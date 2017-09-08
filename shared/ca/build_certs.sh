#!/bin/bash

#
# create required certificates -
# 3 server certificates
# 2 user certificates
#
CA=/shared/ca/root
SRV=/shared/ca/srv
USR=/shared/ca/usr
CNF=/shared/ca/conf

# prep /shared/ca directory - simply wipe and restart as needed (can clean up later)
rm -rf ${CA} ${SRV} ${USR}

mkdir -p ${CA} ${SRV} ${USR}

# create CA for mongodb certificates
echo "certificate management: create mongodb ca key"
openssl genrsa -out ${CA}/mdbprivate.key -aes256 -passout pass:password
openssl req -x509 -new -key ${CA}/mdbprivate.key -days 1000 -out ${CA}/mdbca.crt -passin pass:password -config ${CNF}/ca.conf

# create server certificate requests
echo ""
echo "certificate management: create mongodb server certificate requests"
openssl req -new -nodes -newkey rsa:2048 -keyout ${SRV}/mdb1.key -out ${SRV}/mdb1.csr -config ${CNF}/mdb1.conf
openssl req -new -nodes -newkey rsa:2048 -keyout ${SRV}/mdb2.key -out ${SRV}/mdb2.csr -config ${CNF}/mdb2.conf
openssl req -new -nodes -newkey rsa:2048 -keyout ${SRV}/mdb3.key -out ${SRV}/mdb3.csr -config ${CNF}/mdb3.conf

echo ""
echo "certificate management: siging certificates"
openssl x509 -CA ${CA}/mdbca.crt -CAkey ${CA}/mdbprivate.key -CAcreateserial -req -days 1000 -in ${SRV}/mdb1.csr -out ${SRV}/mdb1.crt -passin pass:password
openssl x509 -CA ${CA}/mdbca.crt -CAkey ${CA}/mdbprivate.key -CAcreateserial -req -days 1000 -in ${SRV}/mdb2.csr -out ${SRV}/mdb2.crt -passin pass:password
openssl x509 -CA ${CA}/mdbca.crt -CAkey ${CA}/mdbprivate.key -CAcreateserial -req -days 1000 -in ${SRV}/mdb3.csr -out ${SRV}/mdb3.crt -passin pass:password

echo ""
echo "creating pem files"
cat ${SRV}/mdb1.key ${SRV}/mdb1.crt > ${SRV}/mdb1.pem
cat ${SRV}/mdb2.key ${SRV}/mdb2.crt > ${SRV}/mdb2.pem
cat ${SRV}/mdb3.key ${SRV}/mdb3.crt > ${SRV}/mdb3.pem

echo ""
echo "creating root user"
openssl req -new -nodes -newkey rsa:2048 -keyout ${USR}/root.key -out ${USR}/root.csr -config ${CNF}/root.conf
openssl x509 -CA ${CA}/mdbca.crt -CAkey ${CA}/mdbprivate.key -CAcreateserial -req -days 1000 -in ${USR}/root.csr -out ${USR}/root.crt -passin pass:password
cat ${USR}/root.key ${USR}/root.crt > ${USR}/root.pem
openssl x509 -in ${USR}/root.pem -inform PEM -subject -nameopt RFC2253

echo ""
echo "creating app user"
openssl req -new -nodes -newkey rsa:2048 -keyout ${USR}/app.key -out ${USR}/app.csr -config ${CNF}/app.conf
openssl x509 -CA ${CA}/mdbca.crt -CAkey ${CA}/mdbprivate.key -CAcreateserial -req -days 1000 -in ${USR}/app.csr -out ${USR}/app.crt -passin pass:password
cat ${USR}/app.key ${USR}/app.crt > ${USR}/app.pem
openssl x509 -in ${USR}/app.pem -inform PEM -subject -nameopt RFC2253

#        2 users (admin & testdb user)
#        - root user:
#            openssl req -new -nodes -newkey rsa:2048 -keyout rootuser.key -out rootuser.csr
#            openssl x509 -CA ./mdbca.crt -CAkey ./mdbprivate.key -CAcreateserial -req -days 1000 -in ./rootuser.csr -out ./rootuser.crt
#            cat ./rootuser.key ./rootuser.crt > ./rootuser.pem
#            openssl x509 -in ./rootuser.pem -inform PEM -subject -nameopt RFC2253
#        - app user:
#            openssl req -new -nodes -newkey rsa:2048 -keyout appuser.key -out appuser.csr
#            openssl x509 -CA ./mdbca.crt -CAkey ./mdbprivate.key -CAcreateserial -req -days 1000 -in ./appuser.csr -out ./appuser.crt
#            cat ./appuser.key ./appuser.crt > ./appuser.key
#            openssl x509 -in ./appuser.pem -inform PEM -subject -nameopt RFC2253
            
