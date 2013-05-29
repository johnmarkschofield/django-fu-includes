#!/bin/bash

set -e

cd /vagrant

set +e
psql -U postgres -l | grep -q www
if [ $? -eq 0 ]; then
    # DB exists
    set -e
    dropdb -U postgres www
fi

set -e

createdb -U postgres www

pg_restore --verbose --no-acl --no-owner -h localhost -U postgres -d www /vagrant/prod.dump
