#!/bin/bash

#
# simple loader to validate data is inserted
#
INC=$1
if [[ -z $INC ]]; then
    INC=1
fi

mongo --host demo/mdb1.vagrant.dev,mdb2.vagrant.dev,mdb3.vagrant.dev --eval "var increment = $INC;" /shared/scripts/dataloader.js