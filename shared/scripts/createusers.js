db.getSiblingDB("$external").runCommand(
  {
    createUser: "CN=root,OU=sa,O=mongodb,L=NYC,ST=New York,C=US",
    roles: [{ role: 'root', db: 'admin' }]
  }
);

print("created root user");


db.getSiblingDB("$external").runCommand(
  {
    createUser: "CN=app,OU=sa,O=mongodb,L=NYC,ST=New York,C=US",
    roles: [{ role: 'readWrite', db: 'testdb' }]
  }
);

print("created app user");