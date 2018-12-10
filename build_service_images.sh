#!/usr/bin/env bash
VERSION=v1.0

./buildservices.sh
docker build -f leia-ii-services.dockerfile -t kyc-attester-services:$VERSION  --build-arg BUILDTIME_ROLE=attester .
docker tag kyc-attester-services:$VERSION cordapptrials.azurecr.io/kyc-attester-services:$VERSION
docker push cordapptrials.azurecr.io/kyc-attester-services:$VERSION

docker build -f leia-ii-services.dockerfile -t kyc-bank-services:$VERSION  --build-arg BUILDTIME_ROLE=bank .
docker tag kyc-bank-services:$VERSION cordapptrials.azurecr.io/kyc-bank-services:$VERSION
docker push cordapptrials.azurecr.io/kyc-bank-services:$VERSION

docker build -f leia-ii-services.dockerfile -t kyc-customer-services:$VERSION  --build-arg BUILDTIME_ROLE=customer .
docker tag kyc-customer-services:$VERSION cordapptrials.azurecr.io/kyc-customer-services:$VERSION
docker push cordapptrials.azurecr.io/kyc-customer-services:$VERSION

docker build -f leia-ii-services.dockerfile -t kyc-datastore-services:$VERSION  --build-arg BUILDTIME_ROLE=datastore .
docker tag kyc-datastore-services:$VERSION cordapptrials.azurecr.io/kyc-datastore-services:$VERSION
docker push cordapptrials.azurecr.io/kyc-datastore-services:$VERSION
