#!/usr/bin/env bash

# add springboot config 
cp /tmp/service/application.properties /opt/websvc/BOOT-INF/classes/application.properties

# start 
service mysql restart; service mysql status
java -Xmx2048m -cp "/opt/websvc:BOOT-INF/lib" org.springframework.boot.loader.JarLauncher
# enable for remote debugging
#java -Xmx2048m -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005 -jar /opt/websvc/customer-0.0.1-SNAPSHOT.jar