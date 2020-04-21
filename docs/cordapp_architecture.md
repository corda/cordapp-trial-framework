# Cordapp Architecture 
When building a Cordapp and deploying it to a decentralized network there are a number of new factors to take into consideration. Developers are no longer in control of a single centralized service, the application is independently run by another entity. 

The following sections cover the considerations that must be taken into account when architecting and designing a Cordapp.

## Simplifications
In preparation for a Cordapp Trial, architecture choices should be simplified because the application does require all the integrations (if any) necessary for production or every conceivable features to be showcased. 
- The Cordapp Trail consists of 2 weeks of deployment and 1 week of trialing the application.
- All data created will be cleared once the trial is done. Therefore there is no requirement for persisting data for an extended period of time. 
- All data is mock data. Therefore there is no requirement for security of data because no monetary value or personal information is being exchanged.
- Deployment is on a public cloud. No approvals are required to deploy on premise and no machines need to be obtained.

## Corda Open Source and Corda Enterprise
Either Corda Open Source or Corda Enterprise may be used for a Cordapp trial. The main benefit of using Corda Enterprise in a trial at this time is the addition of multi-threading. This will improve the performance of Corda in situations where many flows are being run in parallel.

## 3-tier Architecture
In most of the previous trials, the Corda trial deployments follow a standard 3-tier architecture model. The trial application is more than simply a Cordapp: a UI and Web Services layer must also be included.

1. UI: choice of UI framework is at your discretion. R3 has been facilitating trials which use javascript frameworks such as React.js and AngularJS.
2. Web Services: choice of web service layer is at your discretion. Most Corda project use Springboot. R3 recommends that the web server be JVM based so the Corda RPCClient can be used.
3. Corda: This is Cordapp which handles transactions, contracts, flows and recording data to the ledger.
4. Database: Typically this is H2 for open source deployments. Production deployments of Corda use an enterprise database like SQL Server or Oracle. For the short term trial H2 is sufficient and is already built into Corda. Should you require other DBs In support of you’re application stack, be sure to consider them when thinking about packaging and ease of deployment especially if you want participants to deploy the application.

![alt text](../images/basic_architecture.png "Standard Architecture")

## User Interface
The UI looks no different than any standard browser based UI you are accustomed to seeing. The value of the UI is to demonstrate the value of a decentralized solution and the transaction privacy that is built into Corda.

Each trial use case covers many roles and each role should be distinguished with its own version of the UI. Each role does not need to have a separate code base but each participant should be able to deploy a version of the UI which is specific to the role they are taking on.

When designing the UI keep in mind that the UI will be disconnected from the Corda node. It will interact directly with the web services layer over http and will be completely unaware of the fact that data is being stored on a blockchain ledger. As part of your testing, you should run your UI across several commonly used browsers e.g. internet explorer.

User experience is key in a Corda trial, so one should consider some form of personalization for participants to recognise who is on the business (trial) network and who they are interacting with. Commonly, this can be well defined names visible in the UI, custom test data to their business or images of their logos 

## Web Services
This is a simple layer which translates RESTful http APIs calls into RPC requests for the Corda node. No business logic should be done at this layer. The http APIs will map directly to the Corda flows in a one to one ratio to allow the UI to initiate each type of transaction.

Do note that for a trial, we do not prescribe the securities in the likes of a production application, so no TLS is enabled on the HTTP layer. However should your application requires interaction with mobile apps (e.g. IOS), your deployment strategy would have to include provisioning certificates to allow for HTTPS.

## Cordapp
The implementation of the Corda solution which maps out the data model and the actions that can be taken within the business use case. 

Best practices on how to develop the Cordapp follow [here](./cordapp_development_best_practices.md)

## Network
The trial will be run on Corda Testnet or Corda Pre-production Network as prescribed in the SoW should you be running the trial with R3. Testnet or Corda Pre-production Network provides network services required to operate a Corda Network including: an Identity Manager, a Notary and a Network Map Service. More information can be found here: 
https://docs.corda.net/head/corda-testnet-intro.html https://corda.network/participation/index

