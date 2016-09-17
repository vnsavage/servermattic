#!/bin/bash

groupadd mysql 2>/dev/null
useradd -g mysql mysql 2>/dev/null

apt-get -fqqy install numactl libdbd-mysql-perl libaio1 rlwrap

cd /usr/local/

# MySQL 5.6
echo "Installing Percona-Server-5.6.26-rel74.0-Linux.x86_64.ssl098"
for x in $(tar -zxf ./src/download/Percona-Server-5.6.26-rel74.0-Linux.x86_64.ssl098.tar.gz)
do
    echo -e "\t$x"
done
echo "Setting U/G Ownership"
for x in $(chown -R root:mysql /usr/local/Percona-Server-5.6.26-rel74.0-Linux.x86_64.ssl098)
do
    echo -e "\t$x"
done

rm -f /usr/local/mysql5.6 /usr/local/mysql-latest
ln -s /usr/local/Percona-Server-5.6.26-rel74.0-Linux.x86_64.ssl098 /usr/local/mysql5.6
ln -sf /usr/local/mysql5.6 /usr/local/mysql-latest

# Need some awesome symlinks because Percona removed bundled YaSSL and binary distribution we use
# Links against CentOS5 libs for compatibility.  See https://bugs.launchpad.net/percona-server/+bug/1104977
ln -s /usr/lib/libssl.so.0.9.8 /usr/lib/libssl.so.6
ln -s /usr/lib/libcrypto.so.0.9.8 /usr/lib/libcrypto.so.6

if grep -q ^8 /etc/debian_version; then
	apt-get -fqqy install libgcrypt11
fi
