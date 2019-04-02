#!/bin/bash

# Update the git repo drbd
pushd /root/Source/drbd-formula.git
git pull origin dev
popd

# Copy the files
cp -rf /root/Source/drbd-formula.git/drbd/         /srv/salt
cp -rf /root/Source/timezone-formula.git/timezone/ /srv/salt

cp /root/Source/drbd-formula.git/pillar.example     /srv/pillar/drbd/formula.sls
cp /root/Source/timezone-formula.git/pillar.example /srv/pillar/timezone/formula.sls


# Partitioning the /dev/vdb
disk="/dev/vdb"
echo "n
p
1

+300M
n
p
2


w
"|fdisk ${disk}


# Modify the hostname
NUM=$(ip a |grep "192.168.10" |cut -d " " -f "6"|cut -d "/" -f "1"|cut -d "0" -f "3")
sed -i "s/.*/salt-node${NUM}/g" /etc/HOSTNAME
sed -i "s/.*/salt-node${NUM}/g" /etc/hostname
hostnamectl set-hostname "salt-node${NUM}"
hostname salt-node${NUM}


# Enable the salt master/minion service and connect
if [ ${NUM} -eq 1 ]
then
        systemctl enable salt-master.service
	sleep 1
else
        systemctl enable salt-minion.service
fi

# Need to reboot before try accept salt cluster
reboot


