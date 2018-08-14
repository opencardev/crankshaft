#!/bin/bash

# Try to connect previous paired devices

cs_autoconnect() {
list=""
bt-device -l | grep -E -o '[[:xdigit:]]{2}(:[[:xdigit:]]{2}){5}' | { while read line
do
   list="$list connect $line
"
done
bluetoothctl << EOF
$list
EOF
}
}

# Try 5 attempts to connect
counter=0
while [ $counter -lt 5 ]; do
    sleep 5
    cs_autoconnect
    echo "Loop: $counter"
    ((counter++))
done
