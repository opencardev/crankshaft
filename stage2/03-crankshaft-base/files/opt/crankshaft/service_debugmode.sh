#!/bin/bash

# dev mode related utility

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
if [ -f /boot/crankshaft/crankshaft_env.sh ]; then
    source /boot/crankshaft/crankshaft_env.sh
fi

if [ -f /tmp/usb_debug_mode ] || [ $DEBUG_MODE -eq 1 ]; then
    log_echo "Enable Debug Mode"
    #show_screen
    if [ $DEBUG_MODE -eq 1 ]; then
        touch /tmp/usb_debug_mode
    fi
    echo "[${BLUE}${BOLD}ACTIVE${RESET}] Debug Mode Enabled"
    log_echo "Start timers"
    /usr/local/bin/crankshaft timers start &
    touch /tmp/start_openauto
    log_echo "Start wifisetup.service"
    systemctl start wifisetup.service
    log_echo "Start dhcpcd.service"
    systemctl start dhcpcd.service > /dev/null 2>&1
    log_echo "Start networking.service"
    systemctl start networking.service
    show_cursor
fi

exit 0
