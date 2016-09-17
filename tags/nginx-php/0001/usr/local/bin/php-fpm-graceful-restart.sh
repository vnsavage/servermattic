#!/bin/bash

# listen.backlog change requires restart, usually /etc/init.d/php5.5-fpm reload should be enough

PAYLOAD=$1

if [ -n "$ENV_PHP_FPM_INIT_SCRIPT" ]; then
	php_fpm_init_script=$ENV_PHP_FPM_INIT_SCRIPT
elif [ $( pgrep -cf 'php-fpm: master process \(/usr/local/php5.4/etc/php-fpm.conf\)' ) -gt 0 ]; then
	php_fpm_init_script='/usr/sbin/service php5.4-fpm'
else
	php_fpm_init_script='/usr/sbin/service php5.6-fpm'
fi

waitpid() {
	while test -d /proc/$1 ; do
		echo "waiting for pid: $1"
		sleep 1;
	done
}

/usr/sbin/service monit stop

NGINX_PID=`cat /var/run/nginx.pid`
if [ -z "$NGINX_PID" ]; then
	NGINX_PID=$(pgrep -fx 'nginx: master process /usr/local/sbin/nginx')
fi

if [ -n "$NGINX_PID" ]; then
	service nginx stop
	waitpid $NGINX_PID
fi

if [ -n "$PAYLOAD" ]; then
	$PAYLOAD
fi

$php_fpm_init_script restart

# In some places, like sandboxes, Nginx wasn't running to begin with, so we don't want to start it.
if [ -n "$NGINX_PID" ]; then
	/usr/sbin/service nginx start
fi
/usr/sbin/service monit start

# reload firewall if needed
if [ -x "/usr/local/nagios/plugins/security-checks.sh" ]; then
	/usr/local/nagios/plugins/security-checks.sh || /etc/init.d/firewall reload
fi
