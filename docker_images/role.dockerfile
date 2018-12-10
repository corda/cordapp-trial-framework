# build
# docker build -t kyc-customer-cordapp -f ./customer/Dockerfile .
# test
# docker run -ti --name customer_cordapp -p 10002:10002 -p 10003:10003 -p 10004:10004 -p 10103:10103 -p 1416:1416 -v /tmp/corda/:/tmp/corda/ kyc-customer-cordapp
# debug
# docker exec -it customer_cordapp bash
# Release to ACR (Azure Container Registry)
# docker tag kyc-customer-cordapp cordapptrials.azurecr.io/kyc-customer-cordapp:<version>
# docker push cordapptrials.azurecr.io/kyc-customer-cordapp:<version>
FROM base-corda:latest

ARG BUILDTIME_P2P_PORT="10002"
ARG BUILDTIME_RPC_PORT="10002"
ARG BUILDTIME_WEB_PORT="10004"
ARG BUILDTIME_JAVA_OPTIONS="-Xmx2048m -jar"

ENV P2P_PORT=${BUILDTIME_P2P_PORT}
ENV RPC_PORT=${BUILDTIME_RPC_PORT}
ENV WEB_PORT=${BUILDTIME_WEB_PORT}
ENV JAVA_OPTIONS=${BUILDTIME_JAVA_OPTIONS}

ADD build/nodes/R3-Demo-Customer/cordapps/customer-0.1.jar /opt/corda/cordapps/
ADD build/nodes/R3-Demo-Customer/cordapps/base-0.1.jar /opt/corda/cordapps/

EXPOSE ${P2P_PORT}
EXPOSE ${RPC_PORT}
EXPOSE ${WEB_PORT}

WORKDIR /opt/corda
ENV HOME=/opt/corda

RUN chown -R corda:corda /opt/corda

USER corda

ENTRYPOINT ["docker-entrypoint.sh"]