# build
# docker build -f leia-ii-services.dockerfile -t kyc-attester-services:<version>  --build-arg BUILDTIME_ROLE=attester .
# test
# docker run -it --name attester_services -p 8383:8383 -v /tmp/service/:/tmp/service/ kyc-attester-services:<version> /bin/bash
# troubleshooting
# docker run -it --name attester_services -p 8383:8383 -p 5005:5005 -v /tmp/service/:/tmp/service/ kyc-attester-services:<version> /bin/bash
# Release to ACR (Azure Container Registry)
# docker tag kyc-attester-services:<version> cordapptrials.azurecr.io/kyc-attester-services:<version>
# docker push cordapptrials.azurecr.io/kyc-attester-services:<version>

FROM ubuntu:18.04

# roles: attester; customer; bank; datastore
# run buildservices.sh first, then build the container... it'll grab the right jar based on the provided role
ARG BUILDTIME_ROLE=attester 

# setup for unattended install
ENV DEBIAN_FRONTEND=noninteractive

# grab the repo and install java, mysql 8 and initialize the database
WORKDIR /tmp
ADD  ./sql/init.sql .
RUN  apt-get update && apt-get install -y lsb-release wget gnupg && \ 
     echo "mysql-community-server mysql-community-server/root-pass password root" | debconf-set-selections && \
     echo "mysql-community-server mysql-community-server/re-root-pass password root" | debconf-set-selections && \
     wget https://repo.mysql.com//mysql-apt-config_0.8.10-1_all.deb && dpkg -i mysql-apt-config_0.8.10-1_all.deb && \
     apt-get update && \ 
     apt-get install -y mysql-server

# make sure the db is accessible from outside localhost
RUN  service mysql restart && \
      mysql -u root -proot < init.sql && \
      mysql -u root -proot -e 'ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY "root";' && \
      mysql -u root -proot -e 'use mysql; update user set host="%" where user="root" and host="localhost"; flush privileges;' && \
      mysql -u root -proot -e "show databases;" 

# install jdk 1.8.x ( / webserver)
RUN apt-get install -y openjdk-8-jdk 
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
ENV PATH=$PATH:/usr/lib/jvm/java-8-openjdk-amd64/bin

# web server - ports: bank=8282; attester=8383; customer=8080; datastore=8181
EXPOSE 8080
EXPOSE 8181
EXPOSE 8282
EXPOSE 8383
# debug port for troubleshooting
EXPOSE 5005

WORKDIR /opt/websvc
ADD ./${BUILDTIME_ROLE}/build/libs/${BUILDTIME_ROLE}-0.0.1-SNAPSHOT.jar .
RUN jar -xvf ${BUILDTIME_ROLE}-0.0.1-SNAPSHOT.jar && rm /opt/websvc/${BUILDTIME_ROLE}-0.0.1-SNAPSHOT.jar

# get the updated application properties before starting up the app as an exploded jar
COPY  deployment/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
