#!/bin/bash

source /opt/crankshaft/crankshaft_system_env.sh

for usbdevice in $(mount | grep /dev/sd | awk {'print $1'}); do
    umount -f $usbdevice
done

exit 0
