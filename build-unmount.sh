#!/bin/bash

BASEDIR="pwd"

mountpoints=`mount | grep ${BASEDIR} | awk '{print $3}' | awk {'print length, $1'} | sort -g -r | cut -d' ' -f2-`

sed 's/ /\n/g' <<< $mountpoints

for m in $mountpoints; do
    umount -f $m
done

# Check after unmount
mountpoints=`mount | grep ${BASEDIR} | awk '{print $3}' | awk {'print length, $1'} | sort -g -r | cut -d' ' -f2-`
if [ ! -z $mountpoints ]; then
    echo "***************************************************************************************"
    echo "* Still mounted:"
    echo $mountpoints
    echo "***************************************************************************************"
fi
