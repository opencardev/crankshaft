#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /boot/crankshaft/crankshaft_env.sh


gpio -g mode $DEV_PIN up
gpio -g mode $INVERT_PIN up
gpio -g mode $X11_PIN up

/opt/crankshaft/devmode.sh autoset

if [ -f $BRIGHTNESS_FILE ]; then
	chmod 666 $BRIGHTNESS_FILE
fi

# restore the brightness if possible
/opt/crankshaft/brightness.sh restore

if [ $FLIP_SCREEN -ne 0 ] || [ `gpio -g read $INVERT_PIN` -eq 0 ] ; then
        grep "lcd_rotate=2" /boot/config.txt >/dev/null
        if [ $? -ne 0 ]; then
                # Not there
                mount -o remount,rw /boot
                echo "lcd_rotate=2" >> /boot/config.txt
                reboot
        fi
fi


# magic to make stuff work

cp /boot/crankshaft/openauto.ini /tmp/openauto.ini

mkdir -p /tmp/.local
mkdir -p /tmp/.config

chown pi:pi /tmp/.local
chown pi:pi /tmp/.config
chown pi:pi /tmp/openauto.ini

if [ ${NO_CONNECTION_POWEROFF_MINS} -gt 0 ]; then
	# Skip if dev mode is enabled by $DEV_MODE (1=enabled) or $DEV_PIN (0=enabled | 0 = low = closed)
	if [ $DEV_MODE -eq 0 ] && [ `gpio -g read $DEV_PIN` -eq 1 ]; then
	    /sbin/shutdown --poweroff ${NO_CONNECTION_POWEROFF_MINS}
	fi
fi

exit 0
