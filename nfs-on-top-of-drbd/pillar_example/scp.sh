#!/bin/bash

if [ $1 == "drbd.j2" ]
then
  scp drbd.j2 root@10.67.20.147:/tmp/drbd.j2
  scp drbd.j2 root@192.168.10.100:/tmp/drbd.j2
  scp drbd.j2 root@192.168.10.101:/tmp/drbd.j2
  scp drbd.j2 root@192.168.10.102:/tmp/drbd.j2
fi
