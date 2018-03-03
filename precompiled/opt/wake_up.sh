#!/bin/bash

vcgencmd display_power 1
echo 0 > /sys/class/backlight/rpi_backlight/bl_power
