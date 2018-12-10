#!/usr/bin/env bash
VERSION=v1.0

//TODO: replace with access to a Docker container registry of your choice
//R3 has historically used the Azure Container registry: https://azure.microsoft.com/en-us/services/container-registry/
docker login --username [your user] --password [your password] [your domain].azurecr.io

//Tag and upload a copy of each possible image. In this example there were 4 roles and 1 base image.
./gradlew clean deployNodes
docker build -t base-corda -f ./Dockerfile .

docker build -t kyc-attester-cordapp -f ./attester/Dockerfile .
docker tag kyc-attester-cordapp cordapptrials.azurecr.io/kyc-attester-cordapp:$VERSION
docker push cordapptrials.azurecr.io/kyc-attester-cordapp:$VERSION

docker build -t kyc-bank-cordapp -f ./bank/Dockerfile .
docker tag kyc-bank-cordapp cordapptrials.azurecr.io/kyc-bank-cordapp:$VERSION
docker push cordapptrials.azurecr.io/kyc-bank-cordapp:$VERSION

docker build -t kyc-customer-cordapp -f ./customer/Dockerfile .
docker tag kyc-customer-cordapp cordapptrials.azurecr.io/kyc-customer-cordapp:$VERSION
docker push cordapptrials.azurecr.io/kyc-customer-cordapp:$VERSION

docker build -t kyc-datastore-cordapp -f ./datastore/Dockerfile .
docker tag kyc-datastore-cordapp cordapptrials.azurecr.io/kyc-datastore-cordapp:$VERSION
docker push cordapptrials.azurecr.io/kyc-datastore-cordapp:$VERSION