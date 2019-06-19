#!/bin/bash

if [ $1 == "at" ]
then
virsh attach-disk Ftest-testnodetest-2 \
--source /dev/vm-pool/sbd-dummy \
--target vdc \
--persistent

virsh attach-disk Ftest-testnodetest-3 \
--source /dev/vm-pool/sbd-dummy \
--target vdc \
--persistent
elif [ $1 == "dt" ]
then
virsh detach-disk Ftest-testnodetest-2 \
--target /dev/vm-pool/sbd-dummy \
--persistent

virsh detach-disk Ftest-testnodetest-3 \
--target /dev/vm-pool/sbd-dummy \
--persistent
else
echo "Do nothing!"
fi
