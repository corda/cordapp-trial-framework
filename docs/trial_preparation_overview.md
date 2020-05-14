# Trial Preparation
For all Cordapps there are many components which are repeated regardless of the business use case. The steps below are a general project outline for producing Trial ready Cordapps.

The schedule represents preparation for a brand new Cordapp. Existing Cordapp will not need to follow all of these steps.

## Personnel Requirements
The following is a list of skills that will be typically utilized when preparing for a GTM trial. Multiple requirements may be fulfilled by a single team member.
- Technical Architect
- Corda application developer (Java/Kotlin)
- Web Services developer 
- UI developer 
- Devops (Docker/Cloud/Linux)

## Timeline
The time and number of developers for each step will vary but previous trial preparations have been done over the course 3-4 months.

- Business Use Case Definition
- Architecture and Design
- Cordapp Development
- UI + Services Development
- Membership Service Integration
- Application Integration Testing
- Deployment Tooling
- End to End Testing (Systems testing)

### Business Use Case Definition
What business is being solved? The use case typically involves many decentralized parties and reduces the amount of reconciliation required to agree to business transaction. For example:
- In KYC identify verification can be re-used across network participants
- For Cordainsure all reinsurance partners are working off the same insurance policy ("what you see is what I see")
- In Contour all parties involved in a Trade are exchanging information about the same Letter of Credit (LoC) 

**Output**: An educational document/slide deck which describes the use case at an introductory level. This material will be re-used during the trial itself to edcate the trial participants on why the application was built.

### Architecture and Design
Every Corda application goes through a number of architectural decisions. While the product for the purpose of a trial may differ from what is put eventually into production, it is expected to have gone through the rigors of testing like a production applicaton.

Some decisions to consider are as follows. How to make the decision will be covered in the following documents.
- Build the Cordapp using Corda Open Source or Corda Enterprise?
- What framework to use for web services? The default is Springboot.
- What framework to use for the UI? Most common choices are Angular and React.
- What database will be used? Most common choice is to use H2.

Designing the application including modeling of the following components:
- States: what data must be represented on ledger?
- Flows: what transactions occur between parties?
- Contracts: what rules define what a valid transaction looks like?

**Output**: Technical documentation of the network topology, data model, transaction flow and application architecture. All of these documents should be presentable to trial participants for educational purposes.

### Cordapp Development
Build the actual Cordapp which solves the business use case. This is the implementation of the Cordapp design from the previous step.

The expectations and the features to showcase are usually set upfront prior to the trial. If you are running the trial with R3, then the expectations would have been negotiated in the form of a contract.

**Size**: Typically large size

**Output**: Cordapp jar files which can be deployed

### UI + Services Development
Development of the UI and Services layer should be done in parallel with the Cordapp development. This layer doesn't require a blockchain skillset and can be tested independently of any blockchain functionality. It is important that the people on each layer communicate to ensure that everyone is using the same data model.

In this step the UI and web services layer for interacting with the Corda node will be built. The web services layer will be a basic RESTful API layer which translates API requests into Corda RPC requests. The UI is independent of the Cordapp and should demonstate the benefits of a decentralized network and privacy to it's users.

**Size**: Typically the UI is a large size and the Services are a medium size

**Output**: Deployable binaries for the UI and Services application

### Membership Services Integration
A If you are setting up the trials on the Corda networks, then a membership service functionality is mandatory. Should this feature be absent because of circumstantial reasons, one could use the business network membership service (BNMS) as a stand alone application. While the BNMS is not production ready, it allows for the creation of a controlled business network where membership can be approve and revoked. Having said that, BNMS Is currently being deprecated, so support will eventually be terminated. As such we do recommend that Membership service should be a feature already considered In all production application. The feature must be integrated into the application prior to start of trial. 

**Size**: Typically this is a small size, but may be large depending on your requirements

**Output**: As part of your appplication release

### Application Integration Testing
Combine the above steps to integrate the UI/Servies/Cordapp together for a testable application. The goal of the test is to ensure that all components are communicating correctly and the application works as intended. It is expected that application bugs will be uncovered and resolved.

**Size**: Varies

**Output**: none

### Deployment Tooling
Adapt the entire application to the Trial Framework deployment tooling to enable simple deployment. This tooling must streamline the deployment such that a participant with limited technology experience can still deploy the Cordapp. Should you be runnning the trial with R3, then the assigned Solutions Engineer would have the latest update on the requirements towards deployment on the choice network e.g. Corda pre-production network. For the latter, one may have to split the deployment of platform (corda node) and application (cordapp) into 2.

**Size**: Typically large size

**Output**: A set of scripts, images and infrastructure to support anyone who would like to deploy the Cordapp. Also include documentation for how trial participants can use the deployment tools.

### End to End Testing (System testing)
This is the most important step in trial preparation. It is critical that multiple weeks are allocated to test your Cordapp on the network where you are running the trial to ensure that your application performs as designed during the trial. 

**Size**: Varies, the effort will depend on what issues are uncovered

**Output**: A finished product rigorously tested and is trial ready