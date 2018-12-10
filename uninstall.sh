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
esac
done

if [ "$role" == "" ]
then
    echo "Which KYC role would you like to uninstall? (attester/bank/customer/datastore)"
    read role
fi

echo ROLE = "${role}"

if [ "$role" != "attester" -a "$role" != "datastore" -a "$role" != "bank" -a "$role" != "customer" ]
then
    echo "$role not recognized"
    exit 10
fi

sudo docker stop ${role}_cordapp ${role}_service ${role}_ui
sudo docker rm ${role}_cordapp ${role}_service ${role}_ui