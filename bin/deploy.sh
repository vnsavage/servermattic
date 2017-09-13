#!/bin/bash

GITURL='https://github.com/vnsavage/servermattic.git'

# Hack to get rid of bad stuff in your apt sources file
sed -i s/'^deb cdrom'/'# deb cdrom'/g /etc/apt/sources.list

apt-get update

OIFS=$IFS
IFS=$(echo -e "\r\n")

for x in $(apt-get -qqfy install git)
  do 
    echo -e "\t$x"
done

mkdir -p /root/bin 

if echo $GITURL |grep -q '^git@github.com:'; then
	ssh-keyscan -t rsa -H github.com >> ~/.ssh/known_hosts
fi

cd /root
git init
git remote add origin $GITURL
git fetch
git checkout -q -f -t origin/master
git pull

export DEBIAN_FRONTEND=noninteractive  
/bin/bash /root/bin/role.sh init

# Remove thyself
rm $0
