#!/bin/bash

cd /vagrant/settings

for SETTINGSFILE in settings_all settings_auth_local settings_local
do
    while read line
    do
        eval export $line
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

/home/vagrant/www/bin/python /vagrant/manage.py createdb --noinput --nodata

