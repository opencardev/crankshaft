#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
source /boot/crankshaft/crankshaft_env.sh

if [ $ALLOW_USB_FLASH -eq 1 ]; then

    for _device in /sys/block/*/device; do
        if echo $(readlink -f "$_device")|egrep -q "usb"; then
            _disk=$(echo "$_device" | cut -f4 -d/)
            DEVICE="/dev/${_disk}1"
            PARTITION="${_disk}1"
            LABEL=$(blkid /dev/${PARTITION} | sed 's/.*LABEL="//' | cut -d'"' -f1)
            FSTYPE=$(blkid /dev/${PARTITION} | sed 's/.*TYPE="//' | cut -d'"' -f1)
            if [ $LABEL == "RECORD" ]; then
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] USB-Storage for Dashcam detected - mounting..." > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                if [ $FSTYPE == "fat" ] || [ $FSTYPE == "vfat" ] || [ $FSTYPE == "ext3" ] || [ $FSTYPE == "ext4" ]; then
                    umount ${DEVICE} > /dev/null 2>&1
                    /usr/local/bin/crankshaft filesystem system unlock
                    mkdir -p /media/${LABEL}/RPIDC/AUTOSAVE > /dev/null 2>&1
                    mkdir -p /media/${LABEL}/RPIDC/EVENTS > /dev/null 2>&1
                    chmod 777 /media/${LABEL}/RPIDC -R > /dev/null 2>&1
                    mount -t auto ${DEVICE} /media/${LABEL}
                    /usr/local/bin/crankshaft filesystem system lock
                    if [ $? -eq 0 ]; then
                        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                        echo "[${CYAN}${BOLD} INFO ${RESET}] RECORD mounted." > /dev/tty3
                        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                    else
                        echo "[${RED}${BOLD} FAIL ${RESET}] *******************************************************" > /dev/tty3
                        echo "[${RED}${BOLD} FAIL ${RESET}] RECORD not mounted!" > /dev/tty3
                        echo "[${RED}${BOLD} FAIL ${RESET}] *******************************************************" > /dev/tty3
                    fi
                fi
                continue
            fi

            if [ $FSTYPE == "fat" ] || [ $FSTYPE == "vfat" ] || [ $FSTYPE == "ext3" ] || [ $FSTYPE == "ext4" ]; then
                umount /tmp/${PARTITION} > /dev/null 2>&1
                mkdir /tmp/${PARTITION} > /dev/null 2>&1
                mount -t auto ${DEVICE} /tmp/${PARTITION}
                if [ $? -eq 0 ]; then
                    USB_DEVMODE=$(ls /tmp/${PARTITION} | grep ENABLE_DEVMODE | head -1)
                    if [ ! -z ${USB_DEVMODE} ] && [ ${DEV_MODE} -ne 1 ]; then
                        plymouth --hide-splash > /dev/null 2>&1 # hide the boot splash
                        chvt 3
                        clear > /dev/tty3
                        echo "" > /dev/tty3
                        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                        echo "[${CYAN}${BOLD} INFO ${RESET}] Dev Mode trigger file detected on ${DEVICE} (${LABEL})" > /dev/tty3
                        echo "[${CYAN}${BOLD} INFO ${RESET}]" > /dev/tty3
                        echo "[${CYAN}${BOLD} INFO ${RESET}] Starting in dev mode...${RESET}" > /dev/tty3
                        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                        touch /tmp/usb_dev_mode
                    fi
                    UPDATEZIP=$(ls /tmp/${PARTITION} | grep crankshaft-ng | grep .zip | grep -v md5 | head -1)
                    FLAG=0
                    if [ ! -z ${UPDATEZIP} ]; then
                        UNPACKED=$(unzip -l /tmp/${PARTITION}/${UPDATEZIP} | grep crankshaft-ng | grep .img | grep -v md5 | awk {'print $4'})
                        if [ ! -f /tmp/${PARTITION}/${UNPACKED} ]; then
                            chvt 3
                            clear > /dev/tty3
                            echo "" > /dev/tty3
                            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                            echo "[${CYAN}${BOLD} INFO ${RESET}] Update zip found on ${DEVICE} (${LABEL})" > /dev/tty3
                            echo "[${CYAN}${BOLD} INFO ${RESET}]" > /dev/tty3
                            echo "[${CYAN}${BOLD} INFO ${RESET}] Unpacking file $UNPACKED" > /dev/tty3
                            echo "[${CYAN}${BOLD} INFO ${RESET}]" > /dev/tty3
                            echo "[${CYAN}${BOLD} INFO ${RESET}] Please wait..." > /dev/tty3
                            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                            setterm -cursor on > /dev/tty3
                            setterm -blink on > /dev/tty3
                            rm /tmp/${PARTITION}/*.md5 > /dev/null 2>&1
                            rm /tmp/${PARTITION}/*.img > /dev/null 2>&1
                            unzip -q -o /tmp/${PARTITION}/${UPDATEZIP} -d /tmp/${PARTITION}
                            setterm -cursor off > /dev/tty3
                            setterm -blink off> /dev/tty3
                            FLAG=1
                        fi
                    fi
                    UPDATEFILE=$(ls /tmp/${PARTITION} | grep crankshaft-ng | grep .img | grep -v md5 | head -1)
                    if [ ! -z ${UPDATEFILE} ]; then
                        plymouth --hide-splash > /dev/null 2>&1 # hide the boot splash
                        if [ ${FLAG} -ne 1 ]; then
                            chvt 3
                            clear > /dev/tty3
                        fi
                        echo "" > /dev/tty3
                        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                        echo "[${CYAN}${BOLD} INFO ${RESET}] Update file found on ${DEVICE} (${LABEL})" > /dev/tty3
                        echo "[${CYAN}${BOLD} INFO ${RESET}]" > /dev/tty3
                        if [ -f /etc/crankshaft.build ]; then
                            CURRENT=$(cat /etc/crankshaft.build)
                        else
                            CURRENT=""
                        fi
                        NEW=$(basename ${UPDATEFILE} | cut -d- -f1-3,6 | cut -d. -f1) # use date and hash
                        if [ "$CURRENT" == "$NEW" ]; then
                            echo "[${CYAN}${BOLD} INFO ${RESET}] IMAGE already flashed - ignoring." > /dev/tty3
                            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                            umount /tmp/${PARTITION} > /dev/tty3
                            rmdir /tmp/${PARTITION} > /dev/tty3
                            continue
                        fi
                        echo "[${CYAN}${BOLD} INFO ${RESET}] Checking file ${UPDATEFILE}${RESET}" > /dev/tty3
                        echo "[${CYAN}${BOLD} INFO ${RESET}]" > /dev/tty3
                        echo "[${CYAN}${BOLD} INFO ${RESET}] Please wait..." > /dev/tty3
                        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                        setterm -cursor on > /dev/tty3
                        setterm -blink on > /dev/tty3

                        if [ -f /tmp/${PARTITION}/${UPDATEFILE} ]; then
                            SIZE=$(($(wc -c < "/tmp/${PARTITION}/${UPDATEFILE}") / 1024 / 1024 / 1014))
                        else
                            echo "" > /dev/tty3
                            echo "[${RED}${BOLD} FAIL ${RESET}] *******************************************************" > /dev/tty3
                            echo "[${RED}${BOLD} FAIL ${RESET}] Image check has failed - abort.${RESET}" > /dev/tty3
                            echo "[${RED}${BOLD} FAIL ${RESET}] *******************************************************" > /dev/tty3
                            umount /tmp/${PARTITION} > /dev/tty3
                            rmdir /tmp/${PARTITION} > /dev/tty3
                            continue
                        fi
                        cd /tmp/${PARTITION}
                        MD5SUM=$(md5sum -c ${UPDATEFILE}.md5 | grep OK | cut -d: -f2)
                        if [ ! -z ${MD5SUM} ]; then
                            echo "${RESET}" > /dev/tty3
                            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                            echo "[${CYAN}${BOLD} INFO ${RESET}] Image is consistent -> Preparing flash mode...${RESET}" > /dev/tty3
                            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                            # mount /boot rw to init flash mode
                            mount -o remount,rw /boot
                            mkinitramfs -o /boot/initrd.img > /dev/null 2>&1
                            # cleanup
                            sed -i 's/^initramfs initrd.img followkernel//' /boot/config.txt
                            sed -i 's/^ramfsfile=initrd.img//' /boot/config.txt
                            sed -i 's/^ramfsaddr=-1//' /boot/config.txt
                            sed -i '/./,/^$/!d' /boot/config.txt
                            sed -i 's/rootdelay=10//' /boot/cmdline.txt
                            sed -i 's/initrd=-1//' /boot/cmdline.txt
                            # Set entries
                            echo "initramfs initrd.img followkernel" >> /boot/config.txt
                            echo "ramfsfile=initrd.img" >> /boot/config.txt
                            echo "ramfsaddr=-1" >> /boot/config.txt
                            sed -i 's/splash //' /boot/cmdline.txt
                            sed -i 's/vt.global_cursor_default=0 //' /boot/cmdline.txt
                            sed -i 's/plymouth.ignore-serial-consoles //' /boot/cmdline.txt
                            sed -i 's/$/ rootdelay=10/' /boot/cmdline.txt
                            sed -i 's/$/ initrd=-1/' /boot/cmdline.txt
                            echo "[${CYAN}${BOLD} EXEC ${RESET}] *******************************************************" > /dev/tty3
                            echo "[${CYAN}${BOLD} EXEC ${RESET}] System is ready for flashing - reboot...${RESET}" > /dev/tty3
                            echo "[${CYAN}${BOLD} EXEC ${RESET}] *******************************************************" > /dev/tty3
                            sleep 5
                            reboot
                        else
                            echo "${RESET}" > /dev/tty3
                            echo "[${RED}${BOLD} FAIL ${RESET}] *******************************************************" > /dev/tty3
                            echo "[${RED}${BOLD} FAIL ${RESET}] Image check has failed - abort.${RESET}" > /dev/tty3
                            echo "[${RED}${BOLD} FAIL ${RESET}] *******************************************************" > /dev/tty3
                            umount /tmp/${PARTITION} > /dev/tty3
                            rmdir /tmp/${PARTITION} > /dev/tty3
                            continue
                        fi
                    fi
                fi
                umount /tmp/${PARTITION} > /dev/tty3
                rmdir /tmp/${PARTITION} > /dev/tty3
            fi
        fi
    done
fi

exit 0
