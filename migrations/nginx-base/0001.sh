#!/bin/bash

apt-get -fqqy install libpcre3

echo "Update our ld cache"
/sbin/ldconfig -v

ln -sf /usr/local/sbin/nginx-lb /usr/local/sbin/nginx

# Start on boot
update-rc.d nginx defaults

/usr/sbin/service nginx restart
/usr/sbin/service nginx start
