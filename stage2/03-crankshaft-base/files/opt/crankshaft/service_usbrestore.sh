#!/bin/bash +e

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

if [ ! -f /etc/cs_resize_done ]; then
    show_clear_screen
    show_cursor
    echo "${RESET}" > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] Partition and Filesystem not resized - resizing..." > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
    /usr/local/bin/crankshaft resize
    sync
    reboot
fi

SERIAL=$(cat /proc/cpuinfo | grep Serial | cut -d: -f2 | sed 's/ //g')

if [ ! -f /etc/cs_backup_restore_done ]; then
    if [ ! -f /etc/cs_first_start_done ]; then
        show_clear_screen
        # give udev time to finish mounts
        sleep 10
    fi
    show_screen
    show_cursor
    echo "${RESET}" > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] Checking for cs backups to restore..." > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
    log_echo "Checking for cs backups to restore..."
    for FSMOUNTPOINT in $(ls -d /media/USBDRIVES/*); do
        DEVICE="/dev/$(basename ${FSMOUNTPOINT})"
        if [ "$DEVICE" == "/dev/CSSTORAGE" ]; then
            DEVICE=$(mount | grep CSSTORAGE | awk {'print $1'})
        fi
        LABEL=$(blkid ${DEVICE} | sed 's/.*LABEL="//' | cut -d'"' -f1 | sed 's/ //g')
        FSTYPE=$(blkid ${DEVICE} | sed 's/.*TYPE="//' | cut -d'"' -f1)
        echo "${RESET}" > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] Detected  Drive: ${DEVICE}" > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] Partition Label: ${LABEL}" > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] Part Filesystem: ${FSTYPE}" > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3

        echo "${RESET}" > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] Checking if backup folder is present..." > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
        log_echo "Checking for cs backups to restore..."
        log_echo "Checking if backup folder is present on ${DEVICE} (${LABEL} / ${FSTYPE}) ..."
        sleep 2
        if [ -d ${FSMOUNTPOINT}/cs-backup/${SERIAL} ]; then
            show_screen
            show_cursor
            echo "${RESET}" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Backup found on $DEVICE (${LABEL}) - restoring backup..." > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            log_echo "Backup found on $DEVICE (${LABEL}) - restoring backup ..."
            echo "" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Check /boot ..." > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            umount /dev/mmcblk0p1
            fsck -f -y /dev/mmcblk0p1 > /dev/null 2>&1
            mount /dev/mmcblk0p1 /boot
            touch /tmp/keeprw
            mount -o remount,rw /
            # restore files
            cp -r -f ${FSMOUNTPOINT}/cs-backup/${SERIAL}/boot/. /boot/ > /dev/null 2>&1
            cp -r -f ${FSMOUNTPOINT}/cs-backup/${SERIAL}/etc/. /etc/ > /dev/null 2>&1
            cp -r -f ${FSMOUNTPOINT}/cs-backup/${SERIAL}/etc/X11/xorg.conf.d/. /etc/ > /dev/null 2>&1
            cp -r -f ${FSMOUNTPOINT}/cs-backup/${SERIAL}/etc/pulse/. /etc/pulse/ > /dev/null 2>&1
            cp -r -f ${FSMOUNTPOINT}/cs-backup/${SERIAL}/etc/hostapd/. /etc/hostapd/ > /dev/null 2>&1
            cp -r -f ${FSMOUNTPOINT}/cs-backup/${SERIAL}/etc/plymouth/. /etc/plymouth/ > /dev/null 2>&1
            # check and setup client.conf for system wide usage
            sed -i 's/.*Make sure client is correct configured for system wide usage.*//g' /etc/pulse/client.conf
            sed -i 's/.*default-server =.*//g' /etc/pulse/client.conf
            sed -i 's/.*autospawn =.*//g' /etc/pulse/client.conf
            sed -i '$!N; /^\(.*\)\n\1$/!P; D' /etc/pulse/client.conf
            echo "# Make sure client is correct configured for system wide usage" >> /etc/pulse/client.conf
            echo "default-server = unix:/var/run/pulse/native" >> /etc/pulse/client.conf
            echo "autospawn = no" >> /etc/pulse/client.conf
            chmod 644 /etc/timezone > /dev/null 2>&1
            # remove possible existing lost boot entries
            sed -i 's/# Initramfs params for flashsystem//' /boot/config.txt
            sed -i 's/initramfs initrd.img followkernel//' /boot/config.txt
            sed -i 's/ramfsfile=initrd.img//' /boot/config.txt
            sed -i 's/ramfsaddr=-1//' /boot/config.txt
            # clean empty lines
            sed -i '/./,/^$/!d' /boot/config.txt
            # updating crankshaft-env.sh with possible new entries
            echo "" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Updating crankshaft_env.sh..." > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            cat /boot/crankshaft/crankshaft_env.sh | grep "^[^#]" | grep = > /boot/crankshaft/crankshaft_env_bak.sh
            cp -f /opt/crankshaft/crankshaft_default_env.sh /boot/crankshaft/crankshaft_env.sh
            while read -r line; do
            param=$(echo "$line" | cut -d= -f1)
                value=$(echo "$line" | cut -d= -f2-)
                if [ ! -z "$param" ] && [ ! -z "$value" ]; then
                    sed -i 's|^'"$param"'=.*|'"$param"'='"$value"'|' /boot/crankshaft/crankshaft_env.sh
                fi
            done < /boot/crankshaft/crankshaft_env_bak.sh
            rm -f /boot/crankshaft/crankshaft_env_bak.sh
            # reload settings after restore
            source /boot/crankshaft/crankshaft_env.sh
            # check rtc setup
            RTC_CHECK=$(cat /boot/config.txt | grep "^dtoverlay=i2c-rtc")
            if [ ! -z $RTC_CHECK ]; then
                echo "" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] Setup rtc..." > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                # try to set systime from rtc
                echo "" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                hwclock --hctosys
                echo "[${CYAN}${BOLD} INFO ${RESET}] RTC Time: $(hwclock -r)" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                # set tzdata
                timedatectl set-timezone $(cat ${FSMOUNTPOINT}/cs-backup/${SERIAL}/etc/timezone) > /dev/null 2>&1
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] RTC Time: $(hwclock -r)" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                systemctl enable hwclock-load.service > /dev/null 2>&1
                systemctl daemon-reload > /dev/null 2>&1
            fi
            # check camera setup
            CAM_CHECK=$(cat /boot/config.txt | grep "^start_x=1" | tail -n1)
            if [ ! -z $CAM_CHECK ]; then
                echo "" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] Setup cam..." > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                touch /etc/button_camera_visible
                systemctl enable rpicamserver > /dev/null 2>&1
                systemctl daemon-reload > /dev/null 2>&1
            fi
            # check overscan fix
            OVERSCAN_CHECK=$(cat /boot/config.txt | grep "^overscan_scale=1" | tail -n1)
            if [ -z $OVERSCAN_CHECK ]; then
                echo "" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] Setup overscan fix..." > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                # remove possible existing lost boot entries
                sed -i 's/# Overscan fix.*//' /boot/config.txt
                sed -i 's/overscan_scale=.*//' /boot/config.txt
                # clean empty lines
                sed -i '/./,/^$/!d' /boot/config.txt
                echo "" >> /boot/config.txt
                echo "# Overscan fix" >> /boot/config.txt
                echo "overscan_scale=1" >> /boot/config.txt
            fi
            # restore bluetooth
            if [ ${ENABLE_BLUETOOTH} -eq 1 ]; then
                BT_CHECK=$(cat /boot/config.txt | grep '^dtoverlay=pi3-disable-bt' | tail -n1)
                if [ -z $BT_CHECK ]; then
                    BTTYPE="builtin"
                else
                    BTTYPE="external"
                fi
                echo "" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] Setup bluetooth $BTTYPE..." > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                /usr/local/bin/crankshaft bluetooth $BTTYPE
            else
                echo "" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] Disable bluetooth ..." > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                /usr/local/bin/crankshaft bluetooth disable
            fi
            # restore day/night
            if [ $RTC_DAYNIGHT -eq 1 ]; then
                echo "" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] Setup timer..." > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                /usr/local/bin/crankshaft timers daynight "$RTC_DAY_START" "$RTC_NIGHT_START" "skip" > /dev/tty3
            fi

            # clean default modules
            sed -i 's/bcm2835_wdt//' /etc/modules
            # clean empty lines
            sed -i '/./,/^$/!d' /etc/modules
            # add default modules
            echo "bcm2835_wdt" >> /etc/modules

            # check for lightsnsor (i2c)
            if [ -f /etc/cs_lightsensor ]; then
                crankshaft lightsensor enable
            fi

            # set done
            mount -o remount,rw /
            touch /etc/cs_backup_restore_done
            echo "" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] All done." > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            # sync wait and reboot
            sync
            sleep 5
            reboot
        else
            log_echo "No Backup found on $DEVICE (${LABEL}) - skip ..."
        fi
    done
else
    echo "${RESET}" > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] Backup already restored." > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
    log_echo "Backup already restored."
fi

exit 0
