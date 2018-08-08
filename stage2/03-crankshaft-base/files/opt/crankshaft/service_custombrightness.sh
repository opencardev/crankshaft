#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
if [ -f /boot/crankshaft/crankshaft_env.sh ]; then
    source /boot/crankshaft/crankshaft_env.sh
fi

oldvalue=0

while true; do
    if [ -f /tmp/custombrightness ];then
        currentvalue=$(cat /tmp/custombrightness)
        if [ $currentvalue -ne $oldvalue ]; then
            ${CUSTOM_BRIGHTNESS_COMMAND} $currentvalue
            oldvalue=$currentvalue
        fi
    fi
    sleep 0.25
done
