# GTM Trial Application Deployment
A trial Cordapp application must externally deployable by the technical participants of the trial. The technical experience of the participants will vary widely so the installation process must be straight forward. The aim of this guide is to jump start the preparation of deployment scripts and tooling which simplifies application deployment.

Included are sample scripts that were used as part of the KYC Trial initiative in 2018. The scripts are for reference purposes and will need to be adapted to your specific application. Each trial application will have been architected differently with diverse tech stack, but we hope that this toolkit will help accelerate your trial Corda applications.

## Architecture
For purposes of trial Cordapp deployment this document assumes you are working with a standard UI/Web Server/Cordapp/Database architecture.

![alt text](../images/basic_architecture.png "Standard Architecture")

The deployment toolkit will provide an example for deploying the UI, Web Server and Corda layer. The database layer for new applications is typically H2 for simplicity. Each of these layers will be deployed as a Docker container to the same VM to reduce back and forth network traffic between machines.

## Network
The trial Cordapp will be deployed onto the Corda Testnet or Corda pre-production Network with R3: 

https://testnet.corda.network 

https://corda.network/participation/index

Both Corda Testnet and Corda pre-production network provide the identity manager, network map and notary services required to run a basic Corda network. More information on deploying a basic Corda node can be found here: https://docs.corda.net/head/corda-testnet-intro.html

To explore Corda pre-production network, please work with the R3 representative to reach out to Corda Network Foundation

Because the network services are taken care of, the network you deploy will only the nodes as needed for each of the business use case roles. 

## Infrastructure Requirements
In our previous trials, we have used Microsoft Azure as the cloud service for trial Cordapp deployment. However the toolset required is not microsoft specific so any trial participants would be able to run the same steps in any cloud provider (AWS, GCP, etc).

The minimum requirements are listed below. The machine size may grow based on the use case of the application.
- Ubuntu 18.04
- 2 or more Azure vCPUs
- 4GB memory
- 30GB hard drive
- Able to open required ports in a network security group

You can read more about Azure sizing and select the minimum size here: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes-general

## Deployment Tooling
In order to simplify Corda deployment for individuals with no experience on cloud or blockchain the GTM trial framework includes an example deployment toolkit. These toolkits are not a requirement and you may make changes based on your customer requirements and technical architecture.

The toolkit includes the following types of resources.

#### Scripts
Basic automation for the building and deploying the trial Cordapp to Azure.

Scripts are located [here](../scripts/deployment). A list of our past scripts.

#### Docker
Each layer of the architecture has been containerized. This includes the Cordapp, web server and UI. Each Cordapp role, web server and UI that needs to be deployed must have its own image. Example dockerfiles corresponding to the images for each architecture layer are [included](../docker_images).

Each docker images should have it's own build script and entry point script. An example build script and entry point script are described below. The built images should be uploaded to a Docker Container Registry which is operated by the trial operator. In 2018 trials, we used the Azure Container Registry: https://azure.microsoft.com/en-us/services/container-registry/

Each architecture layer will have it's own set of challenges for configuration based on the platform that is chosen. For reference the toolkit includes references for an Angular UI and a Springboot Web Server.

#### (Optional) Business Networks
If you are running the BNMS CorDapp, then you would need to deploy a BNO node and operated by the trial operator. No participants need to interact with deploying or operating a BNO node. 

As a trial operator you will deploy the BNO node which handles membership for the GTM Trial. The BNO node offers a limited set of actions so the node itself is straight forward.

## Participant Action Overview
The actions available to technical trial participants are:
- install: Prepare the VM by installing all required utilities and the trial Cordapp application
- (optional) bootstrap: Prepare the application for usage by including optional sample data which jump starts usage of the trial Cordapp
- uninstall: Remove trial Cordapp from the VM

## List of scripts we have used
There are many scripts available beyond what is customer facing. These help facilitate the building of the applications, business network and support the client scripts.

In alphabetical order:
#### bootstrap
[Bootstrap](../scripts/deployment/bootstrap.sh)

Given a few parameters about the VM: create test data and join the trial business network. This is an essential script to get correct as all trial participants will use it.

