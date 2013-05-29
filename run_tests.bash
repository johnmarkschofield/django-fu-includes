#!/bin/bash

set -e

rm -rf /home/vagrant/testing
mkdir -p /home/vagrant/testing
cd /home/vagrant/testing
wget -e robots=off --recursive -N --page-requisites --span-hosts -H -Ds'amazonaws.com,dakim-www-test.herokuapp.com' --no-remove-listing  --level=inf --no-directories --save-headers --tries 1 http://dakim-www-test.herokuapp.com