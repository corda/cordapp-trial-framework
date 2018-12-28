#!/usr/bin/env bash
# The version of your docker image that will be bbuilt
VERSION=v1.0

./buildservices.sh
# TODO: replace with the correct name for the service image
docker build -f services.dockerfile -t trial-services:$VERSION  --build-arg BUILDTIME_ROLE=<trial role> .
docker tag trial-services:$VERSION cordapptrials.azurecr.io/trial-services:$VERSION
docker push cordapptrials.azurecr.io/trial-services:$VERSION