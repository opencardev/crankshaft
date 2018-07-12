#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
source /boot/crankshaft/crankshaft_env.sh

chown pi:pi /tmp/.local
chown pi:pi /tmp/.config

# Check if wallpapers are present and non zero
if [ ! -f /boot/crankshaft/wallpaper.png ] || [ ! -s /boot/crankshaft/wallpaper.png ]; then
    /usr/local/bin/crankshaft filesystem boot unlock
    cp /opt/crankshaft/wallpaper/wallpaper.png /boot/crankshaft/
    /usr/local/bin/crankshaft filesystem boot lock
fi

if [ ! -f /boot/crankshaft/wallpaper-night.png ] || [ ! -s /boot/crankshaft/wallpaper-night.png ]; then
    /usr/local/bin/crankshaft filesystem boot unlock
    cp /opt/crankshaft/wallpaper/wallpaper-night.png /boot/crankshaft/
    /usr/local/bin/crankshaft filesystem boot lock
fi

if [ ! -f /boot/crankshaft/wallpaper-devmode.png ] || [ ! -s /boot/crankshaft/wallpaper-devmode.png ]; then
    /usr/local/bin/crankshaft filesystem boot unlock
    cp /opt/crankshaft/wallpaper/wallpaper-devmode.png /boot/crankshaft/
    /usr/local/bin/crankshaft filesystem boot lock
fi

if [ ! -f /boot/crankshaft/wallpaper-devmode-night.png ] || [ ! -s /boot/crankshaft/wallpaper-devmode-night.png ]; then
    /usr/local/bin/crankshaft filesystem boot unlock
    cp /opt/crankshaft/wallpaper/wallpaper-devmode-night.png /boot/crankshaft/
    /usr/local/bin/crankshaft filesystem boot lock
fi

if [ ! -f /boot/crankshaft/camera-overlay.png ] || [ ! -s /boot/crankshaft/camera-overlay.png ]; then
    /usr/local/bin/crankshaft filesystem boot unlock
    cp /opt/crankshaft/wallpaper/camera-overlay.png /boot/crankshaft/
    /usr/local/bin/crankshaft filesystem boot lock
fi

exit 0
