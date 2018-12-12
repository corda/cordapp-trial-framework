# build
# docker build -t trial-cordapp -f ./Dockerfile .
# test
# docker run -ti --name <role>_cordapp -p 10002:10002 -p 10003:10003 -p 10004:10004 -p 10103:10103 -p 1416:1416 -v /tmp/corda/:/tmp/corda/ trial-cordapp
# debug
# docker exec -it <role>_cordapp bash
# Release to ACR (Azure Container Registry)
# docker tag trial-cordapp cordapptrials.azurecr.io/trial-cordapp:<version>
# docker push cordapptrials.azurecr.io/trial-cordapp:<version>
FROM base-corda:latest

ARG BUILDTIME_P2P_PORT="10002"
ARG BUILDTIME_RPC_PORT="10002"
ARG BUILDTIME_WEB_PORT="10004"
ARG BUILDTIME_JAVA_OPTIONS="-Xmx2048m -jar"

ENV P2P_PORT=${BUILDTIME_P2P_PORT}
ENV RPC_PORT=${BUILDTIME_RPC_PORT}
ENV WEB_PORT=${BUILDTIME_WEB_PORT}
ENV JAVA_OPTIONS=${BUILDTIME_JAVA_OPTIONS}

ADD build/nodes/<role>/cordapps/role-0.1.jar /opt/corda/cordapps/
ADD build/nodes/<role>/cordapps/base-0.1.jar /opt/corda/cordapps/

EXPOSE ${P2P_PORT}
EXPOSE ${RPC_PORT}
EXPOSE ${WEB_PORT}

WORKDIR /opt/corda
ENV HOME=/opt/corda

RUN chown -R corda:corda /opt/corda

USER corda

ENTRYPOINT ["docker-entrypoint.sh"]