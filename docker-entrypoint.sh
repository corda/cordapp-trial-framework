#!/usr/bin/env bash
if [ ! -d /opt/corda/certificates/ ]; then
    printf "loading fresh certs"
    printf "\n"
    cp -r /tmp/corda/certificates/ /opt/corda/
fi
if [ ! -f /opt/corda/node.conf ]; then
    printf "loading node configuration"
    printf "\n"
    cp /tmp/corda/node.conf /opt/corda/
fi
chown -R corda:corda /opt/corda
nohup java -Xmx1024m -jar /opt/corda/corda-webserver.jar &
java -Xmx2048m -jar /opt/corda/corda.jar