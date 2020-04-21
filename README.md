# Cordapp Trials

Decentralized blockchain networks require participation from a wide group of participants from a diverse background. Cordapp Trial by R3 provide a 6 week educational walkthrough of applications which solve real world business use cases. A network of dozens of participants from around the world will be brought together for a 1 week global trial which demonstrates the effectivess of blockchain solutions. Trial participants will get hands on with the technology to gain an understanding of what it means to run a real world business application powered by blockchain technology.

Previous Cordapp Trials have covered a wide variety of business use cases with many more to come.

- Know Your Customer [(KYC)](https://marketplace.r3.com/solutions/leia-ii)
- Reinsurance [(Cordainsure)](https://marketplace.r3.com/solutions/cordainsure)
- Trade Finance [(Contour)](https://www.contour.network/)

## Trial Framework

Partners of R3 who wish to run their application in a Cordapp Trial will need to ensure it is ready to be deployed and used by a set of new customers. This generally requires a series of upgrades to existing Cordapps to provide a seamless experience for trial participants.

This repository contains documents, scripts, code snippets, configuration and sample data that will jump start your Cordapp Trial preparation. The end result will be a Cordapp which is easily deployable to Testnet or Corda Pre-prodcution network and ready to meet the scale of a week long global trial.

## How should this framework be used?

Whether you're building a new Cordapp from scratch or adapting an existing Cordapp this framework will accelerate your development timelines. The content here has been produced from the experience of previous trials and will allow you to focus on the most important aspect of your development: the business use case. 

In the framework's initial state it is intended to be used in tandem with guidance from your R3 solutions engineer. The content will improve over time.

## What is the Trial Framework?

This framework is a result of automation and stability improvements made as a part of executing previous Cordapp Trials. It provides a number of benefits that streamline the process of deploying and operating a Corda node.

- Scripts to setup Linux VMs
- Encapsulate the Corda node and related services in docker images 
- Business Network integration 

These are standard components leveraged across a variety of solutions which have already been pre-built and tested.

## Table of Contents

Documentation for integrating the trial framework is available for the following topics. These documents will walk you through the steps required to make your application trial ready.

It is recommended to follow them in sequence as they should follow your natural development cycle.

- [Trial Preparation Overview](./docs/trial_preparation_overview.md) - Outline of the steps that must be taken to prepare for a successful trial
- [Cordapp Architecture](./docs/cordapp_architecture.md) - Architecture + application requirements for a trial ready Cordapp
- [Cordapp Development Best Practices](./docs/cordapp_development_best_practices.md) - Design considerations for your Cordapp
- [Integrating the Business Network Management Service](./docs/bnms_integration.md) - How to integrate the BNMS into your Cordapp
- [Deployment Toolkit](./docs/deployment_toolkit.md) - How to make your cordapp easily deployable by a diverse and potentially non-technical audience in a short period of time
- [Azure Best Practices](./docs/azure_best_practices.md) - Tips and tricks on how to manage Azure resources for a trial business network.
- [Participant Onboarding](./docs/participant_onboarding.md) - Now that you have a trial ready application be prepared to answer questions for the participant technical teams.