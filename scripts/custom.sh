#!/bin/bash


# The git repos could be replaced by rpm
# Update the git repo drbd
pushd /root/Source/drbd-formula.git
git checkout dev
#git pull origin dev
git pull local dev
popd

# No longer use,since it merged into salt-shaptools.git
#pushd /root/Source/salt-drbd.git
#git checkout dev
##git pull origin dev
#git pull local dev
#popd

pushd /root/Source/salt-shaptools.git
git checkout dev
#git pull origin dev
git pull local dev
popd

pushd /root/Source/habootstrap-formula.git
#git checkout master
#git pull origin master
git pull local master
popd

pushd /root/Source/nfs-formula.git
#git checkout master
#git pull origin master
git pull local master
popd

# Copy the files of formula
# run as: salt '*' state.apply drbd
#      or salt '*' state.apply drbd.global_confs
cp -rf /root/Source/drbd-formula.git/drbd/          /srv/salt
cp -rf /root/Source/timezone-formula.git/timezone/  /srv/salt
cp -rf /root/Source/habootstrap-formula.git/cluster /srv/salt
cp -rf /root/Source/nfs-formula.git/nfs/            /srv/salt

cp /root/Source/drbd-formula.git/pillar.example     /srv/pillar/drbd/formula.sls
cp /root/Source/timezone-formula.git/pillar.example /srv/pillar/timezone/formula.sls
# FiXME - the pillar file and top file
cp /root/Source/habootstrap-formula.git/pillar.example /srv/pillar/cluster/formula.sls.edit
cp /root/Source/nfs-formula.git/nfs/pillar.example     /srv/salt/nfs/formula.sls

# No need due to use grains['host'] to check
#sed -i "s/\(.*promotion: \).*/\1\"salt-node2\"/" /srv/pillar/drbd/formula.sls

# Copy the files of modules/state
# After any modification on master, should run:  salt '*' saltutil.sync_all
mkdir -p /srv/salt/_modules
mkdir -p /srv/salt/_states


#cp /root/Source/salt-drbd.git/salt/modules/drbd.py  /srv/salt/_modules
#cp /root/Source/salt-drbd.git/salt/states/drbd.py  /srv/salt/_states
cp /root/Source/salt-shaptools.git/salt/modules/drbd.py  /srv/salt/_modules
cp /root/Source/salt-shaptools.git/salt/modules/crmshmod.py  /srv/salt/_modules
cp /root/Source/salt-shaptools.git/salt/states/drbd.py  /srv/salt/_states
cp /root/Source/salt-shaptools.git/salt/states/crmshmod.py  /srv/salt/_states


# For nfs
mkdir -p /srv/nfshome
mkdir -p /mnt/mytest
echo "Hello world!" >/srv/nfshome/fileA
echo "Hello Nick!" >/srv/nfshome/fileB

# TODO:
# 1. mkfs the drbd
#    https://www.tecmint.com/find-linux-filesystem-type/
# 2. configure sbd for cluster

# Could be replaced by salt, configurate in terraform
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


# hostname master: salt-master
# hostname minions: salt-drbdX
# Need to change /etc/hosts and /etc/salt/minion
MASTER="salt-master"
MINION="drbd-node"

# Get the last char of IP addr
IP=$(ip a |grep "192.168.10" |cut -d " " -f "6"|cut -d "/" -f "1")
IPLEN=$((${#IP}-1))
NUM=${IP:$IPLEN:1}

# Modify the hostname
if [ ${NUM} -eq 0 ]
then
    NAME=$MASTER
else
    NAME=${MINION}${NUM}
fi

sed -i "s/.*/${NAME}/g" /etc/HOSTNAME
sed -i "s/.*/${NAME}/g" /etc/hostname
hostnamectl set-hostname "${NAME}"
hostname "${NAME}"


# Enable the salt master/minion service and connect
if [ ${NUM} -eq 0 ]
then
    systemctl enable salt-master.service
else
    systemctl enable salt-minion.service
fi
sleep 1

# Need to reboot before try accept salt cluster
reboot


#Notes:
#
# /srv/salt/top.sls
# /srv/salt/pillar.sls
#  salt/
#  └── top.sls
#  pillar/
#  ├── backup.tgz
#  ├── drbd
#  │   └── formula.sls
#  ├── dummy-pillar
#  │   └── test.sls
#  ├── dummy.sls
#  ├── README
#  ├── timezone
#  │   └── formula.sls
#  └── top.sls
#
#  3 directories, 9 files
#  base:
#    'salt-node*':
#      - drbd
#    '*':
#      - timezone
#
#  base:
#    'salt-node*':
#      - drbd.formula
#    '*':
#      - timezone.formula
#      - dummy-pillar.test
#      - dummy




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

# NFS related:
# node1:   nfs.server
#            Install pkgs,start service(nfs-server)
#            # showmount -e 192.168.10.101
# node2:   nfs.client
#            # Install pkgs
#          nfs.mount
#            # verify:   mount
#            #           l /mnt/mytest/
#          nfs.unmount
#            # verify:   mount

