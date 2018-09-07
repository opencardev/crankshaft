#!/bin/bash

for usbdevice in $(mount | grep /dev/sd | awk {'print $1'}); do
    umount -f $usbdevice
done

exit 0
