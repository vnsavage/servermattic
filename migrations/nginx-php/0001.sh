#!/bin/bash

export DEBIAN_FRONTEND='noninteractive'

apt-get update

# Needed for php to work
apt-get install -fqqy libgd2-noxpm libcurl3 libmcrypt-dev mlock libxslt1.1 libfreetype6 libjpeg62

dpkg -i /usr/local/src/download/libgmp3c2_4.3.2+dfsg-1_amd64.deb

# Needed for fpm-stats
apt-get -fqqy install libwww-perl

mkdir -p /var/cache/nginx/page_cache
chown -R nobody.nogroup /var/cache/nginx/page_cache

/usr/sbin/service nginx reload

/usr/local/bin/switch-php.sh 5.6
