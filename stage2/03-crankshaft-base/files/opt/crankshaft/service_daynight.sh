#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
source /boot/crankshaft/crankshaft_env.sh

# service can only trigger if rtc is set and enabled in crankshaft env
if [ $RTC_DAYNIGHT -eq 1 ]; then
    if [ ! -z $1 ]; then
        if [ $1 == "day" ] && [ -f /tmp/night_mode_enabled ]; then
            sudo rm /tmp/night_mode_enabled
	    crankshaft brightness restore
        fi
        if [ $1 == "night" ] && [ ! -f /tmp/night_mode_enabled ]; then
            touch /tmp/night_mode_enabled
	    chmod 666 /tmp/night_mode_enabled
	    crankshaft brightness restore
        fi
    fi
fi

# exec only app triggered events - ignore service triggered
if [ ! -z $1 ] && [ ! -z $2 ]; then
    if [ $1 == "app" ] && [ $2 == "day" ] && [ -f /tmp/night_mode_enabled ]; then
	crankshaft brightness save
        sudo rm /tmp/night_mode_enabled
	crankshaft brightness restore
    fi
    if [ $1 == "app" ] && [ $2 == "night" ] && [ ! -f /tmp/night_mode_enabled ]; then
	crankshaft brightness save
        touch /tmp/night_mode_enabled
	chmod 666 /tmp/night_mode_enabled
	crankshaft brightness restore
    fi
fi

exit 0
