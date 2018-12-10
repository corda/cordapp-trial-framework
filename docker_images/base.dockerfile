# docker build -t base-corda -f ./Dockerfile .
FROM openjdk:8u171-jre-alpine

ARG BUILDTIME_CORDA_VERSION=3.2-corda
ARG BUILDTIME_CORDA_HOME=/opt/corda
ARG BUILDTIME_NODEPAD_PORT="1416"

ENV CORDA_VERSION=${BUILDTIME_CORDA_VERSION}
ENV CORDA_HOME=${BUILDTIME_CORDA_HOME}
ENV NODEPAD_PORT=${BUILDTIME_NODEPAD_PORT}

# Working directory for Corda
WORKDIR /opt/corda

# Set image labels
LABEL net.corda.version=${CORDA_VERSION} \
      vendor="R3" \
      maintainer=<austin.moothart@r3.com>

# setup alpine
RUN apk upgrade --update && \
    apk add --update --no-cache bash iputils openrc  && \
    apk add openssh && \
    rm -rf /var/cache/apk/* && \
    addgroup corda && \
    adduser -G corda -D -s /bin/bash corda && \
    mkdir -p /opt/corda/cordapps && \
    mkdir -p /opt/corda/logs

# download corda jars
ADD --chown=corda:corda https://dl.bintray.com/r3/corda/net/corda/corda/${CORDA_VERSION}/corda-${CORDA_VERSION}.jar /opt/corda/corda.jar
ADD --chown=corda:corda https://dl.bintray.com/r3/corda/net/corda/corda-webserver/${CORDA_VERSION}/corda-webserver-${CORDA_VERSION}.jar /opt/corda/corda-webserver.jar
ADD build/nodes/R3-KYC-Bno/cordapps/bno-0.1.jar /opt/corda/cordapps/
ADD lib/membership-service-0.1.jar /opt/corda/cordapps/
ADD lib/membership-service-contracts-and-states-0.1.jar /opt/corda/cordapps/
ADD lib/nodepad.jar /opt/corda/

EXPOSE ${NODEPAD_PORT}

# startup script to copy generated node.conf and certs
COPY deployment/docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh

RUN chmod 755 /opt/corda/corda.jar
RUN chmod 755 /opt/corda/corda-webserver.jar