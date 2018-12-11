# Cordapp Trial Application Deployment
A trial Cordapp application must be prepared for external deployment by
the technical participants of the trial. The technical experience of the
participants will vary widely so the aim of this guide is to jump start
the prepation of scripts and tooling which simplifies application deployment.

This guide includes sample scripts here were used as part of the KYC Trial
initiative in 2018. The scripts are for reference purposes and will need
to be adapted to your specific application. Each trial Cordapp will have
different needs but this toollkit will accelerate the needs of most trial
Corda applications.

## Architecture
For purposes of trial Cordapp deployment this document assumes you are
working with a standard UI/Web Server/Cordapp/Database architecture.

![alt text](../graphics/basic_architecture.png "Standard Architecture")

Deployment will provide support for the UI, Web Server and Corda layer.
The database layer for new applications is typically H2 for simplicity.
Each of these layers will be deployed as a container to the same VM to
reduce back and forth between machines.

## Testnet

The trial Cordapp will be deployed onto the Corda Testnet Network: https://testnet.corda.network

Testnet provides the doorman, network map and notary services required
to run a basic Corda network. More information on deploying a
basic Corda node can be found here: https://docs.corda.net/head/corda-testnet-intro.html

## Cloud Requirements
Microsoft Azure is the default cloud for trial Cordapp deployment. The
toolset required is not microsoft specific so any trial participants would
be able to run the same steps in any cloud provider (AWS, GCP, etc).

The minimum requirements are listed below. This may grow based on the
use case of the application.
- Ubunut 18.04
- 2 or more Azure vCPUs
- 4GB memory
- 30GB hard drive
- Able to open required ports in a network security group

## Deployment Tooling
In order to simplify Corda deployment for individuals with no experience
on cloud or blockchain the Cordapp trial framework includes an example
deployment toolkit. These toolkits are not a requirement and you may
elect to use others based on your experience for customer requirements.

The toolkit includes the following types of resources:

#### Scripts
Basic automation for the building and deploying the trial Cordapp to Azure.

See a complete list of scripts below.

#### Docker
Containerization of the Cordapp, web server and UI. Each Cordapp role,
web server and UI that needs to be deployed must have its own image. Example
images for each architecture layer are included.

Each set of docker images should have it's own build script and entry
point. An example build script and entry point are included.

Each architecture layer will have it's own set of challenges for configuration
based on the platform that is chosen. For this example the included
references are for an Angular UI and a Springboot Web Server.

#### Business Networks
R3 recommends organizating Corda nodes by business networks. More information
can be found here: https://solutions.corda.net/designs/business-networks-membership-service.html

The business network is essential to separate each iteration of a Cordapp
trial and to distinguish which node(s) have which roles within a trial
(eg. Bank, Customer, etc).

## Participant Action Overview
The actions available to technical trial participants are:
- install: Prepare the VM by installing all required utilities and the
trial Cordapp application
- bootstrap: Prepare the application for usage by including sample data
which jump starts usage of the trial Cordapp
- uninstall: Removes trial Cordapp from the VM

## Complete list of scripts
There are many scripts available beyond what is customer facing. These
help facilitate the building of the applications, business network and
support the client scritpts.

Scripts in alphabetical order:
#### bootstrap
[Bootstrap](../bootstrap.sh)

Given a few parameters about the VM: create test data and join the trial
business network. This is an essential script to get correct as all trial
participants will use it.

Note that not all applications require bootstrapping. In this example the
KYC application required a customer data json file which was downloaded
as part of the install process.

This script must be hosted on a shared site and downloaded as part of
executing the cordapp-trial facade script ([cordapp-trial]).

#### build_cordapp_images
[Build Cordapp Images Sample](../build_cordapp_images.sh)

From a development machine build and upload all docker images. This is
purely internal and used to get the most up to data docker images available
to participants and testers alike.

#### cordapp-trial
[Cordapp Trial ("facade")](../cordapp-trial)

A single script "facade" which will be delivered to all participants. It
can take 3 actions: install, bootstrap and uninstall. This is the main
entry point for all participants. It will always use the most to date
script in the event a deployment script bug needs to be resolved.

#### docker-entrypoint
[Docker Entrypoint Sample](../docker-entrypoint.sh)

The internal script which runs Corda within its Docker container. This
script also defines the runtime parameters for Corda.

#### install
[Install](../install.sh)

Prepare the container and application for usage. This is the most important
script as it abstracts away all the tricky parts of setting up a Corda node
and surrounding architecture. This script will:
- install Docker
- pull down the latest trial Cordapp Doker images
- set up a node.conf
- retrieve and install testnet certificates

This script is hosted on a shared site and downloaded as part of executing
the cordapp-trial facade script.

#### replaceHostNames
[Replace Host Names](../replaceHostNames.sh)

Internal utility script to update the node config based on user input.

#### request-membership
[Request Membership](../request-membership.sh)

Internal script to request membership from the BNO node.

#### uninstall
[Uninstall](../uninstall.sh)

Remove the cordapp, web server and UI from the VM. Typically
used as part of a reinstall of the trial application.

This script is hosted on a shared site and downloaded as part of executing
the cordapp-trial facade script.

#### BNO Scripts
_Warning_: This is not using docker and is part of a legacy deployment
model from source code directly. The BNO node will use systemctl and
manual configuration as opposed to Docker. The BNO is only deployed once
so the trial participants will not notice the difference.
- build_bno: deploy a BNO node to manage the trial Cordapp Business Network.
- redeploy_bno: Redepoys the BNO node from source.
- setuip_bno: Prepare a VM to run the BNO node.
- uninstall_bno: Remove the BNO node from the VM

R3 is planning to upgrade the BNO deployment process in the future.

## Deployment Process
The process of deploying a trial Cordapp to Testnet should be thoroughly
documented. It is critical to structure a detailed step by step deployment
for of any trial Cordapp. Assume that you audience is not technical
at all as you will have a wide range of experiences to accommodate.

Included in this toolkit is a pdf of the documentation which was given
participants as part of the 2018 KYC Cordapp Trial initiative. The Azure
cloud deployment portion will remain very similar the same but the script
portion may change based on your application.

## Deployment Infrastructure
To support deployment in the background you will require the following
services:
- A docker container registry: this will store the images which can be
used for the various components of your web application.
    - In previous trials R3 has used https://azure.microsoft.com/en-us/services/container-registry/
- Documentation + file hosting: An interactive site to help accelerate
participants deployment and provide up to date scripts.
    - In previous trials R3 has used https://basecamp.com/

## Accelerated VM Provisioning (Alpha)
TODO: R3 has begun experimenting with Terraform (https://www.terraform.io/)
to accelerate the provisioning of cloud VMs. The process of creating networks
manually is very time intensive because of the many configurations
required and the long deploy time. Terraform automates this and allows
for much faster network creation for testing.