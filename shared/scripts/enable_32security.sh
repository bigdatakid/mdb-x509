#!/bin/bash

HOST=`hostname -s`

echo "copying data for ${HOST}"
sudo systemctl stop mongod.service
sudo cp /shared/conf/${HOST}.initial.conf /etc/mongod.conf

sudo systemctl daemon-reload
sudo systemctl start mongod.service
