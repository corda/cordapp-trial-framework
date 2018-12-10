#!/usr/bin/env bash

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
    --alternativename)
    alternativeName="$2"
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
    echo "Which KYC role would you like to bootstrap? (attester/bank/customer/datastore)"
    read role
fi
if [ "$hostName" == "" ]
then
    echo "What host name is your cordapp hosted at?"
    read hostName
fi
if [ "$alternativeName" == "" ]
then
    echo "Which alternative name on the network do you want to use?"
    read alternativeName
fi
echo ROLE               = "${role}"
echo HOST NAME          = "${hostName}"
echo ALTERNATIVE NAME   = "${alternativeName}"

# bank and customer bootstrap
curl -X GET http://${hostName}:10004/api/bootstrap

printf "\n"
echo "Requesting membership for role $role, alternative name $alternativeName, on url $hostName"
curl -X POST http://${hostName}:10004/api/membership/request -H "Cache-Control: no-cache" -H 'Content-Type: application/json' -d "{\"displayedName\":\"$alternativeName\",\"role\":\"$role\"}"

# customer specific boostrap
if [ "$role" = "customer" ]
then
    echo "Waiting for membership confirmation, please wait...."
    # wait for membership to propagate across the business network
    sleep 15

    printf "\n"

    filepath="/tmp/corda/customerData.json"
    curl -X POST \
      http://${hostName}:10004/api/customer/uploadCustomer \
      -H 'Content-Type: application/json' \
      --data "@${filepath}"

    printf "\n"

    curl -X POST http://${hostName}:10004/api/customer/defaultAttestation
fi