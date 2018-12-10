#!/usr/bin/env bash
echo "  ______   ______   .______       _______       ___         .___________. _______     _______.___________..__   __.  _______ .___________."
echo " /      | /  __  \  |   _  \     |       \     /   \        |           ||   ____|   /       |           ||  \ |  | |   ____||           |"
echo "|  ,----'|  |  |  | |  |_)  |    |  .--.  |   /  ^  \       \`---|  |----\`|  |__     |   (----\`---|  |----\`|   \|  | |  |__   \`---|  |----\`"
echo "|  |     |  |  |  | |      /     |  |  |  |  /  /_\  \          |  |     |   __|     \   \       |  |     |  . \`  | |   __|      |  |     "
echo "|  \`----.|  \`--'  | |  |\  \----.|  '--'  | /  _____  \         |  |     |  |____.----)   |      |  |     |  |\   | |  |____     |  |     "
echo " \______| \______/  | _| \`._____||_______/ /__/     \__\        |__|     |_______|_______/       |__|     |__| \__| |_______|    |__|     "
echo ""

configureToThisVM () {
    local desiredRole=$1
    local desiredHostname=$2
    local desiredUIFlavour=$3

    cd ~/app/leia-ii-cordapp/deployment
    replaceHostNames.sh $desiredRole $desiredHostname $desiredUIFlavour
    if [ $? -eq 0 ]; then
        echo "Configured to this VM"
    else
        echo "Error whilst configuring to this VM"
        exit 1
    fi
}

role=bno

Role="${role^}"
if [ "$role" = "attester" -o "$role" = "datastore" -o "$role" = "bno" ]
then
    Role="R3-KYC-${role^}"
elif [ "$role" = "bank" -o "$role" = "customer" ]
then
    Role="R3-Demo-${role^}"
else
    echo "$role not recognized"
    exit 10
fi

echo "Enter a one time access key from Corda Testnet"
read oneTimeKey
echo "What country will be on your X500 directory?"
read country
echo "What locality will be on your X500 directory?"
read locality

#configure to this VM (i.e. configure hostnames)
echo "Enter the DNS url that you configured in the Azure deployment step"
read hostName

configureToThisVM $role $hostName

#cordapp
echo "=== Building KYC Cordapp ==="
cd ~/app/leia-ii-cordapp/
~/app/leia-ii-cordapp/gradlew clean deployNodes

# Integrate with Corda Testnet
echo "=== Retrieving Testnet configuration ==="
sudo curl -X POST "https://testnet.corda.network/api/user/node/generate/one-time-key/redeem/$oneTimeKey" -o "node.zip" -H "Cache-Control: no-cache" -H "Content-Type: application/json" -H "Postman-Token: 54ce745c-ff8f-44d5-9430-da60ca310df1" -d "{
     \"x500Name\": {
      \"country\": \"$country\",
      \"locality\": \"$locality\"
     },
     \"include\": {
      \"cordaJar\": false,
      \"cordaWebserverJar\": false,
      \"scripts\": false
     }
    }"
sudo apt install unzip
sudo unzip node.zip -d ~/app/leia-ii-cordapp/testnet_config

#substitute in the Corda Testnet legal name
echo "=== Replacing legal name ==="
legalNameRegex="O=[a-zA-Z0-9[:space:]-]*,[[:space:]]L=[a-zA-Z[:space:]]*,[[:space:]]C=[A-Z]{2}"
testnetLegalNameRegex="OU=[a-zA-Z0-9[:space:]-]*,[[:space:]]O=[a-zA-Z0-9[:space:]-]*,[[:space:]]L=[a-zA-Z[:space:]]*,[[:space:]]C=[A-Z]{2}"
originalLegalName=$(grep -o -E $legalNameRegex ~/app/leia-ii-cordapp/$role/build/resources/main/node_configuration/azure.node.conf)
testnetLegalName=$(grep -o -E $testnetLegalNameRegex ~/app/leia-ii-cordapp/testnet_config/node.conf)
if [ -z "$originalLegalName" ]
then
    echo "originalLegalname is unset, please confirm the $role node.conf has a valid 'myLegalName'"
    exit 1
else
    echo "originalLegalname is currently set to $originalLegalName"
fi
if [ -z "$testnetLegalName" ]
then
    echo "testnetLegalName is unset, please confirm that the Testnet node.conf has a valid 'myLegalName'"
    exit 2
else echo "testnetLegalName is currently set to $testnetLegalName"
fi
sed -i "s/$originalLegalName/$testnetLegalName/g" ~/app/leia-ii-cordapp/$role/build/resources/main/node_configuration/azure.node.conf
echo "$Role legal name is now set to: $(grep -o -E $testnetLegalNameRegex ~/app/leia-ii-cordapp/$role/build/resources/main/node_configuration/azure.node.conf)"

