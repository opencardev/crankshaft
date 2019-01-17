#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

addremove=$1
model=$2
usbpath=$3

if [ $addremove == "add" ] && [ "$usbpath" != "" ]; then
    sleep 1
    echo $usbpath > /tmp/android_device
    echo $model >> /tmp/android_device
    echo "" > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] Device detected!" > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] Model: $model" > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] Path: $usbpath" > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
    log_echo "Device detected - $usbpath - $model"
    /usr/local/bin/crankshaft timers stop
    if [ $ANDROID_PIN -ne 0 ]; then
        log_echo "Setting device gpio pin up"
        sudo /usr/bin/gpio -g mode $ANDROID_PIN up
    fi
fi

if [ "$addremove" == "remove" ] && [ "$usbpath" != "" ]; then
    if [ -f /tmp/android_device ]; then
        CHECK=$(cat /tmp/android_device | grep $usbpath)
        if [ ! -z $CHECK ]; then
            sudo rm /tmp/android_device
            echo "" > /dev/tty3
            echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
            echo "[${RED}${BOLD} WARN ${RESET}] Device removed!" > /dev/tty3
            echo "[${RED}${BOLD} WARN ${RESET}] Model: $model" > /dev/tty3
            echo "[${RED}${BOLD} WARN ${RESET}] Path: $usbpath" > /dev/tty3
            echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
            log_echo "Device removed - $usbpath - $model"
            sleep 1 # relax time for failsafe while android phone is switching mode
                    # while starting google auto
            if [ ! -f /tmp/dev_mode_enabled ] && [ ! -f /tmp/android_device ] && [ ! -f /tmp/aa_device ]; then
                log_echo "Start timers"
                /usr/local/bin/crankshaft timers start
            fi
            if [ $ANDROID_PIN -ne 0 ]; then
                log_echo "Setting device gpio pin down"
                sudo /usr/bin/gpio -g mode $ANDROID_PIN down
            fi
        fi
    fi
fi
