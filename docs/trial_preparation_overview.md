# Trial Preparation
For all Cordapps there are many components which are repeated regardless of the business use case. The steps below are a standard project outline for producing Trial ready Cordapps.

The schedule represents preperation for a brand new Cordapp. Existing Cordapp will not need to follow all of these steps.

## Personnel Requirements
The following is a list of skills that will be utilized when preparing for a Cordapp trial. Multiple requirements may be fulfilled by a single team member.
- Technical Architect
- Corda application developer (Java/Kotlin)
- Web Services developer 
- UI developer 
- Devops (Docker/Azure/Linux)

## Timeline
The time and developers for each step will vary but previous trial preparations have been done over the course 3-4 months.

- Business Use Case Definition
- Architecture and Design
- Cordapp Development
- UI + Services Development
- BNMS Integration
- Application Integration Testing
- Deployment Tooling
- End to End Testing 

### Business Use Case Definition
What business is being solved? The use case typically involves many decentralized parties and reduces the amount of reconciliation required to agree to business transaction. For example:
- In KYC identify verification can be re-used across network participants
- For Cordainsure all reinsurance partners are working off the same insurance policy ("what you see is what I see")
- In instant property all parties involved in a real estate sale are exchanging information about the same proprety

**Output**: An educational document/slide deck which describes the use case at an introductory level. This material will be re-used during the trial itself to edcate the trial participants on why the application was built.

### Architecture and Design
Every Corda application goes through a number of architectural decisions. For trial purposes only a subset of those decisions will be required because the trial application does not have to go through the same rigors of a production system.

Decisions to consider are below. How to make the decision will be covered in the following documents.
- Build the Cordapp using Corda Open Source or Corda Enterprise?
- What framework to use for web services? The default is Springboot.
- What framework to use for the UI? Most common choices are Angular and React.
- What database will be used? Most common choice is to use H2.

Designing the application including model of the following components:
- States: what data must be represented on ledger?
- Flows: what transactions occur between parties?
- Contracts: what rules define what a valid transaction looks like?

**Output**: Technical documentation of the network topology, data model, transaction flow and application architecture. All of these documents should be presentable to trial participants for educational purposes.

### Cordapp Development
Build the actual Cordapp which solves the business use case. This is the implementation of the Cordapp design from the previous step.

The development should be simple for trial purposes as only a single demo use case needs to be completed. The Cordapp is only required to be in an MVP stage. Expectations are set with trial participants up front that this is a demo application and future development is ongoing.

**Size**: Typically large size

**Output**: Cordapp jar files which can be deployed

### UI + Services Development
Development of the UI and Services layer should be done in parallel with the Cordapp development. This layer doesn't require a blockchain skillset and can be tested independently of any blockchain functionality. It is important that the people on each layer communicate to ensure that everyone is using the same data model.

In this step the UI and web services layer for interacting with the Corda node will be built. The web services layer will be a basic RESTful API layer which translates API requests into Corda RPC requests. The UI is independent of the Cordapp and should demonstate the benefits of a decentralized network and privacy to it's users.

**Size**: Typically the UI is a large size and the Services are a medium size

**Output**: Deployable binaries for the UI and Services application

### BNMS Integration
Once the Cordapp is complete the business network membership service must be integrated into the application. Plan for changes to the Cordapp and an additional node in the network.

**Size**: Typically this is a small size

**Output**: Updated Cordapp jars which include the BNMS and a deployable BNO node

### Application Integration Testing
Combine the above steps to integrate the UI/Servies/Cordapp together for a testable application. The goal of the test is to ensure that all components are communicating correctly and the application works as intended. It is expected that application bugs will be uncovered and resolved.

**Size**: Varies

**Output**: none

### Deployment Tooling
Adapt the entire application to the Trial Framework deployment tooling to enable simple deployment. This tooling must streamline the deployment such that a participant with limited technology experience can still deploy the Cordapp.

**Size**: Typically large size
**Output**: A set of scripts, images and infrastructure to support anyone who would like to deploy the Cordapp. Also include documentation for how trial participants can use the deployment tools.

### End to End Testing
This is the most important step in trial preparation. It is critical that multiple weeks are allocated to test your Cordapp in Testnet to ensure that your application performs correctly in a deployed Corda Network. 

**Size**: Varies, the effort will depend on what issues are uncovered
**Output**: A finished product which is trial ready