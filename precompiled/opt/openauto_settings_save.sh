#!/bin/bash

mount -o remount,rw /
cp /tmp/openauto.ini ~/.openauto_saved.ini

# try to save the brightness if possible
if [ -f /sys/class/backlight/rpi_backlight/brightness ]; then
	cat /sys/class/backlight/rpi_backlight/brightness > ~/.last_brightness
fi
sync
mount -o remount,ro /