#Substitute in the Corda Testnet keyStore password
echo "=== Replacing key store ==="
keyStoreRegex="\"?keyStorePassword\"?[[:space:]]:[[:space:]]\"[a-zA-Z0-9-]*\""
keyStorePasswordRegex="\"[a-zA-Z0-9-]*\"$"
originalKeyStorePassword=$(grep -o -E $keyStoreRegex ~/app/leia-ii-cordapp/$role/build/resources/main/node_configuration/azure.node.conf | grep -o -E $keyStorePasswordRegex)
testnetKeyStorePassword=$(grep -o -E $keyStoreRegex ~/app/leia-ii-cordapp/testnet_config/node.conf | grep -o -E $keyStorePasswordRegex)
if [ -z "$originalKeyStorePassword" ]
then
    echo "originalKeyStorePassword is unset, please confirm the $role node.conf has a valid 'keyStorePassword'"
    exit 3
else
    echo "originalKeyStorePassword is currently set to $originalKeyStorePassword"
fi
if [ -z "$testnetKeyStorePassword" ]
then
    echo "testnetKeyStorePassword is unset, please confirm that the Testnet node.conf has a valid 'keyStorePassword'"
    exit 4
else echo "testnetKeyStorePassword is currently set to $testnetKeyStorePassword"
fi
sed -i "s/$originalKeyStorePassword/$testnetKeyStorePassword/g" ~/app/leia-ii-cordapp/$role/build/resources/main/node_configuration/azure.node.conf
echo "$Role keyStore password is now set to: $(grep -o -E $keyStoreRegex ~/app/leia-ii-cordapp/$role/build/resources/main/node_configuration/azure.node.conf)"

#Substitute in the Corda Testnet trustStore password
echo "=== Replacing trust store ==="
trustStoreRegex="\"?trustStorePassword\"?[[:space:]]:[[:space:]]\"[a-zA-Z0-9-]*\""
trustStorePasswordRegex="\"[a-zA-Z0-9-]*\"$"
originalTrustStorePassword=$(grep -o -E $trustStoreRegex ~/app/leia-ii-cordapp/$role/build/resources/main/node_configuration/azure.node.conf | grep -o -E $trustStorePasswordRegex)
testnetTrustStorePassword=$(grep -o -E $trustStoreRegex ~/app/leia-ii-cordapp/testnet_config/node.conf | grep -o -E $trustStorePasswordRegex)
if [ -z "$originalTrustStorePassword" ]
then
    echo "originalTrustStorePassword is unset, please confirm the $role node.conf has a valid 'trustStorePassword'"
    exit 3
else
    echo "originalTrustStorePassword is currently set to $originalTrustStorePassword"
fi
if [ -z "$testnetTrustStorePassword" ]
then
    echo "testnetTrustStorePassword is unset, please confirm that the Testnet node.conf has a valid 'trustStorePassword'"
    exit 4
else echo "testnetTrustStorePassword is currently set to $testnetTrustStorePassword"
fi
sed -i "s/$originalTrustStorePassword/$testnetTrustStorePassword/g" ~/app/leia-ii-cordapp/$role/build/resources/main/node_configuration/azure.node.conf
echo "$Role trustStore password is now set to: $(grep -o -E $trustStoreRegex ~/app/leia-ii-cordapp/$role/build/resources/main/node_configuration/azure.node.conf)"

#cordapp systemctl service
echo "=== Establishing cordapp service ==="
sudo mkdir /opt/$role; sudo chown -R corda:corda /opt/$role
cd /opt/$role
sudo cp -r ~/app/leia-ii-cordapp/testnet_config/* /opt/$role/
sudo mkdir /opt/$role/cordapps/
sudo cp ~/app/leia-ii-cordapp/build/nodes/$Role/cordapps/* /opt/$role/cordapps/
sudo cp ~/app/leia-ii-cordapp/lib/membership-service-0.1.jar /opt/$role/cordapps/
sudo cp ~/app/leia-ii-cordapp/lib/membership-service-contracts-and-states-0.1.jar /opt/$role/cordapps/
sudo cp ~/app/leia-ii-cordapp/$role/build/resources/main/node_configuration/azure.node.conf /opt/$role/node.conf
sudo cp ~/app/leia-ii-cordapp/build/nodes/$Role/corda.jar /opt/$role/
sudo cp ~/app/leia-ii-cordapp/build/nodes/$Role/corda-webserver.jar /opt/$role/
sudo chown -R corda:corda /opt/$role/
sudo cp ~/app/leia-ii-cordapp/$role/src/main/resources/node_configuration/corda.service /etc/systemd/system/$role.service
sudo cp ~/app/leia-ii-cordapp/$role/src/main/resources/node_configuration/corda-webserver.service /etc/systemd/system/$role-webserver.service

#start services
echo "=== Starting all KYC services ==="
sudo systemctl daemon-reload
sudo systemctl enable --now $role
sudo systemctl enable --now $role-webserver
sudo systemctl restart $role
sudo systemctl restart $role-webserver