#!/bin/bash

# Default to localhost and parameterized for future execution on cloud VMs
if [[ $# -eq 0 ]]
    then
        host="localhost"
    else
        host=$1
fi

function assert() {
    if [[ $1 == $2 ]]
        then
            echo -e "Test \e[32mpassed\e[39m."
        else
            echo -e "Test \e[31mfailed\e[39m."
    fi
}

# example location of dummy JSON files for RESTful calls
cd ../../sample_data


echo "Requesting and activating memberships..."

# Test membership activation for ALL roles. This script can be copy pasted for all roles within the cordapp
actual=$(curl -X POST -H "Content-Type: application/json" -d @TestRequestMembershipRole.json http://$host:8081/api-path/request-membership 2>/dev/null)
echo $actual
expected="{\"msg\":\"Membership requested for <role> (<role>).\"}"
assert "$actual" "$expected"
sleep 5s
actual=$(curl -X GET -H "Content-Type: application/json" http://$host:8081/api-path/get-membership 2>/dev/null)
expected="{\"bno\":\"O=BNO, L=New York, C=US\",\"role\":\<role>\",\"displayName\":\"<display name>\",\"status\":\"ACTIVE\"}"
assert "$actual" "$expected"

# Step 1 of the trial use case
echo "Creating record..."
actual=$(curl -X POST -H "Content-Type: application/json" -d @CreateTrialRecord.json http://$host:8081/api-path/create-trial-record 2>/dev/null)
echo $actual
expected="{\"msg\":\"Trial record for id 1 was added to the ledger.\"}"
assert "$actual" "$expected"
actual=$(curl -X GET -H "Content-Type: application/json" http://$host:8081/api-path/get-trial-record-state/1 2>/dev/null)
expected="{\"recordId\":\"1\",\"counterpartyA\":\"O=BankOfBreakfastTea, L=London, C=GB\",\counterpartyB\":\"O=BankOfBaguettes, L=Paris, C=FR\",\"fieldA\":\Sample field\",\"owner\":\"The Owner\",\"pricePaid\":\"1000\"}"
assert "$actual" "$expected"
actual=$(curl -X GET -H "Content-Type: application/json" http://$host:8081/api-path/get-trial-record-states/unconsumed 2>/dev/null | tr -d [])
assert "$actual" "$expected"
echo

# Repeat the above curl commands for all relevant steps that will be follows in the trial.