The trial deployment framework will facilitate all interaction with Testnet or Pre-prod as part of deploying a node. 
To explore testnet, you will need to register for an account here: https://testnet.corda.network/. If asked for the reason for your request, please write ‘CorDapp Trial Partner’ text box.

On the other hand, to explore Corda pre-production network, please work with the R3 representative to reach out to Corda Network Foundation.

## Quality
The application will need to meet minimum testing requirements to ensure the success of the trial.

#### Application Testing
An inital investment into testing is imperative to ensure the trial deadlines can be met. Creating a test network can be involved and trial test steps can be onerous to perform manually. It is *strongly* recommended that the application development team build the following two test suites at a minimum.

The trial application must pass basic testing on a local machine. The first phase of testing is done with automated unit testing to reduce the risk of regression during trial application development.

The next phase of testing is integration testing of nodes which will be run locally at first before then running the same tests against Corda nodes deployed to the cloud platform of choice.

Information on example implementations can be found here:
 - For [trial applications](./cordapp_testing.md)
 - From Corda documentation: https://docs.corda.net/api-testing.html

#### End to End Testing
Isolated application testing is good for development but insufficient to ensure the Cordapp Trial will be a success. A fully deployed network adds additional complexity:
* An external notary not within control of the BNO
* (optional) Long lived services like the BNMS
* Long lived VMs for Corda nodes
* Integration of API calls from a front end UI
* Deployment by non-technical users
* Unexpected user input (aka not the "happy path")
* Many more

Plan for at least 3 weeks of end to end testing where the trial Cordapp can be tested by people both familiar and unfamiliar with the use case. If you haven't found bugs you're not testing hard enough, especially for new applications. Remember, an application that works for a 3 minutes demo might not stand the test of a 3 weeks trial.

## Business Network Membership Service

Business use cases on Corda are separated into separate business networks. The business network provides a logical separation that ensures that only approved nodes can interact with one another. This is essential in a trial as each iteration of a trial will need to be a separate business network

As a entrance criteria into an R3 led trial, we institute that the application architecture includes a membership service to restrict trial to participants only. Should this feature be absent because of circumstantial reasons, R3 could still provide some support in the form of a business network membership service (BNMS) as a stand alone application. While the BNMS is not production ready, it allows for the creation of a controlled business network where membership can be approve and revoked. Having said that, BNMS is currently being deprecated, so support will eventually be terminated. As such we do recommend that Membership service should be a feature already considered In all production application.

Do take note that BNMS is not production ready and its existence is in support of the corda trial only.

(Optional) A detailed walkthrough of integrating the R3 BNMS is [here](./bnms_integration.md)
 
## Deployment
Once the trial application is developed it will need to be deployed to a public cloud infrastructure platform (e.g. AWS, Azure, Google Cloud etc). On premise deployment is out of scope for Cordapp Trials.

The Trial Framework contains a deployment toolkit for Cordapp Trials. This enables the deployment of cordapps by following a standardized architecture pattern. The toolkit includes example scripts which configure a VM to run all required services for the trial application.

In our previous Corda trial, the application was distributed as a series of Docker images for the UI, Web Services and Cordapp. R3 can assist your team review and design the right Docker configuration and upload the resulting images to a private container registry for sharing the trial images.

The steps required for deployment must be documented and will be distributed to clients on how to deploy the trial application. This includes a step by step guide, screen shots, and potentially a video walkthrough.

More information can be found [here](./deployment_toolkit.md)

#### Network Testing
Deploy the trial application to Testnet and test the use case using Testnet network services. Application behavior on a network may vary from local testing and many types of tests should be run:
- Load/Soak: execute the business use case many times to load 100s or 1000s of transactions to ensure the services continue to function correctly. The quantity of transactions necessary to test will depend on the use case.
- Stress: execute the business use case many times in parallel as many participants may use the trial application simultanesouly. The max throughput is generally not high and will depend on the use case and the number of trial participants. This test is especially Important if your architecture involves some centralisation such that it may become the central point of failure.
- Performance: ensure the application is responsive to single usage. This does not mean a high number of transactions per second but rather that the application is engaging. For example, you do not want your participants to wait 5mins on the UI following each action.
