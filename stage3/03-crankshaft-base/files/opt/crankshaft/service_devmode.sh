#!/bin/bash

# Only start if debugging is not enabled

if [ ! -f /tmp/usb_debug_mode ]; then

    # dev mode related utility
    source /opt/crankshaft/crankshaft_default_env.sh
    source /opt/crankshaft/crankshaft_system_env.sh

    # Check gpio pin if activated
    if [ $ENABLE_GPIO -eq 1 ] && [ $DEV_PIN -ne 0 ]; then
        DEV_MODE_GPIO=`gpio -g read $DEV_PIN`
    else
        DEV_MODE_GPIO=1 # 1 = untriggered
    fi

    if [ $DEV_MODE != 0 ] || [ $DEV_MODE_GPIO != 1 ] || [ -f /tmp/usb_dev_mode ]; then
        if [ $DEV_MODE_APP != 1 ] ; then
            log_echo "Enable Dev Mode Shell"
            # dev mode without start of openauto
            mount -o remount,rw /
            mount -o remount,rw /boot
            touch /tmp/dev_mode_enabled
            show_screen
            echo "[${RED}${BOLD}ACTIVE${RESET}] Dev Mode Enabled - Shell"
        else
            log_echo "Enable Dev Mode OpenAuto"
            # dev mode with start of openauto
            mount -o remount,rw /
            mount -o remount,rw /boot
            touch /tmp/dev_mode_enabled
            show_screen
            echo "[${RED}${BOLD}ACTIVE${RESET}] Dev Mode Enabled - OpenAuto"
            touch /tmp/start_openauto
        fi
        log_echo "Stop watchdog.service"
        systemctl stop watchdog
        EXFAT=`dkms status exfat | cut -d: -f2 | sed 's/ //g'`
        if [ "$EXFAT" != "installed" ] ; then
            echo "[${RED}${BOLD} FAIL ${RESET}] DKMS module exfat missing - installing..."
            sudo dkms autoinstall
        else
            echo "[${CYAN}${BOLD}  OK  ${RESET}] DKMS module exfat is present"
        fi
        show_cursor
    else
        touch /tmp/start_openauto
    fi
fi

exit 0
