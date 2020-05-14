# Azure Best Practices
**Notes**: While we have only presented Azure from our past experiences, the GTM trial, especially the Corda platform, can be deployed on all cloud infrastructures (e.g. Google Cloud, Amazon Web Services etc.). Having said that, depending on individual design, the top of the stack application may require integration with proprietary stacks provided by the cloud service provider e.g. Azure AD.

---

Azure will greatly simplify the deployment of a Corda Business Network. This document outlines a few tips and tricks to help you manage your Business Network.

## Virtual Machines
* You will be creating and destroying many VMs over the course of the project. Make descriptive names that are unique as they cannot be used again
* When creating a VM use a password for access instead of an ssh key. Generally these VMs are shared and ssh keys are not easily shareable.

## Container Registry
* Upgrade your container to get more space and faster performance. Your image push and pulls may be slow on the base version of the Container Registry.
* There are two access keys in each registry. Use only one for each trial and then rotate the key on completion. The access key will be in the deployment scripts so you need to protect against participants from getting future updates.