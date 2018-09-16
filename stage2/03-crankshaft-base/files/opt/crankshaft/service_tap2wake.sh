#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

readlines() {
    while read line; do
        check=$(echo $line | grep "^Event:")
        if [ -n "$check" ]; then
            systemctl stop disconnect.service
            if [ ! -f /tmp/dev_mode_enabled ] && [ ! -f /tmp/android_device ]; then
                systemctl stop disconnect.timer
                if [ $DISCONNECTION_SCREEN_POWEROFF_DISABLE -eq 0 ]; then
                    systemctl start disconnect.timer
                fi
            fi
            sleep 30
            systemctl restart tap2wake
        fi
    done
}

# Kill all possile running evtest's
killall evtest

# Start new evtest's on all input devices
cat /proc/bus/input/devices | grep Handler | sed 's/^.*event//' | while read -r input; do
evtest /dev/input/event$input | readlines &
done

exit 0
