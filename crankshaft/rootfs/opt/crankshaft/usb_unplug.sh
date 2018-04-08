#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /boot/crankshaft/crankshaft_env.sh

touch /tmp/phone_unplugged

sleep ${DISCONNECTION_SCREEN_POWEROFF_SECS}

if [ -f /tmp/phone_unplugged ]; then
	/opt/crankshaft/sleep.sh
	/sbin/shutdown --poweroff ${DISCONNECTION_POWEROFF_MINS}
fi
