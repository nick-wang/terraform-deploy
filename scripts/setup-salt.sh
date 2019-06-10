#!/bin/bash

HOST=$(hostname)

if [ $HOST != "salt-master" ]
then
  echo "Do nothing if not salt-master. Host is ${HOST}."
  exit 0
fi

while :
do
  salt-key -L |grep "drbd-node" >/dev/null
  if [ $? != 0 ]
  then
    sleep 3
  else
    yes| salt-key -A
    sleep 15
    break
  fi
done

#Update the salt module/state
salt '*' saltutil.sync_all
