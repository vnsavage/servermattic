#!/bin/bash

CR="
"
SP=" "

## Grab Some Variables
###############################################################
id_dc=$2
id_dc_l=$(echo $id_dc | tr "[:upper:]" "[:lower:]")
id_hn=$3
id_be=$4

### Operations System Prep
###############################################################
hostname $id_hn
echo $id_hn > /etc/hostname

### System Software
###############################################################

if grep -q ^7 /etc/debian_version; then
    code_name="wheezy"
elif grep -q ^8 /etc/debian_version; then
    code_name="jessie"
fi

# Make sure loopback interface is up otherwise things like postfix won't work
if [ `/sbin/ifconfig | grep -c ^lo` -eq 0 ]; then
	    /sbin/ifup lo
fi

OIFS=$IFS
IFS=$CR
echo "Updating Apt..."
for x in $(apt-get -qy update 2>&1)
do
    echo -e "\t$x"
done
echo "Updating System"
for x in $(apt-get -qqfy dist-upgrade 2>&1)
do
    echo -e "\t$x"
done

# Install everything else
echo -e "Installing Everything Else"
IFS=" "
for pkg in gawk postfix vim sysstat screen ethtool rsync sudo less bsd-mailx pciutils netcat bc symlinks ncurses-term curl lsof strace ltrace wget libc6-i386 smartmontools
do
    IFS=$CR
    for x in $(apt-get -qqfy install $pkg)
    do
        echo -e "\t$x"
    done
    IFS=" "
done
echo
IFS=$OIFS
clear

# Timezone stuff
ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime
/sbin/hwclock --systohc --utc

dpkg -i /usr/local/src/download/libssl0.9.8_0.9.8o-4squeeze13_amd64.deb
apt-get -qqfy install symlinks strace tcpdump dnsutils

## System Users
###############################################################
groupadd nagios
useradd -g nagios -d /usr/local/nagios -s /bin/false nagios
chown -R nagios.nagios /usr/local/nagios

### Software [re]start
###############################################################
/usr/sbin/service postfix restart
/usr/sbin/service ssh restart
/usr/sbin/service nrpe restart
newaliases

###############################################################
# Run on boot
# Permissions on /root/ need to change for anything to work
chmod 755 /root/
rm /root/.bash_profile

# Set the default editor to vim, nano kind of sucks
update-alternatives --set editor /usr/bin/vim.basic
