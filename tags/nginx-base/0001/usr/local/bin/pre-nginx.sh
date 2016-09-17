#!/bin/sh

if [ -w "/proc/sys/net/ipv4/ip_nonlocal_bind" ]; then 
	echo 1 > /proc/sys/net/ipv4/ip_nonlocal_bind
fi
# These should probably be moved to sysctl
if [ -w "/proc/sys/net/ipv4/tcp_syncookies" ]; then
	echo 1 > /proc/sys/net/ipv4/tcp_syncookies
fi
if [ -w "/proc/sys/net/ipv4/tcp_max_tw_buckets" ]; then
	echo 512000 > /proc/sys/net/ipv4/tcp_max_tw_buckets
fi

