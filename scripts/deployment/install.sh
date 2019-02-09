#!/usr/bin/env bash
echo "  ______   ______   .______       _______       ___         .___________. _______     _______.___________..__   __.  _______ .___________."
echo " /      | /  __  \  |   _  \     |       \     /   \        |           ||   ____|   /       |           ||  \ |  | |   ____||           |"
echo "|  ,----'|  |  |  | |  |_)  |    |  .--.  |   /  ^  \       \`---|  |----\`|  |__     |   (----\`---|  |----\`|   \|  | |  |__   \`---|  |----\`"
echo "|  |     |  |  |  | |      /     |  |  |  |  /  /_\  \          |  |     |   __|     \   \       |  |     |  . \`  | |   __|      |  |     "
echo "|  \`----.|  \`--'  | |  |\  \----.|  '--'  | /  _____  \         |  |     |  |____.----)   |      |  |     |  |\   | |  |____     |  |     "
echo " \______| \______/  | _| \`._____||_______/ /__/     \__\        |__|     |_______|_______/       |__|     |__| \__| |_______|    |__|     "
echo ""

 status_msg () {
      printf ' \n\n \e[1;34m%-6s\e[m \n' "*** ${1} ***"
 }

 error_msg () {
      printf ' \n\n \e[1;31m%-6s\e[m \n' "*** ${1} ***"
 }

 msg () {
      printf ' \e[0m%-6s\e[m \n' " ${1} "
 }
make_workspace() {

     mkdir -p /tmp/corda
     if [[ ! -d $HOME/.cordapp_trial ]]
     then
         mkdir -p $HOME/.cordapp_trial/tmp          # service specific work... like writing configs before installing them
         mkdir -p $HOME/.cordapp_trial/hist         # track stuff... like when we first installed...
         mkdir -p $HOME/.cordapp_trial/corda        # working area for cordapp
         mkdir -p $HOME/.cordapp_trial/service      # working area for service
         mkdir -p $HOME/.cordapp_trial/ui           # working area for ui component
         mkdir -p $HOME/.cordapp_trial/archive      # keep copies of stuff across successive installations

         # leave a marker on the first install... (so we know when we're reinstalling)...
         echo $(date) > $HOME/.cordapp_trial/hist/firstinstall.info
     fi
 }

install_docker() {

     status_msg "installing docker..."
     curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
     sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"  > /dev/null    2>&1
     sudo apt-get update -qq -y
     sudo apt-get install docker-ce unzip -qq -y

     status_msg "configuring docker..."
     DOCKER_CONFIG="$HOME/.cordapp_trial/tmp/daemon.json"
     touch  ${DOCKER_CONFIG}
     echo "{"                                   >  ${DOCKER_CONFIG}
     echo "    \"log-driver\": \"json-file\","  >> ${DOCKER_CONFIG}
     echo "    \"log-opts\": {"                 >> ${DOCKER_CONFIG}
     echo "         \"max-size\": \"10m\","     >> ${DOCKER_CONFIG}
     echo "         \"max-file\": \"3\" "       >> ${DOCKER_CONFIG}
     echo "     }"                              >> ${DOCKER_CONFIG}
     echo "}"                                   >> ${DOCKER_CONFIG}
     sudo cp ${DOCKER_CONFIG} /etc/docker/daemon.json

     status_msg "restart docker service..."
     sudo systemctl restart docker.service

 }


# setup
NODE_CONFIG="$HOME/.cordapp_trial/corda/node.conf"
H2_PORT="10092"
CORDAPP_DOCKER_IMAGE_VERSION="v2.0"
SERVICE_DOCKER_IMAGE_VERSION="v1.0"
UI_DOCKER_IMAGE_VERSION="v1.0"

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --role)
    role="$2"
    shift # past argument
    shift # past value
    ;;
    --hostname)
    hostName="$2"
    shift # past argument
    shift # past value
    ;;
    --otk)
    oneTimeKey="$2"
    shift # past argument
    shift # past value
    ;;
    --country)
    country="$2"
    shift # past argument
    shift # past value
    ;;
    --locality)
    locality="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ "$role" == "" ]
then
    # TODO: list your roles here
    echo "Which KYC role would you like to deploy? (<roles>)"
    read role
fi

# TODO: confirm this is one of your roles
if [ "$role" != <role> -a "$role" != <role> -a "$role" != <role> -a "$role" != <role> ]
then
    echo "$role not recognized"
    exit 10
fi

if [ "$hostName" == "" ]
then
    echo "Enter the Azure Host Name for your Azure VM"
    read hostName
