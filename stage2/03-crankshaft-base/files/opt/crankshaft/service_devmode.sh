#!/bin/bash

# Only start if debugging is not enabled

if [ ! -f /tmp/usb_debug_mode ]; then

    # dev mode related utility
    source /opt/crankshaft/crankshaft_default_env.sh
    source /opt/crankshaft/crankshaft_system_env.sh
    source /boot/crankshaft/crankshaft_env.sh

    # Check gpio pin if activated
    if [ $ENABLE_GPIO -eq 1 ]; then
        DEV_MODE_GPIO=`gpio -g read $DEV_PIN`
    else
        DEV_MODE_GPIO=1 # 1 = untriggered
    fi

    if [ $DEV_MODE != 0 ] || [ $DEV_MODE_GPIO != 1 ] || [ -f /tmp/usb_dev_mode ]; then
        if [ $DEV_MODE_APP != 1 ] ; then
            # dev mode without start of openauto
            mount -o remount,rw /
            mount -o remount,rw /boot
            touch /tmp/dev_mode_enabled
            show_screen
            echo "[${RED}${BOLD}ACTIVE${RESET}] Dev Mode Enabled - Shell"
            echo "nameserver 8.8.8.8" > /tmp/resolv.conf
            echo "nameserver 8.8.4.4" >> /tmp/resolv.conf
            systemctl start wifisetup.service
            systemctl start dhcpcd.service > /dev/null 2>&1
            systemctl start networking.service
            systemctl start systemd-timesyncd.service > /dev/null 2>&1
            if [ $ENABLE_HOTSPOT == 1 ] ; then
                systemctl start hotspot.service
            fi
            show_cursor
        else
            # dev mode with start of openauto
            mount -o remount,rw /
            mount -o remount,rw /boot
            touch /tmp/dev_mode_enabled
            show_screen
            echo "[${RED}${BOLD}ACTIVE${RESET}] Dev Mode Enabled - OpenAuto"
            touch /tmp/start_openauto
            echo "nameserver 8.8.8.8" > /tmp/resolv.conf
            echo "nameserver 8.8.4.4" >> /tmp/resolv.conf
            systemctl start wifisetup.service
            systemctl start dhcpcd.service > /dev/null 2>&1
            systemctl start networking.service
            systemctl start systemd-timesyncd.service > /dev/null 2>&1
            if [ $ENABLE_HOTSPOT == 1 ] ; then
                systemctl start hotspot.service
            fi
            show_cursor
        fi
    else
        touch /tmp/start_openauto
    fi
fi

exit 0
