#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

if [ $ENABLE_BLUETOOTH -eq 1 ]; then
    # Check loop for connected btdevice
    while true; do
        bt-device -l | grep -e '(' | grep -e ':' | cut -d'(' -f2 | cut -d')' -f1 | while read paired; do
            info=$(bt-device --info=$paired | grep -e 'Name:' -e 'Connected:' | cut -d: -f2 | sed 's/^ *//g' | sed 's/ *$//g' | tr '\n' '#')
            device=$(echo $info | cut -d# -f1)
            state=$(echo $info | cut -d# -f2)
            if [ $state -eq 1 ]; then
                if [ ! -f /tmp/btdevice ]; then
                    echo "${device}" > /tmp/btdevice
                    log_echo "Bluetooth device connected: ${device} -> stop timers"
                    /usr/local/bin/crankshaft timers stop
                fi
            else
                rm -f /tmp/btdevice
                log_echo "Bluetooth device removed -> start timers"
                /usr/local/bin/crankshaft timers start
            fi
        done
        sleep 5
    done
fi