fi
if [ "$oneTimeKey" == "" ]
then
    echo "Enter a one time access key from Corda Testnet"
    read oneTimeKey
fi
if [ "$country" == "" ]
then
    echo "What country code will be on your X500 directory?"
    read country
fi
if [ "$locality" == "" ]
then
    echo "What locality will be on your X500 directory?"
    read locality
fi

echo ROLE           = "${role}"
echo HOST NAME      = "${hostName}"
echo OTK            = "${oneTimeKey}"
echo COUNTRY        = "${country}"
echo LOCALITY       = "${locality}"

# create local workspace if necessary
make_workspace

# cleanup the working area
rm -rf $HOME/.cordapp_trial/tmp/
mkdir -p $HOME/.cordapp_trial/tmp/
rm -rf $HOME/.cordapp_trial/corda/
mkdir -p $HOME/.cordapp_trial/corda/

# get new creds...
status_msg "Retrieving Testnet certificates"
TESTNET_CERTFILE="$HOME/.cordapp_trial/tmp/testnet_certs.zip"
curl -X POST "https://testnet.corda.network/api/user/node/generate/one-time-key/redeem/$oneTimeKey" -o ${TESTNET_CERTFILE} -H "Cache-Control: no-cache" -H "Content-Type: application/json" -H "Postman-Token: 54ce745c-ff8f-44d5-9430-da60ca310df1" -d "{
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

# quit & complain if you're having trouble getting to testnet...
TESTNET_RESULT=$?
if test "$TESTNET_RESULT" != "0"; then
    echo ""
    error_msg "Had an issue getting certs... please try again [ ERR MSG: $TESTNET_RESULT ]"
    exit
fi

# grab the certificates and scrape the downloaded node.conf so we can generate a proper node.conf
sudo apt install -yqq unzip
unzip -q ${TESTNET_CERTFILE} -d $HOME/.cordapp_trial/tmp/
mv $HOME/.cordapp_trial/tmp/certificates  $HOME/.cordapp_trial/corda
DOWNLOADED_NODE_CONFIG=$HOME/.cordapp_trial/tmp/node.conf

legalNameRegex="O=[a-zA-Z0-9[:space:]-]*,[[:space:]]L=[a-zA-Z[:space:]]*,[[:space:]]C=[A-Z]{2}"
testnetLegalNameRegex="OU=[a-zA-Z0-9[:space:]-]*,[[:space:]]O=[a-zA-Z0-9[:space:]-]*,[[:space:]]L=[a-zA-Z[:space:]]*,[[:space:]]C=[A-Z]{2}"
testnetLegalName=$(grep -o -E $testnetLegalNameRegex $DOWNLOADED_NODE_CONFIG)
if [ -z "$testnetLegalName" ]; then
    # if the legal name is empty somethings wrong...
    error_msg "ERR: INVALID LEGAL NAME [ $testnetLegalName ]... please check your Testnet account... "
    exit
fi

keyStoreRegex="\"?keyStorePassword\"?[[:space:]]:[[:space:]]\"[a-zA-Z0-9-]*\""
keyStorePasswordRegex="\"[a-zA-Z0-9-]*\"$"
testnetKeyStorePassword=$(grep -o -E $keyStoreRegex $DOWNLOADED_NODE_CONFIG | grep -o -E $keyStorePasswordRegex)

trustStoreRegex="\"?trustStorePassword\"?[[:space:]]:[[:space:]]\"[a-zA-Z0-9-]*\""
trustStorePasswordRegex="\"[a-zA-Z0-9-]*\"$"
testnetTrustStorePassword=$(grep -o -E $trustStoreRegex $DOWNLOADED_NODE_CONFIG | grep -o -E $trustStorePasswordRegex)

rpcAddress="localhost"

# write config files
GENERATED_NODE_CONFIG=$HOME/.cordapp_trial/corda/node.conf
echo "basedir = \"/tmp/corda\""                                        > $GENERATED_NODE_CONFIG
echo "compatibilityZoneURL = \"https://map.testnet.corda.network\""    >> $GENERATED_NODE_CONFIG
echo "devMode = false"                                                 >> $GENERATED_NODE_CONFIG
echo "emailAddress = \"austin.moothart@r3.com\""                       >> $GENERATED_NODE_CONFIG

# establish static port and allow remote login for troubleshooting
echo "h2Settings {"                                                    >> $GENERATED_NODE_CONFIG
echo "    address=\"0.0.0.0:$H2_PORT"\"                                >> $GENERATED_NODE_CONFIG
echo "}"                                                               >> $GENERATED_NODE_CONFIG

