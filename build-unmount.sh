#!/bin/bash

BASEDIR="`cd $0 >/dev/null 2>&1; pwd`" >/dev/null 2>&1

mountpoints=`mount | grep ${BASEDIR} | awk '{print $3}' | awk {'print length, $1'} | sort -g -r | cut -d' ' -f2-`

sed 's/ /\n/g' <<< $mountpoints

for m in $mountpoints; do
    umount -f $m
done

# Check after unmount
echo "***************************************************************************************"
echo "* Still mounted:"
mountpoints=`mount | grep ${BASEDIR} | awk '{print $3}' | awk {'print length, $1'} | sort -g -r | cut -d' ' -f2-`
if [ ! -z mountpoints ]; then
    #mount | grep $BASEDIR | awk '{print $3}' | awk {'print length, $1'} | sort -g -r | cut -d' ' -f2-
    echo $mountpoints
    echo "***************************************************************************************"
fi
