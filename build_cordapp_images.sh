#!/usr/bin/env bash
VERSION=v1.0

# TODO: replace with access to a Docker container registry of your choice
# R3 has historically used the Azure Container registry: https://azure.microsoft.com/en-us/services/container-registry/
docker login --username [your user] --password [your password] [your domain].azurecr.io

# Tag and upload a copy of each possible image. In this example there is only a single role and 1 base image.
./gradlew clean deployNodes
docker build -t base-corda -f ./Dockerfile .

# TODO: replace with the correct name for the service image
docker build -t trial-cordapp -f ./Dockerfile .
docker tag trial-cordapp cordapptrials.azurecr.io/trial-cordapp:$VERSION
docker push cordapptrials.azurecr.io/trial-cordapp:$VERSION