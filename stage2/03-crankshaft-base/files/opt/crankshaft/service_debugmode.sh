#!/bin/bash

# dev mode related utility

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
source /boot/crankshaft/crankshaft_env.sh

if [ -f /tmp/usb_debug_mode ]; then
    show_screen
    echo "[${BLUE}${BOLD}ACTIVE${RESET}] Debug Mode Enabled"
    /usr/local/bin/crankshaft timers start &
    touch /tmp/start_openauto
    systemctl start wifisetup.service
    systemctl start dhcpcd.service > /dev/null 2>&1
    systemctl start networking.service
    show_cursor
fi

exit 0
