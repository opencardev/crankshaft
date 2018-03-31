#!/bin/bash

/opt/crankshaft/openauto_settings_save.sh
echo 1 > /sys/class/backlight/rpi_backlight/bl_power
vcgencmd display_power 0
