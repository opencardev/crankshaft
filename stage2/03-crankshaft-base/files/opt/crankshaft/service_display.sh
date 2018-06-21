#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
source /boot/crankshaft/crankshaft_env.sh

if [ -f $BRIGHTNESS_FILE ]; then
    chmod 666 $BRIGHTNESS_FILE
fi

# Auto detect display if enabled in config
if [ $DISPLAY_AUTO_DETECT -eq 1 ]; then
    /usr/local/bin/crankshaft display autodetect
fi

# Check if we need to rotate
flipset=`grep '^lcd_rotate=' /boot/config.txt`

# check gpio pin if activated
if [ $ENABLE_GPIO -eq 1 ]; then
    INVERT_MODE_GPIO=`gpio -g read $INVERT_PIN`
else
    INVERT_MODE_GPIO=1 # 1 = untriggered
fi

if [ $FLIP_SCREEN -ne 0 ] || [ $INVERT_MODE_GPIO -ne 1 ] ; then
    if [ -z $flipset ]; then
        # Not there
        mount -o remount,rw /
        mount -o remount,rw /boot
        plymouth --hide-splash > /dev/null 2>&1 # hide the boot splash
        chvt 3
        echo "[${RED}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        echo "[${RED}${BOLD} INFO ${RESET}] Display rotation triggered - Setting up..." >/dev/tty3
        echo "[${RED}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        sed -i 's/^# Display rotation.*//' /boot/config.txt
        sed -i 's/^lcd_rotate=.*//' /boot/config.txt
        sed -i '/./,/^$/!d' /boot/config.txt
        sh -c "echo '' >> /boot/config.txt"
        sh -c "echo '# Display rotation' >> /boot/config.txt"
        sh -c "echo 'lcd_rotate=2' >> /boot/config.txt"
        sync
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] Display rotation activated" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        sleep 5
        reboot
    fi
else
    if [ ! -z $flipset ]; then
        # there
        mount -o remount,rw /
        mount -o remount,rw /boot
        plymouth --hide-splash > /dev/null 2>&1 # hide the boot splash
        chvt 3
        echo "[${RED}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        echo "[${RED}${BOLD} INFO ${RESET}] Display rotation not triggered - Removing..." >/dev/tty3
        echo "[${RED}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        sed -i 's/^# Display rotation.*//' /boot/config.txt
        sed -i 's/^lcd_rotate=.*//' /boot/config.txt
        sed -i '/./,/^$/!d' /boot/config.txt
        sync
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] Display rotation removed" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        sleep 5
        reboot
    fi
fi

# restore the brightness if possible
/usr/local/bin/crankshaft brightness restore

exit 0
