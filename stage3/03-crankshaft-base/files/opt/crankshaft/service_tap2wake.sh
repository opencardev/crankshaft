#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

readlines() {
    while read line; do
        check=$(echo $line | grep "^Event:")
        if [ -n "$check" ]; then
            systemctl stop disconnect.service > /dev/null 2>&1
            systemctl stop shutdown.service > /dev/null 2>&1
            if [ ! -f /tmp/dev_mode_enabled ] && [ ! -f /tmp/android_device ]; then
                systemctl stop disconnect.timer > /dev/null 2>&1
                systemctl stop shutdown.timer > /dev/null 2>&1
                if [ $DISCONNECTION_SCREEN_POWEROFF_DISABLE -eq 0 ]; then
                    systemctl start disconnect.timer
                fi
                if [ $DISCONNECTION_POWEROFF_DISABLE -eq 0 ]; then
                    systemctl start shutdown.timer
                fi
            fi
            sleep 15
            systemctl restart tap2wake
        fi
    done
}

# Kill all possile running evtest's
killall evtest > /dev/null 2>&1

# Start new evtest's on all input devices
cat /proc/bus/input/devices | grep Handler | sed 's/^.*event//' | while read -r input; do
evtest /dev/input/event$input | readlines &
done

exit 0
