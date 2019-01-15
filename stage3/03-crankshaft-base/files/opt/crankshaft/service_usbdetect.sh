#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

CSSTORAGE_DETECTED=0

for FSMOUNTPOINT in $(ls -d /media/USBDRIVES/*); do
    DEVICE="/dev/$(basename ${FSMOUNTPOINT})"
    PARTITION=$(basename ${DEVICE})

    if [ "$PARTITION" == "CSSTORAGE" ]; then
        echo "" > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] CSSTORAGE detected" > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
        log_echo "CSSTORAGE detected"
        /usr/local/bin/crankshaft filesystem system unlock
        # dashcam related
        mkdir -p /media/USBDRIVES/$PARTITION/RPIDC/AUTOSAVE > /dev/null 2>&1
        mkdir -p /media/USBDRIVES/$PARTITION/RPIDC/EVENTS > /dev/null 2>&1
        # kodi related
        mkdir -p /media/USBDRIVES/$PARTITION/KODI > /dev/null 2>&1
        rm -rf /home/pi/.kodi > /dev/null 2>&1
        ln -s /media/USBDRIVES/$PARTITION/KODI /home/pi/.kodi
        chmod 777 /home/pi/.kodi > /dev/null 2>&1
        # Allow all users rw to CSSTORAGE and subfolders/files
        chmod -R 777 /media/USBDRIVES/$PARTITION > /dev/null 2>&1
        chmown -R pi:pi /home/pi/.kodi > /dev/null 2>&1
        /usr/local/bin/crankshaft filesystem system lock
        CSSTORAGE_DETECTED=1
        # set correct device for csstorage
        DEVICE=$(mount | grep CSSTORAGE | awk {'print $1'})
    fi

    LABEL=$(blkid ${DEVICE} | sed 's/.*LABEL="//' | cut -d'"' -f1 | sed 's/ //g')
    FSTYPE=$(blkid ${DEVICE} | sed 's/.*TYPE="//' | cut -d'"' -f1)

    # Check for trigger files excluding CSSTORAGE
    if [ "$PARTITION" != "CSSTORAGE" ]; then
        USB_DEBUGMODE=$(ls /media/USBDRIVES/${PARTITION} | grep ENABLE_DEBUG | head -1)
        if [ ! -z ${USB_DEBUGMODE} ]; then
            show_clear_screen
            echo "" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Debug Mode trigger file detected on ${DEVICE} (${LABEL})" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}]" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Starting in debug mode...${RESET}" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            log_echo "${DEVICE} - Debug trigger file detected"
            touch /tmp/usb_debug_mode
        fi

        USB_DEVMODE=$(ls /media/USBDRIVES/${PARTITION} | grep ENABLE_DEVMODE | head -1)
        if [ ! -z ${USB_DEVMODE} ] && [ ${DEV_MODE} -ne 1 ] && [ -z ${USB_DEBUGMODE} ]; then
            show_clear_screen
            echo "" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Dev Mode trigger file detected on ${DEVICE} (${LABEL})" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}]" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Starting in dev mode...${RESET}" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            log_echo "${DEVICE} - Dev Mode trigger file detected"
            touch /tmp/usb_dev_mode
        fi
    fi

    if [ $ALLOW_USB_FLASH -eq 1 ]; then
        UPDATEZIP=$(ls -Art /media/USBDRIVES/${PARTITION} | grep crankshaft-ng | grep .zip | grep -v md5 | grep -v ^._ | tail -1)
        FLAG=0
        if [ ! -z ${UPDATEZIP} ]; then
            UNPACKED=$(unzip -l /media/USBDRIVES/${PARTITION}/${UPDATEZIP} | grep crankshaft-ng | grep .img | grep -v md5 | grep -v ^._ | awk {'print $4'})
            if [ ! -f /media/USBDRIVES/${PARTITION}/${UNPACKED} ]; then
                show_clear_screen
                echo "" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] Update zip found on ${DEVICE} (${LABEL})" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}]" > /dev/tty3
                log_echo "Update zip found on ${DEVICE} (${LABEL})"
                if [ -f /etc/crankshaft.build ] && [ -f /etc/crankshaft.date ]; then
                    CURRENT="$(cat /etc/crankshaft.date)-$(cat /etc/crankshaft.build)"
                else
                    CURRENT=""
                fi
                NEW=$(basename ${UPDATEZIP} | cut -d- -f1-3,6 | cut -d. -f1) # use date and hash
                FORCEFLASH=$(ls /media/USBDRIVES/${PARTITION} | grep FORCE_FLASH | head -1)
                if [ "$CURRENT" == "$NEW" ] && [ -z $FORCEFLASH ]; then
                    echo "[${CYAN}${BOLD} INFO ${RESET}] ZIP VERSION already flashed - skip unpacking." > /dev/tty3
                    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                    log_echo "ZIP VERSION already flashed - skip unpacking."
                    continue
                fi
                echo "[${CYAN}${BOLD} INFO ${RESET}] Unpacking file $UNPACKED" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}]" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] Please wait..." > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                log_echo "Unpacking file $UNPACKED"
                show_cursor
                sudo mount -o remount,rw ${DEVICE}
                rm /media/USBDRIVES/${PARTITION}/*.md5 > /dev/null 2>&1
                rm /media/USBDRIVES/${PARTITION}/*.img > /dev/null 2>&1
                /bin/echo "n" | unzip -q -o /media/USBDRIVES/${PARTITION}/${UPDATEZIP} -d /media/USBDRIVES/${PARTITION}
                hide_cursor
                FLAG=1
            fi
        fi
        UPDATEFILE=$(ls -Art /media/USBDRIVES/${PARTITION} | grep crankshaft-ng | grep .img | grep -v md5 | grep -v ^._ | tail -1)
        if [ ! -z ${UPDATEFILE} ]; then
            if [ ${FLAG} -ne 1 ]; then
                show_clear_screen
            else
                show_screen
            fi
            echo "" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Update file found on ${DEVICE} (${LABEL})" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}]" > /dev/tty3
            log_echo "Update file found on ${DEVICE} (${LABEL})"
            if [ -f /etc/crankshaft.build ] && [ -f /etc/crankshaft.date ]; then
                CURRENT="$(cat /etc/crankshaft.date)-$(cat /etc/crankshaft.build)"
            else
                CURRENT=""
            fi
            NEW=$(basename ${UPDATEFILE} | cut -d- -f1-3,6 | cut -d. -f1) # use date and hash
            FORCEFLASH=$(ls /media/USBDRIVES/${PARTITION} | grep FORCE_FLASH | head -1)
            if [ "$CURRENT" == "$NEW" ] && [ -z $FORCEFLASH ]; then
                echo "[${CYAN}${BOLD} INFO ${RESET}] IMAGE already flashed - ignoring." > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                log_echo "IMAGE already flashed - ignoring."
                if [ "${PARTITION}" == "CSSTORAGE" ]; then
                    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                    echo "[${CYAN}${BOLD} INFO ${RESET}] Cleanup old flash files on CSSTORAGE ..." > /dev/tty3
                    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                    log_echo "Cleanup old flash files on CSSTORAGE ..."
                    sudo rm /media/USBDRIVES/${PARTITION}/*.zip > /dev/null 2>&1
                    sudo rm /media/USBDRIVES/${PARTITION}/*.md5 > /dev/null 2>&1
                    sudo rm /media/USBDRIVES/${PARTITION}/*.img > /dev/null 2>&1
                fi
                continue
            fi
            echo "[${CYAN}${BOLD} INFO ${RESET}] Checking file ${UPDATEFILE}${RESET}" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}]" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Please wait..." > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            log_echo "Checking file ${UPDATEFILE}${RESET}"
            show_cursor
            if [ -f /media/USBDRIVES/${PARTITION}/${UPDATEFILE} ]; then
                SIZE=$(($(wc -c < "/media/USBDRIVES/${PARTITION}/${UPDATEFILE}") / 1024 / 1024 / 1014))
            else
                echo "" > /dev/tty3
                echo "[${RED}${BOLD} FAIL ${RESET}] *******************************************************" > /dev/tty3
                echo "[${RED}${BOLD} FAIL ${RESET}] Image check has failed - abort.${RESET}" > /dev/tty3
                echo "[${RED}${BOLD} FAIL ${RESET}] *******************************************************" > /dev/tty3
                log_echo "Image check has failed - abort."
                continue
            fi
            cd /media/USBDRIVES/${PARTITION}
            MD5SUM=$(md5sum -c ${UPDATEFILE}.md5 | grep OK | cut -d: -f2)
            if [ ! -z ${MD5SUM} ]; then
                echo "${RESET}" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}]" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] Image is consistent -> Preparing flash mode...${RESET}" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}]" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                # mount /boot rw to init flash mode
                mount -o remount,rw /boot
                mkinitramfs -o /boot/initrd.img > /dev/null 2>&1
                # cleanup
                sed -i 's/^# Initramfs params for flashsystem//' /boot/config.txt
                sed -i 's/^initramfs initrd.img followkernel//' /boot/config.txt
                sed -i 's/^ramfsfile=initrd.img//' /boot/config.txt
                sed -i 's/^ramfsaddr=-1//' /boot/config.txt
                sed -i 's/rootdelay=10//' /boot/cmdline.txt
                sed -i 's/initrd=-1//' /boot/cmdline.txt
                sed -i '/./,/^$/!d' /boot/config.txt
                # Set entries
                echo "" >> /boot/config.txt
                echo "# Initramfs params for flashsystem" >> /boot/config.txt
                echo "initramfs initrd.img followkernel" >> /boot/config.txt
                echo "ramfsfile=initrd.img" >> /boot/config.txt
                echo "ramfsaddr=-1" >> /boot/config.txt
                sed -i 's/splash //' /boot/cmdline.txt
                sed -i 's/vt.global_cursor_default=0 //' /boot/cmdline.txt
                sed -i 's/plymouth.ignore-serial-consoles //' /boot/cmdline.txt
                sed -i 's/$/ rootdelay=10/' /boot/cmdline.txt
                sed -i 's/$/ initrd=-1/' /boot/cmdline.txt
                # remove possible existing force trigger to prevent flash loop
                sudo mount -o remount,rw ${DEVICE} > /dev/null 2>&1
                rm /media/USBDRIVES/${PARTITION}/FORCE_FLASH > /dev/null 2>&1
                echo "${RESET}" > /dev/tty3
                echo "[${GREEN}${BOLD} EXEC ${RESET}] *******************************************************" > /dev/tty3
                echo "[${GREEN}${BOLD} EXEC ${RESET}]" > /dev/tty3
                echo "[${GREEN}${BOLD} EXEC ${RESET}] System is ready for flashing - reboot...${RESET}" > /dev/tty3
                echo "[${GREEN}${BOLD} EXEC ${RESET}]" > /dev/tty3
                echo "[${GREEN}${BOLD} EXEC ${RESET}] *******************************************************" > /dev/tty3
                sudo sync
                sudo umount ${DEVICE} > /dev/null 2>&1
                sleep 5
                reboot
            else
                echo "${RESET}" > /dev/tty3
                echo "[${RED}${BOLD} FAIL ${RESET}] *******************************************************" > /dev/tty3
                echo "[${RED}${BOLD} FAIL ${RESET}]" > /dev/tty3
                echo "[${RED}${BOLD} FAIL ${RESET}] Image check has failed - abort. (CRC)${RESET}" > /dev/tty3
                echo "[${RED}${BOLD} FAIL ${RESET}]" > /dev/tty3
                echo "[${RED}${BOLD} FAIL ${RESET}] *******************************************************" > /dev/tty3
                log_echo "Image check has failed - abort. (CRC)"
                continue
            fi
        fi
    fi
done

# No external storage available - remove lost local folders / files
if [ $CSSTORAGE_DETECTED -eq 0 ]; then
    /usr/local/bin/crankshaft filesystem system unlock
    rm -rf /media/CSSTORAGE > /dev/null 2>&1
    rm -rf /home/pi/.kodi > /dev/null 2>&1
    /usr/local/bin/crankshaft filesystem system lock
fi

exit 0
