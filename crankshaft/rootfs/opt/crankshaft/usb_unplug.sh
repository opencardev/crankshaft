#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /boot/crankshaft/crankshaft_env.sh

touch /tmp/phone_unplugged

sleep ${DISCONNECTION_SCREEN_POWEROFF_SECS}

if [ -f /tmp/phone_unplugged ]; then
    /opt/crankshaft/sleep.sh
    if [ ${DISCONNECTION_POWEROFF_MINS} -gt 0 ]; then
	# Skip if dev mode is enabled by $DEV_MODE (1=enabled) or $DEV_PIN (0=enabled | 0 = low = closed)
	if [ $DEV_MODE -eq 0 ] && [ `gpio -g read $DEV_PIN` -eq 1 ]; then
	    /sbin/shutdown --poweroff ${DISCONNECTION_POWEROFF_MINS}
	fi
    fi
fi
