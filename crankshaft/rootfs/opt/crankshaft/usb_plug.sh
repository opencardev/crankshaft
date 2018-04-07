#!/bin/bash

rm /tmp/phone_unplugged
/sbin/shutdown -c
/opt/crankshaft/wake_up.sh
