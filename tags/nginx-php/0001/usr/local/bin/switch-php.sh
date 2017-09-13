#!/bin/bash

if grep -q 6.0 /etc/debian_version; then
    DISTRO=squeeze
elif grep -q ^7. /etc/debian_version; then
    DISTRO=wheezy
elif grep -q ^8. /etc/debian_version; then
    DISTRO=jessie
elif grep -q ^9. /etc/debian_version; then
	DISTRO=stretch
else
	echo "Distro not supported"
	exit 1
fi

function do_symlinks() {
	PHP_VER="php${1}"

	rm /usr/local/$PHP_VER/bin
	rm /usr/local/$PHP_VER/lib
	rm /usr/local/$PHP_VER/modules

	ln -sf /usr/local/$PHP_VER/bin{.${DISTRO},}
	ln -sf /usr/local/$PHP_VER/lib{.${DISTRO},}
	ln -sf /usr/local/$PHP_VER/modules{.${DISTRO},}

	if [ -L /etc/roles/wp-web ]; then
		if [ -L /etc/roles/dev-base ]; then
			ln -s /usr/local/$PHP_VER/conf.d/large-uploads /usr/local/$PHP_VER/conf.d/large-uploads.ini
			ln -s /usr/local/$PHP_VER/conf.d/wp-web.admin /usr/local/$PHP_VER/conf.d/wp-web.ini
			ln -sf /usr/local/$PHP_VER/etc/fpm.d/dev-files /usr/local/$PHP_VER/etc/fpm.d/dev-files.conf
			ln -sf /usr/local/$PHP_VER/conf.d/ftp-dev /usr/local/$PHP_VER/conf.d/ftp.ini
			ln -sf /usr/local/$PHP_VER/conf.d/imap-jobs /usr/local/$PHP_VER/conf.d/imap.ini
			ln -sf /usr/local/$PHP_VER/conf.d/zip-jobs /usr/local/$PHP_VER/conf.d/zip.ini
		elif [[ $(hostname -f) =~ (admin|jobs) ]]; then
			ln -s /usr/local/$PHP_VER/conf.d/large-uploads /usr/local/$PHP_VER/conf.d/large-uploads.ini
		fi

		if [[ $(hostname -f) =~ admin ]]; then
			ln -s /usr/local/$PHP_VER/conf.d/wp-web.admin /usr/local/$PHP_VER/conf.d/wp-web.ini
		elif [[ $(hostname -f) =~ ^files ]]; then
			ln -s /usr/local/$PHP_VER/conf.d/wp-web.admin /usr/local/$PHP_VER/conf.d/wp-web.ini
		fi

		if [[ $(hostname -f) =~ \.jetpack\. ]]; then
			ln -sf /usr/local/$PHP_VER/etc/fpm.d/wp-files-jetpack /usr/local/$PHP_VER/etc/fpm.d/10-wp-files.conf
		elif [[ $(hostname -f) =~ files ]]; then
			ln -sf /usr/local/$PHP_VER/etc/fpm.d/wp-files-high /usr/local/$PHP_VER/etc/fpm.d/10-wp-files.conf
		fi

		if [[ $(hostname -f) =~ ^files ]]; then
			ln -s /usr/local/$PHP_VER/conf.d/large-uploads /usr/local/$PHP_VER/conf.d/large-uploads.ini
		fi

		if [[ $(hostname -f) =~ jobs ]]; then
			ln -sf /usr/local/$PHP_VER/conf.d/imap-jobs /usr/local/$PHP_VER/conf.d/imap.ini
			ln -sf /usr/local/$PHP_VER/conf.d/zip-jobs /usr/local/$PHP_VER/conf.d/zip.ini
		fi
	fi

	if [ -L /etc/roles/wpcom-jobs ]; then
		/usr/sbin/service wpcom-jobs restart
	fi

	if [ -L /etc/roles/akismet-jobs ]; then
		/usr/sbin/service ak-jobs restart
	fi

	if [ "$DISTRO" == "wheezy" ] || [ "$DISTRO" == "jessie" ]; then
		ln -sf /etc/$PHP_VER-logs-logrotate-wheezy /etc/logrotate.d/php-logs
	else
		ln -sf /etc/$PHP_VER-logs-logrotate-pre-wheezy /etc/logrotate.d/php-logs
	fi

	ln -sf /usr/local/$PHP_VER/bin/php /usr/local/bin/php
}

if [ "$1" == "7.0" ]; then
	if readlink -f /usr/local/bin/php | grep -q php7.0; then
		echo "Already 7.0"
		exit
	fi
	do_symlinks $1

	if [ "$DISTRO" == "jessie" ]; then
		systemctl daemon-reload
		systemctl enable $(readlink /root/services/php7.0-fpm.service)
	else
		update-rc.d php7.0-fpm defaults
	fi
	export ENV_PHP_FPM_INIT_SCRIPT='/usr/sbin/service php7.0-fpm'
	/usr/local/bin/php-fpm-graceful-restart.sh
	sleep 2
else 
	echo "Missing or invalid php version."
	exit 1
fi

