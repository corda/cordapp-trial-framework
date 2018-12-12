#!/usr/bin/env bash
# TODO: list your roles here
echo "Which role would you like to uninstall? (<roles>)"
read role

# TODO: confirm this is one of your roles
if [ "$role" != <role> -a "$role" != <role> -a "$role" != <role> -a "$role" != <role> ]
then
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

