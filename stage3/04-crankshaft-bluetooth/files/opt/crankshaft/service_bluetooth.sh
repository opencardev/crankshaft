#!/bin/bash -e

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

cs_autoconnect() {
list=""
bt-device -l | grep -E -o '[[:xdigit:]]{2}(:[[:xdigit:]]{2}){5}' | while read line
do
    echo -e 'connect '$line'\nquit' | bluetoothctl > /dev/null 2>&1
    check=$(bt-device -i $line | grep Connected | sed 's/ //g' | cut -d: -f2)
    if [ "$check" == "1" ]; then
        exit 0
    fi
done
}

if [ $ENABLE_BLUETOOTH -eq 1 ]; then
    touch /tmp/bluetooth_enabled

    # Set controller in correct mode
    log_echo "Init bluetooth adapter defaults"
    sudo bt-adapter --set Powered 1
    sudo bt-adapter --set Discoverable 1
    sudo bt-adapter --set DiscoverableTimeout 0
    if [ $ENABLE_PAIRABLE -eq 1 ]; then
        log_echo "Set bluetooth adapter pairable for 120 seconds"
        /usr/local/bin/crankshaft bluetooth pairable
    fi
    # Try 5 attempts to connect
    counter=0
    while [ $counter -lt 5 ] && [ ! -f /tmp/btdevice ]; do
        log_echo "Bluetooth auto connect attempt: $counter"
        cs_autoconnect
        sleep 5
        counter=$((counter+1))
    done
fi
