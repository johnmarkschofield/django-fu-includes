#!/bin/bash

cd /vagrant/settings

for SETTINGSFILE in settings_all settings_auth_local settings_local
do
    while read line
    do
        eval export $line
    done < SETTINGSFILE
done

cd /vagrant
source /home/vagrant/www/bin/activate
foreman start
