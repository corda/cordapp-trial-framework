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
	# TODO: list your roles here
    echo "Which role would you like to uninstall? (<roles>)"
    read role
fi

echo ROLE = "${role}"

# TODO: confirm this is one of your roles
if [ "$role" != <role> -a "$role" != <role> -a "$role" != <role> -a "$role" != <role> ]
then
    echo "$role not recognized"
    exit 10
fi

sudo docker stop ${role}_cordapp ${role}_service ${role}_ui
sudo docker rm ${role}_cordapp ${role}_service ${role}_ui