#!/bin/bash

DEV_MODE=`/opt/crankshaft/devmode.sh status`


if [ $DEV_MODE == "disabled" ] ; then
	/opt/crankshaft/filesystem.sh unlock_boot
fi

cp /tmp/openauto.ini /boot/crankshaft/openauto.ini

/opt/crankshaft/brightness.sh save

if [ $DEV_MODE == "disabled" ] ; then
	/opt/crankshaft/filesystem.sh lock_boot
fi