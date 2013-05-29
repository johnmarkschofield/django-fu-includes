#!/bin/bash

cd /vagrant/hfu_settings

for SETTINGSFILE in settings_all settings_auth_local settings_local
do
    echo "Loading settings from $SETTINGSFILE"
    while read line
    do
        eval export $line
        echo eval export $line
    done < $SETTINGSFILE
done

cd /vagrant

source /home/vagrant/www/bin/activate

psql -U postgres -l | grep -q www
if [ $? -eq 0 ]; then
    # DB exists
    psql -U postgres -c "drop database www;"
fi

psql -U postgres -c "create database www;"

pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d www /vagrant/prod.dump
