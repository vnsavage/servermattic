#!/bin/bash

mkdir -p /var/log/mysql1-0
chown mysql.mysql /var/log/mysql1-0

cd /usr/local/mysql5.6/
./scripts/mysql_install_db --defaults-file=/etc/mysql/mysql1-0.cnf --user=mysql --datadir=/var/lib/mysql1-0 --force  --skip-name-resolve
chown -R mysql.mysql /var/lib/mysql1-0

/etc/init.d/mysql1-0 start

MYSQL_CMD="mysql --defaults-file=/etc/mysql/mysql1-0.cnf -u root -sN -e" 
$MYSQL_CMD "drop database test;"
$MYSQL_CMD "update mysql.user set user = 'test' where user='root';"
$MYSQL_CMD "delete from mysql.user where host = '$HOSTNAME';"
$MYSQL_CMD "update mysql.user set password = '*94BDCEBE19083CE2A1F959FD02F964C7AF4CFC29' where user = 'test';"
$MYSQL_CMD "update mysql.user set Shutdown_priv = 'Y', Process_priv = 'Y', Super_priv = 'Y' where host = 'localhost' and user = '';"
$MYSQL_CMD "flush privileges;"

