# Technical Requirements

## Corda Open Source and Corda Enterprise
Either Corda Open Source or Corda Enterprise may be used for a Cordapp trial. Open Source Corda is currently the default for Cordapp Trials but Corda Enterprise can also be used.

The main benefit of using Corda Enterprise in a trial at this time is the addition of multi-threading. This will improve the performance of Corda in situations where many flows are being run in parallel.

## Architecture
Corda deployments follow a standard 3-tier architecture model. The trial application is more than a Cordapp. It also includes a UI and Web Services layer.

1. UI: choice of UI framework is at your discretion. R3 has been facilitating trials which use javascript frameworks such as React.js and AngularJS.
2.	Web Services: choice of web service layer is at your discretion. Most Corda projects use Springboot. R3 recommends that the web server be JVM based so the Corda RPCClient can be used.
3.	Corda: This is Cordapp which handles transactions, contracts, flows and recording data to the ledger.
4. Database: Typically this is H2 or Postgres for open source deployments. Production deployments of Corda use an enterprise database like SQL Server or Oracle. For a short term trial H2 is generally sufficient and is already built into Corda.

![alt text](../graphics/basic_architecture.png "Standard Architecture")

## Testnet
The Cordapp trial will be run on Corda Testnet which is the Corda Network sandbox. Testnet provides the network services required to operate a Corda Network including: a Doorman, a Notary and a Network Map. More information can be found here: https://docs.corda.net/head/corda-testnet-intro.html

The trial framework will facilitate all interaction with Testnet as part of deploying a node. 

To explore testnet, you will need to register for an account here: https://testnet.corda.network/. If asked for the reason for your request, please write ‘CorDapp Trial Partner’ text box.

## Quality
The application will need to meet minimum testing requirements to ensure the success of the trial.

#### Application Testing
The trial application must pass basic testing on a local machine. Ideally this is done with automated testing to reduce the risk of regression during trial application development. R3 will provide guidance on testing best practices.

#### Network Testing
Deploy the trial application to Testnet and test the use case when using Testnet network services. Application behaviour on a network may vary from local testing and many types of tests should be run.

Once the application is stable and deployed it should be tested for:

- Load: execute the business use case many times to load 100s or 1000s of transactions to ensure the services continue to function correctly. The quantity of transactions necessary to test will depend on the use case. The system does not need to be tested to the breaking point as a Cordapp Trial is typically lighter weight.
- Stress: execute the business use case many times in parallel as many participants may use the trial application simultaneously. The max throughput generally does not need to be high high and will depend on the use case as well as the number of trial participants.
- Performance: ensure the application is responsive to basic usage. This does not mean a high number of transactions per second but that the application is engaging.

## Business Network Membership Service

Amongst the larger Corda Network each business use case can be separated into business networks. The business network provides a logical separation from the rest of the network that ensures only approved nodes can interact with one another. This is essential in a trial as each iteration of a trial will need to be a separate business network.

In order to establish a business network R3 provides a business network membership service (BNMS) as a stand alone application. The BNMS allows for the creation of a business network for the trial operator where membership can be approve and revoked. 

A BNMS is required as part of a Cordapp Trial solution. R3 will provide guidance on best practice usage of the BNMS.

- Separate each Cordapp Trial from previous trials that have been run
- Assign a business role to each Corda node that defines what actions the node can take
- Assign a visible description of the node for other members of the network

The BNMS is an open source Cordapp solution: https://github.com/corda/corda-solutions/tree/master/bn-apps/memberships-management

Documentation on how to use the BNMS is here: https://solutions.corda.net/designs/business-networks-membership-service.html
 
## Deployment
Once the trail application is developed it will need to be deployed to a public cloud infrastructure platform (e.g. AWS, Azure, Google Cloud etc). On premise deployment is out of scope for Cordapp Trials.

This repository containers a deployment toolkit for Cordapp Trials. This enables deploying cordapps by following a standardized architecture pattern. The toolkit includes scripts which configure a VM to run all required services for the trial application.

The trial application is distributed as a series of Docker images for the UI, Web Services and Cordapp. R3 will help your team construct the right Docker configuration and upload the resulting images to a private container registry for sharing the trial images.

The steps required for deployment must be documented and will be distributed to clients on how to deploy the trial application. This includes a step by step guide, screen shots, and potentially a video walkthrough.

More information can be found [here](../README.md)


## Technical Documentation & Brief
Thorough documentation detailing the architecture and design of the application to share with R3 team. This is to enable R3 to have the tools to support the trial application design and development. The documentation will not be shared beyond R3.