# set password (required for allowing remote logins)
echo "dataSourceProperties = {"                                        >> $GENERATED_NODE_CONFIG
echo "    dataSource.password=\"Cordacorda1!\" "                       >> $GENERATED_NODE_CONFIG
echo "}"                                                               >> $GENERATED_NODE_CONFIG

echo "rpcSettings = {"                                                 >> $GENERATED_NODE_CONFIG
echo "    address=\"0.0.0.0:10003\""                                   >> $GENERATED_NODE_CONFIG
echo "    adminAddress=\"${rpcAddress}:10103\""                        >> $GENERATED_NODE_CONFIG
echo "    standAloneBroker=false"                                      >> $GENERATED_NODE_CONFIG
echo "    useSsl=false"                                                >> $GENERATED_NODE_CONFIG
echo "}"                                                               >> $GENERATED_NODE_CONFIG
echo "rpcUsers=["                                                      >> $GENERATED_NODE_CONFIG
echo "    {"                                                           >> $GENERATED_NODE_CONFIG
#TODO replace with your rpc username and password
echo "        user=username"                                           >> $GENERATED_NODE_CONFIG
echo "        password=password123"                                    >> $GENERATED_NODE_CONFIG
echo "        permissions=["                                           >> $GENERATED_NODE_CONFIG
echo "            ALL"                                                 >> $GENERATED_NODE_CONFIG
echo "        ]"                                                       >> $GENERATED_NODE_CONFIG
echo "    }"                                                           >> $GENERATED_NODE_CONFIG
echo "]"                                                               >> $GENERATED_NODE_CONFIG
echo "sshd {"                                                          >> $GENERATED_NODE_CONFIG
echo "    port = 2222"                                                 >> $GENERATED_NODE_CONFIG
echo "}"                                                               >> $GENERATED_NODE_CONFIG
echo "myLegalName=\"${testnetLegalName}\""                             >> $GENERATED_NODE_CONFIG
echo "p2pAddress=\"${hostName}:10002\""                                >> $GENERATED_NODE_CONFIG
echo "webAddress=\"${hostName}:10004\""                                >> $GENERATED_NODE_CONFIG
echo "keyStorePassword=${testnetKeyStorePassword}"                     >> $GENERATED_NODE_CONFIG
echo "trustStorePassword=${testnetTrustStorePassword}"                 >> $GENERATED_NODE_CONFIG


# setup angular envrionment for ui based on role
rm -rf $HOME/.cordapp_trial/ui/
mkdir -p $HOME/.cordapp_trial/ui/

status_msg "generating ui config file"
webPort=-1
ANGULAR_CONFIG="$HOME/.cordapp_trial/ui/environment.trial.ts"
echo "export const environment = {"               >  $ANGULAR_CONFIG
echo "  production: false,"                       >> $ANGULAR_CONFIG
echo "  protocol:'http',"                         >> $ANGULAR_CONFIG
echo "  hostName:'$hostName',"                    >> $ANGULAR_CONFIG

# TODO: repalce with the configuration of your UI application
 case $role in
    customer)
        webPort=8080
        echo "  customerPort:'$webPort',"          >> $ANGULAR_CONFIG
        echo "  bankPort:'',"                      >> $ANGULAR_CONFIG
        echo "  attesterPort:'',"                  >> $ANGULAR_CONFIG
        echo "  datastorePort:''"                  >> $ANGULAR_CONFIG
        ;;
    datastore)
        webPort=8181
        echo "  customerPort:'',"                  >> $ANGULAR_CONFIG
        echo "  bankPort:'',"                      >> $ANGULAR_CONFIG
        echo "  attesterPort:'',"                  >> $ANGULAR_CONFIG
        echo "  datastorePort:'$webPort'"          >> $ANGULAR_CONFIG
        ;;
    bank)
        webPort=8282
        echo "  customerPort:'',"                  >> $ANGULAR_CONFIG
        echo "  bankPort:'$webPort',"              >> $ANGULAR_CONFIG
        echo "  attesterPort:'',"                  >> $ANGULAR_CONFIG
        echo "  datastorePort:''"                  >> $ANGULAR_CONFIG
        ;;
    attester)
        webPort=8383
        echo "  customerPort:'',"                  >> $ANGULAR_CONFIG
        echo "  bankPort:'',"                      >> $ANGULAR_CONFIG
        echo "  attesterPort:'$webPort',"          >> $ANGULAR_CONFIG
        echo "  datastorePort:''"                  >> $ANGULAR_CONFIG

        ;;
    *)
        webPort=-1
        ;;
  esac

