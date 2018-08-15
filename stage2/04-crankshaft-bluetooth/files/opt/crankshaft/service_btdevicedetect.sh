#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
if [ -f /boot/crankshaft/crankshaft_env.sh ]; then
    source /boot/crankshaft/crankshaft_env.sh
fi

if [ $ENABLE_BLUETOOTH -eq 1 ]; then
    # Check loop for connected btdevice
    while true; do
        export connected=0
        export btdevice=
        bt-device -l | grep -e '(' | grep -e ':' | cut -d'(' -f2 | cut -d')' -f1 | while read paired; do
            device=$(bt-device -i  $paired | grep -e 'Name:' | cut -d':' -f2 | sed 's/^ //g' | sed 's/ *$//g')
            state=$(bt-device -i  $paired | grep -e 'Connected:' | cut -d':' -f2 |  sed 's/^ //g' | sed 's/ *$//g')
            if [ $state -eq 1 ]; then
                echo "${device}" > /tmp/new_btdevice
            fi
        done
        if [ -f /tmp/new_btdevice ]; then
            mv /tmp/new_btdevice /tmp/btdevice
        else
            if [ -f /tmp/btdevice ]; then
                rm -f /tmp/btdevice
            fi
        fi
        sleep 1
    done
fi
