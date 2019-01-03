# Business Network Membership Service 
In order to establish a business network R3 provides a business network membership service (BNMS) as a stand alone application. The BNMS allows for the creation of a business network for the trial operator where membership can be approve and revoked. 

A BNMS is required as part of a Cordapp Trial solution. R3 will provide guidance on best practice usage of the BNMS.

- Separate each Cordapp Trial from previous trials that have been run
- Assign a business role to each Corda node that defines what actions the node can take
- Assign a visible description of the node for other members of the network

The BNMS is an open source Cordapp solution: https://github.com/corda/corda-solutions/tree/master/bn-apps/memberships-management

Documentation on how to use the BNMS is here: https://solutions.corda.net/designs/business-networks-membership-service.html

It is expected that the BNMS may need to be modified to meet the needs of specifi Cordapps. For deeper education you can refer to the source code: https://github.com/corda/corda-solutions/tree/master/bn-apps/memberships-management/membership-service/src/main/kotlin/net/corda/businessnetworks/membership 

## How to integrate the BNMS
Integrating the BNMS requires changes in the Cordapp and a new node within the trial business network. The following steps cover each area of the Cordapp that needs to be adapted for the BNMS.

Example source code from the 2018 KYC Cordapp Trial is [included](../sample_code/bno_node).

## Business Network Operator (BNO) Node
Each business network requires a BNO node in addition to the standard network services provided by a Corda Network. The BNO node tracks role assignment and membership for the business network it is deployed to. It acts as a lookup for nodes within the business network to know what Corda nodes have membership in the business network and what role that node represents.

The BNO node will be represented within the Cordapp's `build.gradle` file.

```
node {
        name "O=BNO,L=New York,C=US"
        p2pPort 10005
        rpcSettings {
            address("localhost:10006")
            adminAddress("localhost:10046")
        }
        cordapps = [
                "$project.group:cordapp-contracts-states:$project.version",
                "$project.group:cordapp:$project.version",
        ]
        rpcUsers = [[ user: "user1", "password": "test", "permissions": ["ALL"]]]
    }
```

The Cordapp iteslf will include the compiled jar of the BNO: 
```
    cordaCompile files('../lib/membership-service-1.0.jar')
    cordaCompile files('../lib/membership-service-contracts-and-states-1.0.jar')
```

## Flow Responder Integration
The BNO node does not enforce membership within the business network. Memebership enforcement occurs with each flow's responder class. This is the entry point for any node which has a flow initiated to that node. Each flow responder will check that the counter party who is initiating the flow responder is a member of the business network. 

The membership check is made automatically within a new BNO provided super class `BusinessNetworkAwareInitiatedFlow`. This is demonstrated in the BNMS readme: https://github.com/corda/corda-solutions/tree/master/bn-apps/memberships-management#designing-your-flows-for-business-networks

The Cordapp's flow responders should inherit from this class as follows:
```
    @InitiatedBy(Initiator::class)
    class Acceptor(flowSession: FlowSession) : BusinessNetworkAwareInitiatedFlow<SignedTransaction>(flowSession) {
        @Suspendable
        override fun onOtherPartyMembershipVerified(): SignedTransaction {
            val signTransactionFlow = object : SignTransactionFlow(flowSession) {
                override fun checkTransaction(stx: SignedTransaction) = requireThat {
                    "Must be signed by the initiator" using (stx.sigs.any())

                    // check the transaction for correctness

                    stx.verify(serviceHub, false)
                }
            }

            return subFlow(signTransactionFlow)
        }
    }
```

Additionally, each flow responder will need to implement the `bnoIdentity` method. In this example the BNO node identity is hard coded but normally this would be moved to configuration.
```
override fun bnoIdentity(): Party {
            return serviceHub.networkMapCache.getPeerByLegalName(CordaX500Name.parse("O=BNO,L=New York,C=US"))!!
        }
```

## Membership Management
Once the Cordapp is checking membership in the flow responder each Corda node must apply for membership when it first starts or else it will no longer be able to communicate with the other nodes in the business network. Membership application is done via an http API request. During deployment this API request will be automated to ensure that all trial participant nodes have membership. If a message from a non-member is received a "Counterparty not member" exception will be thrown.

