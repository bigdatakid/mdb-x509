#!/bin/bash

#
# setup initial unsecure instance of mongodb 3.0.x
# with vagrant these commands will be run as root
#

#
# (1) setup host file
#
cp /etc/hosts /etc/hosts.backup
cp /shared/conf/hosts /etc/hosts

#
# (2) copy repo files for yum installs
#
cp /shared/repos/* /etc/yum.repos.d/

#
# (3) install mongodb 3.0.12
#
sudo yum install -y mongodb-org-3.0.12 mongodb-org-server-3.0.12 mongodb-org-shell-3.0.12 mongodb-org-mongos-3.0.12 mongodb-org-tools-3.0.12

#
# (4) setup configuration
#
mkdir /data /log
chown -R mongod:mongod /data /log
cp /shared/conf/mdb.initial.conf /etc/mongod.conf

#
# (5) start mongod
#
systemctl start mongod.service

#
# (6) setup replica set - stupid hack (if $1 == mdb3) vagrant up will go in order mdb1, mdb2, mdb3, if we are at mdb3 we are
#     on the last server so setup the replica set
#
if [[ $1 == "mdb3" ]]; then
    echo "setting up replica set"
    # to ensure mongodb starts!
    sleep 2
    mongo /shared/scripts/replicaset.js
fi