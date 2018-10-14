#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

if [ $ENABLE_BLUETOOTH -eq 1 ]; then
    touch /tmp/button_bluetooth_visible

    # Set controller in correct mode
    sudo bt-adapter --set Powered 1
    sudo bt-adapter --set DiscoverableTimeout 0
    sudo bt-adapter --set Discoverable 1
    sudo bt-adapter --set PairableTimeout 120
    if [ $ENABLE_PAIRABLE -eq 1 ]; then
        sudo bt-adapter --set Pairable 1
    else
        sudo bt-adapter --set Pairable 0
    fi
fi
