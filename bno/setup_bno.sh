#!/usr/bin/env bash
echo "What bitbucket username will be used?"
read username

#cordapp. The BNO, not being client facing, shouldn't need the services/UI
echo "=== Installing KYC BNO Cordapp ==="
mkdir app
cd ~/app
git clone "https://$username@bitbucket.org/R3-CEV/leia-ii-cordapp.git"
cd ~/app/leia-ii-cordapp
sudo apt-get update
sudo apt-get install -y openjdk-8-jdk
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/; export PATH=$PATH:/usr/lib/jvm/java-8-openjdk-amd64/bin
java -version

echo "What branch do you want to checkout?"
read branchname
git checkout $branchname
sudo adduser --system --no-create-home --group corda