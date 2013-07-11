#!/bin/bash

cd /vagrant/hfu_settings

if [ "$1" =  "prod" ]; then
    for SETTINGSFILE in settings_all settings_auth_prod settings_prod
    do
        echo "Loading settings from $SETTINGSFILE"
        while read line
        do
            eval export $line
        done < $SETTINGSFILE
    done
elif [ "$1" = "test" ]; then
    for SETTINGSFILE in settings_all settings_auth_test settings_test
    do
        echo "Loading settings from $SETTINGSFILE"
        while read line
        do
            eval export $line
        done < $SETTINGSFILE
    done
elif [ "$1" = "staging" ]; then
    for SETTINGSFILE in settings_all settings_auth_staging settings_staging
    do
        echo "Loading settings from $SETTINGSFILE"
        while read line
        do
            eval export $line
        done < $SETTINGSFILE
    done
elif [ "$1" = "local" ]; then
    for SETTINGSFILE in settings_all settings_auth_local settings_local
    do
        echo "Loading settings from $SETTINGSFILE"
        while read line
        do
            eval export $line
        done < $SETTINGSFILE
    done
else
    echo "Invalid command line. Must be $0 and prod, staging, or test or local."
    exit 100
fi

cd /vagrant

source /home/vagrant/www/bin/activate

python manage.py collectstatic --noinput
