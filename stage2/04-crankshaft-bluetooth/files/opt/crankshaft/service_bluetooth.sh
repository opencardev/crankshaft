#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

cs_autoconnect() {
list=""
bt-device -l | grep -E -o '[[:xdigit:]]{2}(:[[:xdigit:]]{2}){5}' | { while read line
do
   list="$list connect $line"
done
bluetoothctl << EOF
$list
EOF
}
}

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

    # Try 5 attempts to connect
    counter=0
    while [ $counter -lt 5 ] && [ ! -f /tmp/btdevice ]; do
        sleep 5
        cs_autoconnect > /dev/null 2>&1
        echo "Loop: $counter"
        counter=$((counter+1))
    done
fi
