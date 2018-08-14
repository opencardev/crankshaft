#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
if [ -f /boot/crankshaft/crankshaft_env.sh ]; then
    source /boot/crankshaft/crankshaft_env.sh
fi

/usr/local/bin/crankshaft bluetooth restore

if [ $ENABLE_BLUETOOTH -eq 1 ]; then
    # only disable wifi if system is in normal mode
    if [ $DEV_MODE == 0 ] && [ $DEV_MODE_GPIO == 0 ] && [ ! -f /tmp/usb_dev_mode ] && [ ! -f /tmp/usb_debug_mode ]; then
        # make sure wifi is down cause it createds massiv audio crackles
        sudo ifconfig wlan0 down > /dev/null 2>&1
    fi
    # restore possible pairings
    crankshaft bluetooth restore

    # start services
    sudo systemctl start hciuart
    sudo systemctl start ofono
    sudo systemctl start btautopair

    # Enable hci sco fix
    sudo hcitool cmd 0x3F 0x01C 0x01 0x02 0x00 0x01 0x01

    # Set controller in correct mode
    sudo bt-adapter --set Powered 1
    sudo bt-adapter --set DiscoverableTimeout 0
    sudo bt-adapter --set Discoverable 1
    sudo bt-adapter --set PairableTimeout 0
    sudo bt-adapter --set Pairable 1

    # start autoconnect
    sudo systemctl start btautoconnect
fi
