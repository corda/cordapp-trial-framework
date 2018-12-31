# Cordapp Development Best Practices 
Whether this is your first cordapp or you are an experienced blockchain developer there are many best practices your development team should consider in order to produce a high quality trial application.

The following sections describe aspects of Cordapp development to keep in mind when preparing your application for the trial. These best practices will help you create a more stable experience for the trial participants.

## Cordapp Jar Deliverables
When Corda runs it picks up many Cordapp jar files in the node. These jar files contain the trial application code and are deployed on all nodes in the trial business network. 

The application should be built in such a way that the states and contracts are in a separate jar in order to make upgrading the cordapp easier: https://docs.corda.net/writing-a-cordapp.html#structure

## Separation of Roles
In a Cordapp trial there are typically many roles within the network that a participant can take on. Each of these roles must be separated from one another. There are two main ways to do this, please confirm your design choice with your R3 solutions engineer.

Two common role separation solutions:
- Have a different Cordapp for each role. Deploy only the relevant Cordapp for the role on each VM.
- Use BNMS to define the role within the node’s membership. The membership can be retrieved and used in application logic.

The UI must take roles into account as well. Does a single UI work for all roles or does each role have its own UI? How does the UI show what role is available? 

## Logging/Error Messages
The trial application should be consistently logging activity inside of flows. When troubleshooting issues on a live network it is imperative to be able to scan logs to look for which node was last active or had an error. 

Any application without logging will be sent back. https://docs.corda.net/node-administration.html#logging

When a flow fails then a FlowException must be thrown: https://docs.corda.net/api/kotlin/corda/net.corda.core.flows/-flow-exception/ The FlowException will not only terminate the flow on the active node but it will rethrow the same exception on all active counterparties to the transaction. This allows all counterparties to cleanly terminate the active flow.

## Contract Constraints
Cordapp compatibility is based on contract constraints in Corda: https://docs.corda.net/api-contract-constraints.html These define which Contract verify methods can be used for transactions. By default Corda uses hash constraints. These constaints should have no impact on your application so long as the application is split up as described in the Cordapp jar deliverables.

## When to use Flows
Flows are the mechanism by which Corda communicates between nodes. They are a highly resilient way to communicate between nodes but it comes with an overhead that makes them more expensive than a classical http API request.

Flows are best used in situations similar to but not limited to the following:

- Facilitate consensus between parties on the network
- [Send and receive](https://docs.corda.net/api-flows.html#sendandreceive) off ledger information between two parties

Flows are not required to do things like query the vault are best not be run constantly on a your trial demo network.

## Transaction Participants
TODO: how to reduce the number of counterparties

## Vault Querying + Pagination
The vault is a set of tables where Corda stores the information on the ledger. The UI of the cordapp will need to query the vault to get the data needed to populate the UI. This can be done using vault services: https://docs.corda.net/api-vault-query.html

When querying the vault by default there is a limit of 200 records to be returned. When there are more than 200 records an exception is thrown. To solve this use pagination: https://docs.corda.net/api-vault-query.html#pagination

You can also query for specific kinds of states to reduce the result set, for example: query only unconsumed states. You can also query for all data page by page as seen in this Stack Overflow answer: https://stackoverflow.com/questions/52174675/vaultquery-exceeds-default-page-size

## X500 Names
Corda Network identities are established using X500 certificates. These identies are how nodes know who the counterparties in their transactions are. 

The X500 names are established as part of the Testnet deployment and are outside of the control of the participants. Therefore, the trial application must not depend on any information from the X500 name to make any logical decision within the application. The BNMS is best suited to associate a role or label with a specific node.

## RPC Client
A Corda node can be communicated with by using the RPC Client: https://docs.corda.net/clientrpc.html This is a Java client which communicates to the Corda node over an RPC connection. The RPC Client should be embedded in the web server. This way the web server can translate all http requests from the UI into an RPC request to the Corda node.

An example application for embedding the RPC Client can be found here: https://github.com/corda/corda/tree/master/samples/irs-demo