# and don't forget the closing bracket...
echo "};"                                         >> $ANGULAR_CONFIG


# setup properties for springboot web services
rm -rf $HOME/.cordapp_trial/service/
mkdir -p $HOME/.cordapp_trial/service/

status_msg "generating springboot config file"
SPRINGBOOT_CONFIG="$HOME/.cordapp_trial/service/application.properties"
touch ${SPRINGBOOT_CONFIG}
#TODO: replace this config with your own Springboot config
echo "# ***generated: spring application properties"                                 >  $SPRINGBOOT_CONFIG
echo "spring.mvc.view.prefix: /"                                                     >> $SPRINGBOOT_CONFIG
echo "spring.mvc.view.suffix: .jsp"                                                  >> $SPRINGBOOT_CONFIG
echo "spring.jpa.hibernate.ddl-auto=none"                                            >> $SPRINGBOOT_CONFIG
echo "spring.jpa.show-sql=true"                                                      >> $SPRINGBOOT_CONFIG
echo "spring.messages.basename=validation"                                           >> $SPRINGBOOT_CONFIG
echo "spring.datasource.url=jdbc:mysql://localhost:3306/db$role"                     >> $SPRINGBOOT_CONFIG
echo "spring.datasource.username=root"                                               >> $SPRINGBOOT_CONFIG
echo "spring.datasource.password=root"                                               >> $SPRINGBOOT_CONFIG
echo "spring.datasource.driver-class-name=com.mysql.jdbc.Driver"                     >> $SPRINGBOOT_CONFIG
echo "spring.jpa.properties.hibernate.dialect = org.hibernate.dialect.MySQLDialect"  >> $SPRINGBOOT_CONFIG
echo "spring.output.ansi.enabled=ALWAYS"                                             >> $SPRINGBOOT_CONFIG
echo "server.port=$webPort"                                                          >> $SPRINGBOOT_CONFIG
echo "loggging.file=$role/logs/application.log"                                      >> $SPRINGBOOT_CONFIG
echo "http=http://"                                                                  >> $SPRINGBOOT_CONFIG
echo "cordaHostName=$hostName"                                                       >> $SPRINGBOOT_CONFIG
echo "cordaPort=10004"                                                               >> $SPRINGBOOT_CONFIG

