#!/bin/bash

if [ -f /boot/crankshaft/brightness ]; then
        cat /boot/crankshaft/brightness > /sys/class/backlight/rpi_backlight/brightness
else
	echo 255 > /sys/class/backlight/rpi_backlight/brightness
fi

exit 0
