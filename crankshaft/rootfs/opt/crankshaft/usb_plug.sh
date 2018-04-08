#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /boot/crankshaft/crankshaft_env.sh

rm /tmp/phone_unplugged
/sbin/shutdown -c
/opt/crankshaft/wake_up.sh
