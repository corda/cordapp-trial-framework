# Business Network Membership Service 
In order to establish a business network R3 provides a business network membership service (BNMS) as a stand alone application. The BNMS allows for the creation of a business network for the trial operator where membership can be approve and revoked. 

A BNMS is required as part of a Cordapp Trial solution. R3 will provide guidance on best practice usage of the BNMS.

- Separate each Cordapp Trial from previous trials that have been run
- Assign a business role to each Corda node that defines what actions the node can take
- Assign a visible description of the node for other members of the network

The BNMS is an open source Cordapp solution: https://github.com/corda/corda-solutions/tree/master/bn-apps/memberships-management

Documentation on how to use the BNMS is here: https://solutions.corda.net/designs/business-networks-membership-service.html

## How to integrate the BNMS
Integrating the BNMS requires changes in the Cordapp and a new node within the trial business network. The following steps cover each area of the Cordapp that needs to be adapted for the BNMS.

### Business Network Operator (BNO) Node
Each business network requires a BNO node in addition to the standard network services provided by a Corda Network. The BNO node tracks role assignment and membership for the business network it is deployed to. It acts as a lookup for all nodes to know what Corda nodes have membership in the business network and what role that node represents.

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

### Flow Responder
The BNO node does not enforce membership within the business network. Memebership enforcement occurs with each flow's responder class. This is the entry point for any node which has a flow initiated to that node. Each flow responder will check that the counter party who is initiating the flow responder is a member of the business network. 

The membership check is made automatically within a new BNO provided super class `BusinessNetworkAwareInitiatedFlow`. The Cordapp's flow responders should inherit from this class as follows:
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

### Membership Management
Once the Cordapp is checking membership in the flow responder each Corda node must apply for membership when it first starts or else it will no longer be able to communicate with the other nodes in the business network. Membership application is done via an http API request. During deployment this API request will be automated to ensure that all trial participant nodes have membership.

From the BNO node perspective a method for membership acceptance must be provided. For the simplicity of the trial the `MembershipAutoAcceptor` is strongly recommended as a membership acceptance protocol. When auto acceptance is enabled any node that requests membership is automatically approved. This is poor security in a production network but for the simplicity of a short trial this is the lowest cost implementation.

### API Endpoints
The BNO is a central retrieval for membership data. As such it must provide APIs which return the current state of membership. An API should be provided for:
- `memberships`: the active membership on the ledger
- `activate`: active a membership on the ledger
- `revoke`: revoke a membership already on the ledger

### Membership Cache
Each node maintains a cache of membership for performance reasons and to be resilient in the event that the BNO node becomes unavailable. 

Providing a cache clear endpoint is recommended for each Corda node. In the event the node's membership cache becomes corrupt this allows the node to reset itself and get the latest information.