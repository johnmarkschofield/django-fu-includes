#!/bin/bash

cd /vagrant/hfu_settings

if [ "$1" =  "prod" ]; then
    for SETTINGSFILE in settings_all settings_auth_prod settings_local
    do
        echo "Loading settings from $SETTINGSFILE"
        while read line
        do
            eval export $line
            echo eval export $line
        done < $SETTINGSFILE
    done
elif [ "$1" = "test" ]; then
    for SETTINGSFILE in settings_all settings_auth_test settings_local
    do
        echo "Loading settings from $SETTINGSFILE"
        while read line
        do
            eval export $line
            echo eval export $line
        done < $SETTINGSFILE
    done
elif [ "$1" = "staging" ]; then
    for SETTINGSFILE in settings_all settings_auth_staging settings_local
    do
        echo "Loading settings from $SETTINGSFILE"
        while read line
        do
            eval export $line
            echo eval export $line
        done < $SETTINGSFILE
    done
else
    echo "Invalid command line. Must be $0 and prod, staging, or test."
    exit 100
fi

cd /vagrant

source /home/vagrant/www/bin/activate

python manage.py collectstatic --noinput
