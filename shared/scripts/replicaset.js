/*
 * setup replica set
 */
rs.initiate();
print("sleep 5 seconds");
sleep(5000);
rs.add('mdb2.vagrant.dev');
rs.add('mdb1.vagrant.dev');
var members = rs.conf().members;
if (members.length === 3) {
    for(x = 0; x < members.length; x++){
        print("member[" + x + "]: " + members[x].host);
    }
} else {
    print("Error: replica set not setup properly");
}