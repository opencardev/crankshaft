#!/bin/bash

DEV_PIN=4
DEV_FILE=/etc/dev_mode_enabled
INVERT_PIN=21

gpio -g mode $DEV_PIN up
gpio -g mode $INVERT_PIN up


if [ `gpio -g read $DEV_PIN` -eq 0 ] ; then
	# the development mode pin is there
	mount -o remount,rw /
	mount -o remount,rw /boot

	# ... but we don't see it being enabled
	if ! [ -f $DEV_FILE ]; then
		/opt/crankshaft/devmode.sh enable
		touch $DEV_FILE
		reboot
	fi
else
	# the development mode pin is not there
	# ... but there is a dev file
	if [ -f $DEV_FILE ]; then
		mount -o remount,rw /
		/opt/crankshaft/devmode.sh disable
		rm -f $DEV_FILE
		reboot
	fi
fi

if [ `gpio -g read $INVERT_PIN` -eq 0 ] ; then
        grep "lcd_rotate=2" /boot/config.txt >/dev/null
        if [ $? -ne 0 ]; then
                # Not there
                mount -o remount,rw /boot
                echo "lcd_rotate=2" >> /boot/config.txt
                reboot
        fi
#this section is commented out
#once you put the invert pin in, then it won't flip back
#else
#       grep "lcd_rotate=2" /boot/config.txt >/dev/null
#       if [ \$? -eq 0 ]; then
#               # There, need to restore
#               mount -o remount,rw /boot
#               sed -i 's/^lcd_rotate=2//g' /boot/config.txt
#               reboot
#       fi
fi

exit 0
