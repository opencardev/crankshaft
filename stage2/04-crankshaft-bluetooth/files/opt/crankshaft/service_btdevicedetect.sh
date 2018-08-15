#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
if [ -f /boot/crankshaft/crankshaft_env.sh ]; then
    source /boot/crankshaft/crankshaft_env.sh
fi

if [ $ENABLE_BLUETOOTH -eq 1 ]; then
    # Check loop for connected btdevice
    while true; do
        btdevice=$(pactl list sinks | grep 'bluez' | grep 'bluez.alias' | cut -d= -f2 | sed 's/"//g' | sed 's/^ //g' | sed 's/ *$//g')
        echo "$btdevice"
        if [ ! -z "$btdevice" ]; then
            echo "$btdevice" > /tmp/btdevice
        else
            if [ -f /tmp/btdevice ]; then
                rm -f /tmp/btdevice
            fi
        fi
        sleep 1
    done
fi
