#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
if [ -f /boot/crankshaft/crankshaft_env.sh ];then
    source /boot/crankshaft/crankshaft_env.sh
fi

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

# check if / is available
while [ "$(mountpoint -q / && echo mounted || echo fail)" == "fail" ]; do
    show_clear_screen
    show_cursor
    echo "${RESET}" > /dev/tty3
    echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
    echo "[${RED}${BOLD} WARN ${RESET}] Delayed rootfs - waiting..." > /dev/tty3
    echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
    sleep 2
done

sleep 1
SERIAL=$(cat /proc/cpuinfo | grep Serial | cut -d: -f2 | sed 's/ //g')

if [ ! -f /etc/cs_backup_restore_done ]; then
    if [ ! -f /etc/cs_first_start_done ]; then
        show_clear_screen
    fi
    echo "${RESET}" > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] Checking for cs backups to restore..." > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
    for _device in /sys/block/*/device; do
        if echo $(readlink -f "$_device")|egrep -q "usb"; then
            _disk=$(echo "$_device" | cut -f4 -d/)
            DEVICE="/dev/${_disk}1"
            PARTITION="${_disk}1"
            LABEL=$(blkid /dev/${PARTITION} | sed 's/.*LABEL="//' | cut -d'"' -f1 | sed 's/ //g')
            FSTYPE=$(blkid /dev/${PARTITION} | sed 's/.*TYPE="//' | cut -d'"' -f1)
            echo "${RESET}" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Detected Drive: ${PARTITION}" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Label 1st Part: ${LABEL}" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] PartFilesystem: ${FSTYPE}" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            if [ $LABEL == "CSSTORAGE" ]; then
                echo "${RESET}" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] Skipping CSSTORAGE..." > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                continue
            fi
            if [ $FSTYPE == "fat" ] || [ $FSTYPE == "vfat" ] || [ $FSTYPE == "ext3" ] || [ $FSTYPE == "ext4" ]; then
                umount /tmp/${PARTITION} > /dev/null 2>&1
                mkdir /tmp/${PARTITION} > /dev/null 2>&1
                echo "${RESET}" > /dev/tty3
                # check fs if needed
                if [ $FSTYPE == "fat" ] || [ $FSTYPE == "vfat" ]; then
                    # check state of fs
                    dosfsck -n $DEVICE
                    if [ $? == "1" ]; then
                        # 1 = errors detected - repair...
                        show_cursor
                        echo "${RESET}" > /dev/tty3
                        echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
                        echo "[${RED}${BOLD} WARN ${RESET}] Errors on $DEVICE detected - repairing..." > /dev/tty3
                        echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
                        dosfsck -y $DEVICE > /dev/tty3
                        sync
                        sleep 5
                        reboot
                    fi
                fi
                if [ $FSTYPE == "ext3" ] || [ $FSTYPE == "ext4" ]; then
                    CHECK=`tune2fs -l /dev/devicename |awk -F':' '/^Filesystem s/ {print $2}' | sed 's/ //g'`
                    if [ "$CHECK" != "clean" ]; then
                        show_cursor
                        echo "${RESET}" > /dev/tty3
                        echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
                        echo "[${RED}${BOLD} WARN ${RESET}] Errors on $DEVICE detected - repairing..." > /dev/tty3
                        echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
                        fsck.$FSTYPE -f -y $DEVICE > /dev/tty3
                        sync
                        sleep 5
                        reboot
                    fi
                fi
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] Mounting..." > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                mount -t auto ${DEVICE} /tmp/${PARTITION} > /dev/tty3
                if [ $? -eq 0 ]; then
                    echo "${RESET}" > /dev/tty3
                    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                    echo "[${CYAN}${BOLD} INFO ${RESET}] Checking if backup folder is present..." > /dev/tty3
                    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                    if [ -d /tmp/${PARTITION}/cs-backup/${SERIAL} ] || [ -d /tmp/${PARTITION}/cs-backup/boot ]; then
                        sleep 2
                        show_screen
                        show_cursor
                        echo "${RESET}" > /dev/tty3
                        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                        echo "[${CYAN}${BOLD} INFO ${RESET}] Backup found on $DEVICE (${LABEL}) - restoring backup..." > /dev/tty3
                        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                        echo "" > /dev/tty3
                        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                        echo "[${CYAN}${BOLD} INFO ${RESET}] Check /boot ..." > /dev/tty3
                        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
                        umount /dev/mmcblk0p1
                        fsck -f -y /dev/mmcblk0p1 > /dev/null 2>&1
                        mount /dev/mmcblk0p1 /boot
                        mount -o remount,rw /
                        # restore files
                        cp -r -f /tmp/${PARTITION}/cs-backup/${SERIAL}/boot/. /boot/ > /dev/null 2>&1
                        cp -r -f /tmp/${PARTITION}/cs-backup/${SERIAL}/etc/. /etc/ > /dev/null 2>&1
                        cp -r -f /tmp/${PARTITION}/cs-backup/${SERIAL}/etc/X11/xorg.conf.d/. /etc/ > /dev/null 2>&1
                        cp -r -f /tmp/${PARTITION}/cs-backup/${SERIAL}/etc/pulse/. /etc/pulse/ > /dev/null 2>&1
                        chmod 644 /etc/timezone > /dev/null 2>&1
                        # remove possible existing lost boot entries
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
                            param=$(echo $line | cut -d= -f1)
                            value=$(echo $line | cut -d= -f2)
                            if [ ! -z $param ] && [ ! -z $value ]; then
                                sed -i 's#^'"$param"'=.*#'"$param"'='"$value"'#' /boot/crankshaft/crankshaft_env.sh
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
                            # check rtc services
                            CHECK_RTC_LOAD=$(systemctl -l --state enabled --all list-unit-files | grep hwclock-load | awk {'print $2'})
                            if [ "$CHECK_RTC_LOAD" != "enabled" ]; then
                                systemctl enable hwclock-load.service > /dev/null 2>&1
                            fi

                            CHECK_RTC_SAVE=$(systemctl -l --state enabled --all list-unit-files | grep hwclock-save | awk {'print $2'})
                            if [ "$CHECK_RTC_SAVE" != "enabled" ]; then
                                systemctl enable hwclock-load.service > /dev/null 2>&1
                            fi
                            systemctl disable fake-hwclock > /dev/null 2>&1
                            # reload services
                            systemctl daemon-reload > /dev/null 2>&1
                            # set tzdata
                            timedatectl set-timezone $(cat /tmp/${PARTITION}/cs-backup/${SERIAL}/etc/timezone) > /dev/null 2>&1
                            # failsafe for coming from pre1
                            if [ -d /tmp/${PARTITION}/cs-backup/etc ]; then
                                timedatectl set-timezone $(cat /tmp/${PARTITION}/cs-backup/${SERIAL}/etc/timezone) > /dev/null 2>&1
                            fi
                            # reset i2c modules
                            sed -i '/i2c/d' /etc/modules
                            # clean empty lines
                            sed -i '/./,/^$/!d' /etc/modules
                            # set modules
                            echo 'i2c_dev' >> /etc/modules
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
                        umount /tmp/${PARTITION}
                        reboot
                    fi
                    umount /tmp/${PARTITION}
                    rmdir /tmp/${PARTITION}
                else
                    echo "${RESET}" > /dev/tty3
                    echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
                    echo "[${RED}${BOLD} WARN ${RESET}] Mount failed!" > /dev/tty3
                    echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
                    sleep 5
                fi
            fi
        fi
    done
else
    echo "${RESET}" > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] Backup already restored." > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
fi

exit 0
