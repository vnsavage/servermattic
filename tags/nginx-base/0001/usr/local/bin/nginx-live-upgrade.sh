#!/bin/bash
#
# This, in theory, allows you to upgrade an nginx binary w/out service interruption.
# http://wiki.nginx.org/NginxCommandLine
#

oldpid=`cat /var/run/nginx.pid`

if [ -z "$oldpid" ]; then
	echo "Nginx PID not found in /var/run/nginx.pid"
	exit 0
fi

kill -USR2 $oldpid

sleep 2

if [ $oldpid = $(cat /var/run/nginx.pid) ]; then
	echo "Failed to start new binary, check /var/log/nginx/error_log"
	exit 1
fi

kill -WINCH $oldpid

sleep 2

kill -QUIT $oldpid
