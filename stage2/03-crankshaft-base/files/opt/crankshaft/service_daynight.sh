#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

# service can only trigger if rtc is set and enabled in crankshaft env
if [ $RTC_DAYNIGHT -eq 1 ] && [ ! -f /tmp/auto_brightness_active ] && [ $DAYNIGHT_PIN -eq 0 ]; then
    if [ ! -z $1 ]; then
        if [ $1 == "day" ] && [ -f /tmp/night_mode_enabled ]; then
            log_echo "Restore brightness day"
            sudo rm /tmp/night_mode_enabled
            crankshaft brightness restore
        fi
        if [ $1 == "night" ] && [ ! -f /tmp/night_mode_enabled ]; then
            log_echo "Restore brightness night"
            touch /tmp/night_mode_enabled
            chmod 666 /tmp/night_mode_enabled
            crankshaft brightness restore
        fi
    fi
fi

# exec only app triggered events - ignore service triggered
if [ ! -z $1 ] && [ ! -z $2 ]; then
    if [ $1 == "app" ] && [ $2 == "day" ] && [ -f /tmp/night_mode_enabled ]; then
        log_echo "Save brightness night"
        sudo rm /tmp/night_mode_enabled
        log_echo "Restore brightness day"
        crankshaft brightness restore
    fi
    if [ $1 == "app" ] && [ $2 == "night" ] && [ ! -f /tmp/night_mode_enabled ]; then
        log_echo "Save brightness day"
        touch /tmp/night_mode_enabled
        chmod 666 /tmp/night_mode_enabled
        log_echo "Restore brightness night"
        crankshaft brightness restore
    fi
fi

exit 0
