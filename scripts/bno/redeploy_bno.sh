#!/usr/bin/env bash
#TODO: replace with your application directory
APP_HOME="~/app/<your app>"
role=bno

#cordapp
echo "=== Building KYC Cordapp ==="
cd $APP_HOME
$APP_HOME/gradlew clean deployNodes

#cordapp systemctl service
echo "=== Establishing cordapp service ==="
sudo chown -R corda:corda /opt/$role
cd /opt/$role
sudo cp $APP_HOME/build/nodes/$role/cordapps/* /opt/$role/cordapps/
sudo cp $APP_HOME/lib/membership-service-0.1.jar /opt/$role/cordapps/
sudo cp $APP_HOME/lib/membership-service-contracts-and-states-0.1.jar /opt/$role/cordapps/
sudo chown -R corda:corda /opt/$role/

#start services
echo "=== Starting all KYC services ==="
sudo systemctl daemon-reload
sudo systemctl enable --now $role
sudo systemctl enable --now $role-webserver
sudo systemctl restart $role
sudo systemctl restart $role-webserver