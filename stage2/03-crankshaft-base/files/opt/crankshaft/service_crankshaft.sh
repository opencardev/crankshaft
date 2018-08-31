#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
if [ -f /boot/crankshaft/crankshaft_env.sh ]; then
    source /boot/crankshaft/crankshaft_env.sh
fi

log_echo "Set user permissions /tmp/xxx"
chown pi:pi /tmp/.local-pi
chown pi:pi /tmp/.config-pi
chown pi:pi /tmp/.cache-pi

chown root:root /tmp/.local-pi
chown root:root /tmp/.config-pi
chown root:root /tmp/.cache-pi

# Check if wallpapers are present and non zero
if [ ! -f /boot/crankshaft/wallpaper.png ] || [ ! -s /boot/crankshaft/wallpaper.png ]; then
    log_echo "Place default wallpaper.png"
    /usr/local/bin/crankshaft filesystem boot unlock
    cp /opt/crankshaft/wallpaper/wallpaper.png /boot/crankshaft/
    /usr/local/bin/crankshaft filesystem boot lock
fi

if [ ! -f /boot/crankshaft/wallpaper-night.png ] || [ ! -s /boot/crankshaft/wallpaper-night.png ]; then
    log_echo "Place default wallpaper-night.png"
    /usr/local/bin/crankshaft filesystem boot unlock
    cp /opt/crankshaft/wallpaper/wallpaper-night.png /boot/crankshaft/
    /usr/local/bin/crankshaft filesystem boot lock
fi

if [ ! -f /boot/crankshaft/wallpaper-classic.png ] || [ ! -s /boot/crankshaft/wallpaper-classic.png ]; then
    log_echo "Place default wallpaper-classic.png"
    /usr/local/bin/crankshaft filesystem boot unlock
    cp /opt/crankshaft/wallpaper/wallpaper-classic.png /boot/crankshaft/
    /usr/local/bin/crankshaft filesystem boot lock
fi

if [ ! -f /boot/crankshaft/wallpaper-classic-night.png ] || [ ! -s /boot/crankshaft/wallpaper-classic-night.png ]; then
    log_echo "Place default wallpaper-classic-night.png"
    /usr/local/bin/crankshaft filesystem boot unlock
    cp /opt/crankshaft/wallpaper/wallpaper-classic-night.png /boot/crankshaft/
    /usr/local/bin/crankshaft filesystem boot lock
fi

if [ ! -f /boot/crankshaft/camera-overlay.png ] || [ ! -s /boot/crankshaft/camera-overlay.png ]; then
    log_echo "Place default camera-overlay.png"
    /usr/local/bin/crankshaft filesystem boot unlock
    cp /opt/crankshaft/wallpaper/camera-overlay.png /boot/crankshaft/
    /usr/local/bin/crankshaft filesystem boot lock
fi

exit 0
