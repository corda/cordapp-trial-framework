#!/usr/bin/env bash
role=bno
Role="R3-KYC-${role^}"

#cordapp
echo "=== Building KYC Cordapp ==="
cd ~/app/leia-ii-cordapp/
~/app/leia-ii-cordapp/gradlew clean deployNodes

#cordapp systemctl service
echo "=== Establishing cordapp service ==="
sudo chown -R corda:corda /opt/$role
cd /opt/$role
sudo cp ~/app/leia-ii-cordapp/build/nodes/$Role/cordapps/* /opt/$role/cordapps/
sudo cp ~/app/leia-ii-cordapp/lib/membership-service-0.1.jar /opt/$role/cordapps/
sudo cp ~/app/leia-ii-cordapp/lib/membership-service-contracts-and-states-0.1.jar /opt/$role/cordapps/
sudo chown -R corda:corda /opt/$role/

#start services
echo "=== Starting all KYC services ==="
sudo systemctl daemon-reload
sudo systemctl enable --now $role
sudo systemctl enable --now $role-webserver
sudo systemctl restart $role
sudo systemctl restart $role-webserver