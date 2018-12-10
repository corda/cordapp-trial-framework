#!/usr/bin/env bash
echo "Which Leia role would you like to uninstall? (attester/bank/customer/datastore/bno)"
read role

Role="${role^}"
if [ "$role" = "attester" -o "$role" = "datastore" -o "$role" = "bno" ]
then
    Role="R3-KYC-${role^}"
elif [ "$role" = "bank" -o "$role" = "customer" ]
then
    Role="R3-Demo-${role^}"
else
    echo "$role not recognized"
    exit 10
fi

cd ~
sudo rm -rf ~/app/
sudo rm -rf /opt/$role*
sudo rm /etc/systemd/system/$role*
sudo systemctl disable $role
sudo systemctl stop $role
sudo systemctl disable $role-webserver
sudo systemctl stop $role-webserver
sudo systemctl daemon-reload

