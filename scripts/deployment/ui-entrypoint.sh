#!/usr/bin/env bash

# copy environment config from host machine file system
cp /tmp/ui/environment.trial.ts /root/ui/src/environments/environment.trial.ts

# build 
cd /root/ui
echo "building from: $(pwd) "
ng build -c=trial
cd /root/ui/dist; echo "$(pwd)"; ls -la 
http-server -p 4200