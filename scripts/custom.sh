#!/bin/bash

# Update the git repo drbd
pushd /root/Source/drbd-formula.git
git checkout dev
#git pull origin dev
git pull local dev
popd

pushd /root/Source/salt-drbd.git
git checkout dev
#git pull origin dev
git pull local dev
popd

# Copy the files of formula
# run as: salt '*' state.apply drbd
#      or salt '*' state.apply drbd.global_confs
cp -rf /root/Source/drbd-formula.git/drbd/         /srv/salt
cp -rf /root/Source/timezone-formula.git/timezone/ /srv/salt

cp /root/Source/drbd-formula.git/pillar.example     /srv/pillar/drbd/formula.sls
cp /root/Source/drbd-formula.git/pillar.example     /srv/pillar/drbd/formula_pri.sls
cp /root/Source/timezone-formula.git/pillar.example /srv/pillar/timezone/formula.sls

sed -i "s/\(.*promotion: \).*/\1true/" /srv/pillar/drbd/formula_pri.sls

# Copy the files of modules/state
# After any modification on master, should run:  salt '*' saltutil.sync_all
mkdir -p /srv/salt/_modules
mkdir -p /srv/salt/_states

cp /root/Source/salt-drbd.git/salt/modules/drbd.py  /srv/salt/_modules
cp /root/Source/salt-drbd.git/salt/states/drbd.py  /srv/salt/_states


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
    sed -i "s/\(.*promotion: \).*/\1true/" /srv/pillar/drbd/formula_pri.sls
    systemctl enable salt-master.service
else
    systemctl enable salt-minion.service
fi
sleep 1

# Need to reboot before try accept salt cluster
reboot


# Commands to run
# Update modules/states/etc...:  	salt '*' saltutil.sync_all
# highstate: 						salt '*' state.highstate
#	refer to:	/srv/salt/top.sls
# Formula:                          salt '*' state.apply drbd
#	refer to:	/srv/salt/drbd/init.sls
# Modules: 							salt '*' drbd.createmd
#	refer to:	/srv/salt/_modules/drbd.py (func createmd)
# States:							salt '*' state.apply drbd.xxx
#									salt '*' state.apply drbd.dummy test=True
#	refer to:	/srv/salt/drbd/xxx.sls (from formula but not init.sls)
#   	func 	/srv/salt/_states/drbd.py (func dummy in xxx.sls)
