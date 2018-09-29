#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

state=$1

if [ "$state" == "connected" ]; then
    log_echo "Device detected - aa"
    #echo $usbpath > /tmp/android_device
    #echo $model >> /tmp/android_device
    touch /tmp/aa_device
    echo "" > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] AA Device detected!" > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
    /usr/local/bin/crankshaft timers stop
    if [ $ANDROID_PIN -ne 0 ]; then
        log_echo "Setting device gpio pin up"
        sudo /usr/bin/gpio -g mode $ANDROID_PIN up
    fi
fi

if [ "$state" == "disconnected" ]; then
    if [ -f /tmp/aa_device ]; then
        sudo rm /tmp/aa_device
        echo "" > /dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] AA Device disconnected!" > /dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
        sleep 1 # relax time for failsafe while android phone is switching mode
                # while starting google auto
        if [ ! -f /tmp/dev_mode_enabled ] && [ ! -f /tmp/aa_device ]; then
            log_echo "Start timers"
            /usr/local/bin/crankshaft timers start
        fi
        if [ $ANDROID_PIN -ne 0 ]; then
            log_echo "Setting device gpio pin down"
            sudo /usr/bin/gpio -g mode $ANDROID_PIN down
        fi
    fi
fi
