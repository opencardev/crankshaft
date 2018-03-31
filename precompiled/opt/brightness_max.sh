#!/bin/bash

if [ -f ~/.last_brightness ]; then
        cat ~/.last_brightness > /sys/class/backlight/rpi_backlight/brightness
else
	echo 255 > /sys/class/backlight/rpi_backlight/brightness
fi

exit 0
