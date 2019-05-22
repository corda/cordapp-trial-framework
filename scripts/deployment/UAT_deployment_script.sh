#!/bin/bash

# Welcome to the UAT deployment script. Replace all variables in [] with hardcoded values.

# Exit on error
set -e

# colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
Purple='\033[0;35m'
NC='\033[0m'

# font style
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

TOTAL_STEPS=8

printf "${CYAN}
  ████████╗██████╗ ██╗ █████╗ ██╗   
     ██╔══╝██╔══██╗██║██╔══██╗██║      
     ██║   ██████╔╝██║███████║██║      
     ██║   ██╔══██╗██║██╔══██║██║      
     ██║   ██║  ██║██║██║  ██║███████╗ 
     ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚══════╝ 
\n${NC}"


# Check if the keystore has been obtained and saved in the appropriate location
if test -f /opt/corda/certificates/nodekeystore.jks; 
then printf "${GREEN}Installation process is started.\n${NC}"; 
else printf "${RED}Your corda is not ready. Please check with R3 for more details.\n${NC}" && exit 1;
fi

# Stop the service if it already exists
systemctl is-active --quiet corda.service && systemctl stop corda.service
systemctl is-active --quiet voltron_trial.service && systemctl stop voltron_trial.service

# Download and unzip the installation pacakages
printf "${GREEN}Step 1/${TOTAL_STEPS}:${NC} Downloading the [CorDapp Project Name] installation packages..\n"

# Insert a link to an artifactory instance or general hosting tool
wget -N "[LINK TO ARTIFACTORY]"
printf "${GREEN}Step 2/${TOTAL_STEPS}:${NC} Decompressing the installation pacakges..\n"
tar xvf voltron_trial.tar
printf "${GREEN}Step 3/${TOTAL_STEPS}:${NC} Gather user input for environment preparation..\n"
printf "${YELLOW}Please answer the following questions to complete the installation:\n${NC}"

# Set up configuration for the BNMS
until [[ $bnms_displayname =~ ^[-A-Za-z0-9_,[:space:]]+$ ]]; 
do
    printf "${YELLOW}- Please input your company display name: ${NC}"
    read -r bnms_displayname
    if [[ ! $bnms_displayname =~ ^[-A-Za-z0-9_,[:space:]]+$ ]];then
        printf "${RED}${bnms_displayname} is invalid.\n\n${NC}"
    fi
done

until [ "${bnms_role}" == "[ROLE]" -o "${bnms_role}" == "[ROLE]" ]
do
	printf "${YELLOW}- Please select your company role ([ROLE] or [ROLE]): ${NC}"
    read -r bnms_role
    if [ "${bnms_role}" != "[ROLE]" -a "$bnms_role" != "[ROLE]" ];then
        printf "${RED}${bnms_role} is invalid.\n${NC}"
    fi
done

sudo sed -i -e "s/[PROJECT NAME].bn.displayName=.*/[PROJECT NAME].bn.displayName=${[ROLE]}/" membership-service.properties
sudo sed -i -e "s/[PROJECT NAME].bn.role=.*/[PROJECT NAME].bn.role=${[ROLE]}/" membership-service.properties


# Install necessary packages
printf "${GREEN}Step 4/${TOTAL_STEPS}:${NC} Installing necessary packages for [PROJECT NAME]..\n"
sudo apt-get upgrade -y 
sudo apt-get update -y
sudo apt-get install zip -y
sudo apt-get install unzip -y

# Install database
printf "${GREEN}Step 5/${TOTAL_STEPS}:${NC} Installing PostgreSQL database..\n"

#  Install postgresql-9.6
sudo apt-get install postgresql postgresql-contrib -y
sudo -u postgres psql --command="DROP database if exists [PROJECT NAME];"

# Create database and db user
printf "${GREEN}Step 6/${TOTAL_STEPS}:${NC} Updating database schema..\n"
sudo -u postgres psql --command="create database [PROJECT NAME];"
sudo -u postgres psql --command="drop user if exists [PROJECT NAME];"
sudo -u postgres psql --command="create user [PROJECT NAME] with encrypted password 'password';"
sudo -u postgres psql --command="grant all privileges on database [PROJECT NAME] to [PROJECT NAME];"

# Install ansible
printf "${GREEN}Step 7/${TOTAL_STEPS}:${NC} Installing ansible..\n"
sudo apt-get install software-properties-common -y
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install ansible -y

# Run ansible script
printf "${GREEN}Step 8/${TOTAL_STEPS}:${NC} Installing [PROJECT NAME]..\n"
ansible-playbook [PROJECT NAME]_trial.yml --connection=local

printf "${CYAN}
 █████╗ ██╗     ██╗          ██████╗ ██████╗ ███╗   ███╗██████╗ ██╗     ███████╗████████╗███████╗██████╗ ██╗
██╔══██╗██║     ██║         ██╔════╝██╔═══██╗████╗ ████║██╔══██╗██║     ██╔════╝╚══██╔══╝██╔════╝██╔══██╗██║
███████║██║     ██║         ██║     ██║   ██║██╔████╔██║██████╔╝██║     █████╗     ██║   █████╗  ██║  ██║██║
██╔══██║██║     ██║         ██║     ██║   ██║██║╚██╔╝██║██╔═══╝ ██║     ██╔══╝     ██║   ██╔══╝  ██║  ██║╚═╝
██║  ██║███████╗███████╗    ╚██████╗╚██████╔╝██║ ╚═╝ ██║██║     ███████╗███████╗   ██║   ███████╗██████╔╝██╗
╚═╝  ╚═╝╚══════╝╚══════╝     ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚══════╝╚══════╝   ╚═╝   ╚══════╝╚═════╝ ╚═╝
\n
=== Congratulations, the [PROJECT NAME] node is ready for you! ===
=== For the easy trial purpose, your login credentials have been set as ===
=== username: [PROJECT NAME] ===
=== password: password ===
\n\n
${NC}"