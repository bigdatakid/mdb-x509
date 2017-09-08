# README
Vagrant environment to demonstrate:
1. Setup initial replica set with 3.0.x with no security
2. Upgrade replica set to 3.2.x with no security
3. Create required SSL certificates for server and clients
4. Enable security and require SSL for authentication into the system

## About
Everything is self contained with scripts that do the execution, for the sake of this demo each
step is done in a self-contained script allowing the user to see what occurs

Note: Where ever you see mdbX, X represents a number from 1 through 3 as there are three vagrant servers
running mdb1, mdb2, mdb3

## Instructions
1. first deploy initial vagrant environemnt
   ```
   $ cd <path-to-mdbx509-directory>
   $ vagrant up
   ```
   The vagrant up command will launch 3 centos boxes and install mongodb locally, this includes setting up
   the repo for both the 3.0.x and 3.2.x community repositories.
   Each of the mdbX boxes will be built serially and attach the ./shared directory locally.  When
   the vagrant environemnt is built it will then execute /shared/setupmdb.sh which installs mongodb and
   copies the /shared/conf/mdb1.initial.conf to /etc/mongod.conf.  Since the execution is serial,
   the script will then setup the replica set when the mdb3 vagrant box is finished by calling the
   /shared/replicaset.js script.
2. To ensure everything is working log into the system and execute the dataloader:
   ```
   $ vagrant ssh mdbX
   [mdbX]$ mongo --host demo/mdb1.vagrant.dev,mdb2.vagrant.dev,mdb3.vagrant.dev --eval "var increment = 0;" /shared/scripts/dataloader.js --shell
   demo:PRIMARY> use testdb;
   demo:PRIMARY> db.coll.count();
   1000
   ```
3. Now we do an upgrade, this can be done in zero downtime, this involves running the upgrade mongodb.sh script
   on each server (X = 1,2,3):
   ```
   $ vagrant ssh mdbX
   [mdbX]$ sudo /shared/scripts/upgrademdb.sh
   ```
   To achieve zero down time do one server at a time with the a secondary and as it comes up ensure it is in a good state before
   moving forward.  When there are a large number of replicas, more than 1 secondary can be targeted at a time as we will not
   bring down a majority of the servers.
   To confirm this works, execute step 2 again, change increment to 1000, you should now have 2000 documents in the collection
4. Next we can update the replica set protocal to use the new faster failover option.
   Run this from one server, as it will update the replica set configuration for all servers
   ```
   $ vagrant ssh mdbX
   [mdbX]$ mongo --host demo/mdb1.vagrant.dev,mdb2.vagrant.dev,mdb3.vagrant.dev /shared/scripts/updateProtocol.js
   ```
   Note: that this could cause an interruption in service in some circumstances as it might force an election for a new primary
   Plan the maintenance window accordingly
   Run step 2 again to ensure everythin is functioning properly - Should now be at 3000 records
5. Next, lets create the certificates that we will need for server and client authentication, from one box run the following command:
   ```
   $ vagrant ssh mdbX
   [mdbX]$ sudo /shared/scripts/build_certs.sh
   ```
   This script creates the Root CA needed to sign the certificates as well as 3 server certs and 2 client certs.
   The directories created are: /shared/ca/root, /shared/ca/srvs, /shared/ca/usrs
   Each of the directories will contain the key, csr, cert and pem file.
   Please note this is not a production ready release - use your organizations best practices for certificate management
   CA passphrase is password.
6. Upon success of creating the certs the next thing to do is add the users that we want to have access to the sytem.  This can
   be done before actually enabling security and restarting the servers.  To do this run the commands below:
   ```
   $ vagrant ssh mdbX
   [mdbX]$ mongo --host demo/mdb1.vagrant.dev,mdb2.vagrant.dev,mdb3.vagrant.dev /shared/scripts/createusers.js
   ```
   this will create two users:
   CN=root,OU=sa,O=mongodb,L=NYC,ST=New York,C=US - which will have root access (all) to the database
   CN=app,OU=sa,O=mongodb,L=NYC,ST=New York,C=US - which will have readWrite access to testdb
7. Finally, enable security - this is done by copying the mdbX.initial.conf files from the /shared/conf directory to the associated
   /etc/mongod.conf files and restarting the server. run the following command on each server:
   ```
   $ vagrant ssh mdbX
   [mdbX]$ sudo /shared/scripts/enable_32security.sh
   Note that at this time there could be an outage depending on how you plan your application driver updates to address the
   authentication enabling process.
   During this time the first server will not be able to connect to the rest of the replica set, so it will appear down, then
   when the second server is updating there will be no primary and once up it will be able  to connect to the first but not
   the third, and finally the third will connect to the rest.
   In this state each server will have a different view of who is failing and the primary will follow the majority of servers that
   are accessible.
8. Final authenticated test:
   ```
   $ vagrant ssh mdbX
   [mdbX]$ mongo --host demo/mdb1.vagrant.dev,mdb2.vagrant.dev,mdb3.vagrant.dev --ssl --sslPEMKeyFile /shared/ca/usr/app.pem --sslCAFile /shared/ca/root/mdbca.crt
   demo:PRIMARY> db.getSiblingDB("$external").auth({mechanism: "MONGODB-X509", user: "CN=app,OU=sa,O=mongodb,L=NYC,ST=New York,C=US"}) 
   1
   demo:PRIMARY> use testdb
   demo:PRIMARY> db.coll.count()
   3000
   ```
   Note that the user must match the certificate that was passed in

