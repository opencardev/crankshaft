#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
source /boot/crankshaft/crankshaft_env.sh

# check gpio pin if activated
if [ $ENABLE_GPIO -eq 1 ] && [ $REARCAM_PIN -ne 0 ]; then
    while true; do
        REARCAM_GPIO=`gpio -g read $REARCAM_PIN`
        if [ $REARCAM_GPIO -ne 1 ] ; then
            touch /tmp/rearcam_enabled
        else
            if [ -f /tmp/rearcam_enabled ]; then
                rm /tmp/rearcam_enabled
            fi
        fi
        sleep 1
    done
fi

exit 0
