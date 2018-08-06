#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
source /boot/crankshaft/crankshaft_env.sh
IGN_COUNTER=0

# check gpio pin if activated
if [ $REARCAM_PIN -ne 0 ] || [ $IGNITION_PIN -ne 0 ]; then
    while true; do
        if [ $REARCAM_PIN -ne 0 ]; then
            REARCAM_GPIO=`gpio -g read $REARCAM_PIN`
            if [ $REARCAM_GPIO -ne 1 ] ; then
                touch /tmp/rearcam_enabled
            else
                if [ -f /tmp/rearcam_enabled ]; then
                    rm /tmp/rearcam_enabled
                fi
            fi
        fi
        if [ $IGNITION_PIN -ne 0 ]; then
            IGNITION_GPIO=`gpio -g read $IGNITION_PIN`
            if [ $IGNITION_GPIO -ne 0 ] ; then
                IGN_COUNTER=$((IGN_COUNTER+1))
                if [ $IGN_COUNTER -gt $IGNITION_DELAY ]; then
                    touch /tmp/external_exit
                fi
            else
                IGN_COUNTER=0
            fi
        fi
        sleep 1
    done
fi

exit 0
