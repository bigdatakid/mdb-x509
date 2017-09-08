#!/bin/bash

sudo systemctl stop mongod.service
sudo yum update -y mongodb-org
sudo systemctl daemon-reload
sudo systemctl start mongod.service
