#!/bin/bash

# dev mode related utility

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

if [ -f /tmp/usb_debug_mode ] || [ $DEBUG_MODE -eq 1 ]; then
    log_echo "Enable Debug Mode"
    show_screen
    if [ $DEBUG_MODE -eq 1 ]; then
        touch /tmp/usb_debug_mode
        log_echo "Stop default pulseaudio"
        systemctl stop pulseaudio
        log_echo "Start debug pulseaudio"
        systemctl start pulseaudio-debug
    fi
    echo "[${BLUE}${BOLD}ACTIVE${RESET}] Debug Mode Enabled"
    touch /tmp/start_openauto
    show_cursor
fi

exit 0