#TODO: add additional config depending on what customization each role has
 case $role in
    customer)
        echo "actionDataAccessReq=/api/customer/actionDataAccessReq"             >> $SPRINGBOOT_CONFIG
        echo "attesterList=/api/attesterList"                                    >> $SPRINGBOOT_CONFIG
        echo "addNewDataField=/api/atomic/add/field"                             >> $SPRINGBOOT_CONFIG
        echo "defaultAttestation=api/customer/defaultAttestation"                >> $SPRINGBOOT_CONFIG
        echo "distributionList=/api/customer/distributionList"                   >> $SPRINGBOOT_CONFIG
        echo "downloadDocument=/api/customer/download/documents"                 >> $SPRINGBOOT_CONFIG
        echo "kycCustomerProfile=/api/customer/profile"                          >> $SPRINGBOOT_CONFIG
        echo "kycCustomerTransactions=/api/transactions"                         >> $SPRINGBOOT_CONFIG
        echo "kycUpdateCustomerProfile=/api/customer/updateField"                >> $SPRINGBOOT_CONFIG
        echo "headlineInfo=/api/customer/profile/headlineInfo"                   >> $SPRINGBOOT_CONFIG
        echo "customerList=/api/customerList"                                    >> $SPRINGBOOT_CONFIG
        ;;
    datastore)
        echo "attesterList=/api/attesterList"                                    >> $SPRINGBOOT_CONFIG
        echo "datastoreList=/api/datastoreList"                                  >> $SPRINGBOOT_CONFIG
        echo "distributionList=/api/datastore/distributionList"                  >> $SPRINGBOOT_CONFIG
        echo "kycDatastoreTransactions=/api/transactions"                        >> $SPRINGBOOT_CONFIG
        echo "kycCorporatesListOnDS=/api/datastore/kycCorporatesListOnDS"        >> $SPRINGBOOT_CONFIG
        ;;
    bank)
        echo "spring.datasource.data=classpath*:bank1_data.sql"                  >> $SPRINGBOOT_CONFIG
        echo "attesterList=/api/attesterList"                                    >> $SPRINGBOOT_CONFIG
        echo "bankHeaderInfo=/api/bank/bankHeaderInfo"                           >> $SPRINGBOOT_CONFIG
        echo "bankList=/api/bankList"                                            >> $SPRINGBOOT_CONFIG
        echo "raiseDataAccessReq=/api/bank/raiseDataAccessReq"                   >> $SPRINGBOOT_CONFIG
        echo "searchCustomer=/api/bank/searchCustomer"                           >> $SPRINGBOOT_CONFIG
        echo "viewCustomerProfile=/api/bank/viewCustomerProfile"                 >> $SPRINGBOOT_CONFIG
        echo "customerDataRequests=/api/bank/customerDataRequests"               >> $SPRINGBOOT_CONFIG
        echo "downloadDocument=/api/bank/download/documents"                     >> $SPRINGBOOT_CONFIG
        echo "kycBankTransactions=/api/transactions"                             >> $SPRINGBOOT_CONFIG
        ;;
    attester)
        echo "transaction=/api/transactions"                                     >> $SPRINGBOOT_CONFIG
        echo "attesterList=/api/attesterList"                                    >> $SPRINGBOOT_CONFIG
        echo "attestationHeaderInfo=/api/attester/attestationHeaderInfo"         >> $SPRINGBOOT_CONFIG
        echo "attestationRequestsList=/api/attester/attestationRequestsList"     >> $SPRINGBOOT_CONFIG
        echo "attestationSeed=/api/attester/action/attest"                       >> $SPRINGBOOT_CONFIG
        echo "attestedFields=/api/attester/attestationFields"                    >> $SPRINGBOOT_CONFIG
        echo "pendingAttestationFields=/api/attester/pendingAttestationFields"   >> $SPRINGBOOT_CONFIG
        echo "attestationRevoke=/api/attester/action/revoke"                     >> $SPRINGBOOT_CONFIG
        echo "downloadDocument=/api/attester/download/documents"                 >> $SPRINGBOOT_CONFIG
        echo "bankList=/api/bankList"                                            >> $SPRINGBOOT_CONFIG
        echo "customerList=/api/customerList"                                    >> $SPRINGBOOT_CONFIG
        echo "datastoreList=/api/datastoreList"                                  >> $SPRINGBOOT_CONFIG
        ;;
    *)
        echo "unknown role"
        port=-1
        ;;
  esac

echo "#deploymentEnv=test"                                                       >> $SPRINGBOOT_CONFIG
echo "deploymentEnv=local"                                                       >> $SPRINGBOOT_CONFIG
status_msg "springboot config file complete... "

# if docker's not there, then install it
 if [[ ! $(which docker) && ! $(docker --version) ]]; then
     install_docker
 fi

# login to remote image repo 
status_msg "downloading cordapp containers..."
sudo docker login --username cordappTrials --password sjad0sMuKkbR5XDgZ7jmcmo3V9=pxMNR cordapptrials.azurecr.io

#run the docker image for ui, services and cordapp
status_msg "running cordapp container"
sudo docker pull cordapptrials.azurecr.io/$role-cordapp:$CORDAPP_DOCKER_IMAGE_VERSION
sudo docker run -dti                                                 \
                --name ${role}_cordapp                               \
                -p $H2_PORT:$H2_PORT  -p 10002:10002 -p 10003:10003  \
                -p 10004:10004 -p 10103:10103 -p 1416:1416           \
                -v $HOME/.cordapp_trial/corda:/tmp/corda/            \
                cordapptrials.azurecr.io/$role-cordapp:$CORDAPP_DOCKER_IMAGE_VERSION

status_msg "starting service container"
sudo docker pull cordapptrials.azurecr.io/$role-services:$SERVICE_DOCKER_IMAGE_VERSION
sudo docker run -dti                                                 \
                --name ${role}_service                               \
                -p 8080:8080 -p 8181:8181 -p 8282:8282 -p 8383:8383  \
                -v $HOME/.cordapp_trial/service:/tmp/service/        \
                cordapptrials.azurecr.io/$role-services:$SERVICE_DOCKER_IMAGE_VERSION

status_msg "starting ui container"
sudo docker pull cordapptrials.azurecr.io/trial-ui:$UI_DOCKER_IMAGE_VERSION
sudo docker run -dti                                 \
                --name ${role}_ui                    \
                -p 80:4200                           \
                -v $HOME/.cordapp_trial/ui:/tmp/ui/  \
                cordapptrials.azurecr.io/trial-ui:$UI_DOCKER_IMAGE_VERSION

echo "All containers have been started. Check 'sudo docker ps -a' to check their status"
sudo docker ps
