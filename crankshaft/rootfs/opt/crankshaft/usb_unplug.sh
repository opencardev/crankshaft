#!/bin/bash

touch /tmp/phone_unplugged
sleep 30
if [ -f /tmp/phone_unplugged ]; then
	/opt/crankshaft/sleep.sh
	/sbin/shutdown --poweroff 180
fi
