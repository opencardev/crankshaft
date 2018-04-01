#!/bin/bash

# we need to probe the value of the bl_power first
# to not wake up the screen if it's already up

if [ -f /sys/class/backlight/rpi_backlight/bl_power ]; then
	BL_PWR=`cat /sys/class/backlight/rpi_backlight/bl_power`
	
	if [ ${BL_PWR} -ne 0 ]; then
		vcgencmd display_power 1
		echo 0 > /sys/class/backlight/rpi_backlight/bl_power
	fi
else
	vcgencmd display_power 1
fi