An example membership request API is [here](../sample_code/business_network/cordapp_node/membership_apis.kt). This request is made from the bootstrap script as seen [here](../scripts/deployment/bootstrap.sh).

Two pieces of information must be provided when requesting membership:
1. What role will this node play?
2. What dislpay name should this node have?

From the BNO node perspective an acceptance protocol for membership acceptance must be provided. For the simplicity of the Cordapp trial `MembershipAutoAcceptor` is strongly recommended as a membership acceptance protocol. When auto acceptance is enabled any node that requests membership is automatically approved. This is poor security in a production network but for the simplicity of a short trial this is the lowest cost implementation.

The membership acceptor is defined as a subclass of `BNODecisionMaker`. An [example reference](../sample_code/business_network/bno_node/customization/DecisionMaker.kt) is provided.

```
class DecisionMaker() : BNODecisionMaker {

    override fun autoActivateThisMembership(membershipState: Membership.State): Boolean {
        return listOf({<your roles>}).contains(membershipState.membershipMetadata.role.toLowerCase())
    }
}
```

## BNO API Endpoints
The BNO is a central retrieval for membership data. As such it must provide APIs which return the current state of membership. An API should be provided for:
- `memberships`: the active membership on the ledger
- `activate`: active a membership on the ledger
- `revoke`: revoke a membership already on the ledger

An [example reference](../sample_code/business_network/bno_node/api/BnoApi.kt) is available.

## BNO Configuration
Finally bring all the above pieces together with a [configuration file](../sample_code/business_network/cordapp_node/membership-service.properties) to tell the Corda node how to operate with the business network.
- `net.corda.businessnetworks.membership.bnoName` => X500 name of the BNO node
- `net.corda.businessnetworks.membership.notaryName` => X500 name of the network notary
- `net.corda.businessnetworks.membership.bnoDecisionMaker` => How to handle membership applications, this will be an automatic acceptor

This configuration file is built into the node which means this configuration cannot be changed at runtime. That means that the X500 names of the BNO and the Notary are locked in once clients have begun deploying. **Make sure you have stable BNO node prior to beginning deployment, otherwise a participant redeploy will be required.**

More information on the configuration is available in the BNMS repository: https://github.com/corda/corda-solutions/tree/master/bn-apps/memberships-management#configuration

## Role Lookup
Now that the Cordapp has joined the business network you can start using membership data to lookup other nodes in the business network. This way your cordapp can target specific nodes to be counterparties depending on what role they have.

The membership object contains to pieces of information:
1. Role: what role does this node play on the network?
2. Display Name: reference name for the node

When using flows to interact between node the Cordapp can query the parties of the business network as seen below:
```
    @POST
    @Path("defaultAttestation")
    fun getDefaultAttestation(): Response {
        return try {
            val roles = getPartiesOnThisBusinessNetwork().filter {
                it.membershipMetadata.role.equals(<your role>,true)
            }.map { it.party }
            if(roles.size > 1) {
                return Response.status(NOT_FOUND).entity("Too many roles found in Business Network").build()
            }
            val role = roles.firstOrNull()
            if(role == null) {
                return Response.status(NOT_FOUND).entity("Role not found in Business Network").build()
            }
            logger.info("Going to use this role: $role")

            ....
    }
```

A utility function for getting a list of parties can be helpful for wrapping `GetMembersFlow`. This flow will use a local membership cache on the node as going to the BNO node for a membership list repeatedly can cause performance issues. 	
```
    private fun getPartiesOnThisBusinessNetwork() : List<PartyAndMembershipMetadata> {
        val flowHandle = services.startTrackedFlow(::GetMembersFlow,false)
        return flowHandle.returnValue.getOrThrow()
    }
```

## Membership Cache
Each node maintains a cache of membership for performance reasons and to be resilient in the event that the BNO node becomes unavailable. 

Providing a cache clear endpoint is recommended for each Corda node. In the event the node's membership cache becomes corrupt this allows the node to reset itself and get the latest information. 