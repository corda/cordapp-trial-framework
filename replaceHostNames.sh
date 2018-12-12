#!/usr/bin/env bash

replaceHostnameInFile () {
    local fileName=$1
    local newHostName=$2

    echo "Replacing in file $fileName"

    sed -i "s/#replace_with_your_hostname#/$newHostName/g" $1
}

replaceHostnameInFileIfFileExists () {
    local fileName=$1
    local newHostName=$2

    echo "Checking if this file exists $fileName"
    if [ -e $fileName ]
    then
        replaceHostnameInFile $fileName $newHostName
    else
        echo "File does not exist, continuing"
    fi

}

if [ $# -eq 0 ] || [ $# -eq 1 ]
  then
    echo "Not enough arguments supplied"
    exit 1
fi

if [ -z "$1" ] || [ -z "$2" ]
  then
    echo "No argument supplied"
    exit 1
fi

role=$1
hostname=$2

echo "Replacing host names for role $role to $hostname"

cd ~/app/

# TODO replace with correct path to your configuration
replaceHostnameInFileIfFileExists "./$role/src/main/resources/node_configuration/azure.node.conf" $hostname
replaceHostnameInFileIfFileExists "./$role/src/main/resources/application.properties" $hostname

if [ $# -eq 3 ]
  then
    uiFlavour=$3
    # TODO replace with correct path to your configuration
    replaceHostnameInFileIfFileExists "./src/environments/environment.$uiFlavour.ts" $hostname
fi








