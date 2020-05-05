# Azure Best Practices
Azure will greatly simplify the deployment of a Corda Business Network. This document outlines a few tips and tricks to help you manage your Business Network.

Maybe worth mentioning other cloud platforms are supported as well. however, the scripts were written for Azure, so using Azure would have an advantage over other cloud platform.

## Virtual Machines
* You will be creating and destroying many VMs over the course of the project. Make descriptive names that are unique as they cannot be used again
* When creating a VM use a password for access instead of an ssh key. Generally these VMs are shared and ssh keys are not easily shareable.

## Container Registry
* Upgrade your container to get more space and faster performance. Your image push and pulls may be slow on the base version of the Container Registry.
* There are two access keys in each registry. Use only one for each trial and then rotate the key on completion. The access key will be in the deployment scripts so you need to protect against participants from getting future updates.