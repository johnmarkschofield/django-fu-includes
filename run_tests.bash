#!/bin/bash

set -e

cd /vagrant/hfu_settings

for SETTINGSFILE in settings_all settings_auth_test settings_test
do
    echo "Loading settings from $SETTINGSFILE"
    while read line
    do
        eval export $line
    done < $SETTINGSFILE
done


rm -rf /home/vagrant/testing
mkdir -p /home/vagrant/testing
cd /home/vagrant/testing

# Warm up the server
sleep 5
curl -o /dev/null http://$HOST
wget -e robots=off --recursive -N --page-requisites \
    --span-hosts -H -Ds'amazonaws.com,$HOST' --no-remove-listing  \
    --level=inf --no-directories --save-headers --tries 1 https://$HOST
