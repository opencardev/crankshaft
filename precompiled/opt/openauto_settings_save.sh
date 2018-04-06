#!/bin/bash

mount -o remount,rw /boot/

cp /tmp/openauto.ini /boot/crankshaft/openauto.ini

# try to save the brightness if possible
if [ -f /sys/class/backlight/rpi_backlight/brightness ]; then
	cat /sys/class/backlight/rpi_backlight/brightness > /boot/crankshaft/brightness
fi
sync

mount -o remount,ro /