Note that not all applications require bootstrapping. In this example the KYC application required a [customer data json file](../sample_data/bootstrapdata.json) which was downloaded as part of the install process.

The bootstrap script must be hosted on a shared site (eg. Basecamp) and downloaded as part of executing the [cordapp-trial](../scripts/deployment/cordapp-trial) facade script.

#### build_cordapp_images
[Build Cordapp Images Sample](../scripts/build/build_cordapp_images.sh)

From a development machine build and upload all docker images. This is purely internal and makes the latest docker images available to participants and testers alike. The built images should be uploaded to the Docker Container Registry being used for the GTM Trial.

#### cordapp-trial
[GTM Trial ("facade")](../scripts/deployment/cordapp-trial)

A single script "facade" which will be delivered to all participants. It can take 3 actions: install, bootstrap and uninstall. This is the main entry point for all participants. It will always use the most to date script in the event a deployment script bug needs to be resolved.

The benefits of using the facade are:
1. There is only a single script to distribute to all clients
2. The latest version of the deployment scripts will be downloaded on every deployment so any bug fixes will automatically be available	

#### docker-entrypoint
[Docker Entrypoint Sample](../scripts/deployment/docker-entrypoint.sh)

An internal script which runs Corda within its Docker container. This script also defines the runtime parameters for Corda.

#### install
[Install](../scripts/deployment/install.sh)

Prepare the container and application for usage. This is the most important script as it abstracts away the tricky aspects of setting up a Corda node and surrounding architecture. This script will:
- install Docker
- pull the latest trial Cordapp Docker images from a repository
- set up a node.conf
- retrieve and install testnet certificates (Note that the deployment was made on the 2018 Corda Testnet facility)

This script is hosted on a shared site and downloaded as part of executing the [cordapp-trial](../scripts/deployment/cordapp-trial) facade script.

#### replaceHostNames
[Replace Host Names](../scripts/deployment/replaceHostNames.sh)

Internal utility script to update the node config based on user input.

#### request-membership
[Request Membership](../scripts/deployment/request-membership.sh)

Internal script to request membership from the BNO node.

#### uninstall
[Uninstall](../scripts/deployment/uninstall.sh)

Remove the cordapp, web server and UI from the VM. Typically used as part of a reinstall of the trial application.

This script is hosted on a shared site and downloaded as part of executing the [cordapp-trial](../scripts/deployment/cordapp-trial) facade script.

#### BNO Scripts
_Warning_: This is not using docker and is part of a legacy deployment model from source code directly. The deployment process is more involved but occurs once and is under complete control of the trial operator.

Only relevant is you are running the BNMS CorDapp. The BNO node will use systemctl and manual configuration as opposed to Docker. Scripts for deploying the BNO node are:
- build_bno: deploy a BNO node to manage the trial Cordapp Business Network.
- redeploy_bno: Redepoys the BNO node from source.
- setuip_bno: Prepare a VM to run the BNO node.
- uninstall_bno: Remove the BNO node from the VM

## Deployment Process
The external process of deploying a trial Cordapp to Testnet should be thoroughly documented. It is critical to create a detailed step by step deployment for of any trial Cordapp. Assume that your audience is not technical at all as you will have a wide range of experiences and languages to accommodate.

Included in this toolkit is a [pdf](../CorporateCordaKYC-DeploymentInstructions.pdf) of the documentation which was given participants as part of the 2018 KYC GTM Trial (previously CorDapp Trial) initiative. The Azure cloud deployment portion will remain very similar the same but the script deployment may change based on your application.

## Deployment Infrastructure
To support deployment in the background you will require the following services:
- A docker container registry: this will store the images which can be used for the various components of your web application.
    - In previous trials R3 has used https://azure.microsoft.com/en-us/services/container-registry/
    - This allows for multiple versions of each image to be made available
    - The container registry can be used across trials and across applications
- Documentation + file hosting: An interactive site to help accelerate participants deployment and provide up to date scripts.
    - In previous trials R3 has used https://basecamp.com/