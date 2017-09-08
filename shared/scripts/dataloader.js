/*
 * usage: mongo --host demo/mdb1.vagrant.dev,mdb2.vagrant.dev,mdb3.vagrant.dev --eval "var increment = 0;" /shared/scripts/dataloader.js
 */
var load1kdocs = function(starting){
    db = db.getSiblingDB('testdb');
    for(var x = starting; x < (starting + 1000); x++){
        db.coll.insert({x: x, y: x * 10, z: x * 100});
    }
}

load1kdocs(increment);