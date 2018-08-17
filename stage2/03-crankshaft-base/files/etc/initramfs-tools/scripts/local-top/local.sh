#!/bin/ash

GRAY="\e[38;5;244m"
BLUE="\e[38;5;21m"
CYAN="\e[38;5;51m"
RED="\e[38;5;196m"
GREEN="\e[38;5;46m"
YELLOW="\e[38;5;214m"

printf "${GRAY}" >/dev/tty3
printf "[ ${BLUE}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
printf "[ ${BLUE}INFO${GRAY} ] Crankshaft Flash & Backup System\n" >/dev/tty3
printf "[ ${BLUE}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
printf "\n" >/dev/tty3

SERIAL=$(cat /proc/cpuinfo | grep Serial | cut -d: -f2 | sed 's/ //g')

for _device in /sys/block/*/device; do
    if echo $(readlink -f "$_device")|egrep -q "usb"; then
        _disk=$(echo "$_device" | cut -f4 -d/)
        DEVICE="/dev/${_disk}1"
        PARTITION="${_disk}1"
        LABEL=$(blkid /dev/${PARTITION} | sed 's/.*LABEL="//' | cut -d'"' -f1)
        FSTYPE=$(blkid /dev/${PARTITION} | sed 's/.*TYPE="//' | cut -d'"' -f1)
        sleep 1
        if [ $FSTYPE == "fat" ] || [ $FSTYPE == "vfat" ] || [ $FSTYPE == "ext3" ] || [ $FSTYPE == "ext4" ]; then
            mkdir /tmp/${PARTITION} >/dev/null 2>&1
            mount -t auto ${DEVICE} /tmp/${PARTITION}
            if [ $? -ne 0 ]; then
                printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                printf "[ ${CYAN}INFO${GRAY} ] Mount not possible - skipping drive ${DEVICE}\n" > /dev/tty3
                printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                sleep 1
            else
                UPDATEFILE=$(ls -Art /tmp/${PARTITION} | grep crankshaft-ng | grep .img | grep -v md5 | tail -1)
                if [ ! -z ${UPDATEFILE} ]; then
                    printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                    printf "[ ${CYAN}INFO${GRAY} ] Detected Drive: ${PARTITION}\n" > /dev/tty3
                    printf "[ ${CYAN}INFO${GRAY} ] Label 1st Part: ${LABEL}\n" > /dev/tty3
                    printf "[ ${CYAN}INFO${GRAY} ] PartFilesystem: ${FSTYPE}\n" > /dev/tty3
                    printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                    printf "\n" > /dev/tty3
                    printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                    printf "[ ${CYAN}INFO${GRAY} ] Update file found on ${DEVICE} (${LABEL})\n" > /dev/tty3
                    printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                    printf "\n" > /dev/tty3
                    sleep 1
                    # lets go
                    printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                    printf "[ ${CYAN}INFO${GRAY} ] Mounting mmcblk0 (sdcard) for backup...\n" > /dev/tty3
                    printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                    printf "\n" > /dev/tty3
                    sleep 1
                    mkdir /tmp/bootfs
                    mkdir /tmp/rootfs
                    mount -o ro /dev/mmcblk0p1 /tmp/bootfs
                    mount -o ro /dev/mmcblk0p2 /tmp/rootfs
                    rm -rf /tmp/${PARTITION}/cs-backup/${SERIAL}
                    mkdir -p /tmp/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft
                    mkdir -p /tmp/${PARTITION}/cs-backup/${SERIAL}/etc
                    mkdir -p /tmp/${PARTITION}/cs-backup/${SERIAL}/etc/X11/xorg.conf.d/
                    mkdir -p /tmp/${PARTITION}/cs-backup/${SERIAL}/etc/pulse
                    printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                    printf "[ ${CYAN}INFO${GRAY} ] Backing up cranksahft config files...\n" > /dev/tty3
                    printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                    printf "\n" > /dev/tty3
                    cp -f /tmp/bootfs/config.txt /tmp/${PARTITION}/cs-backup/${SERIAL}/boot/ 2>/dev/null
                    cp -f /tmp/bootfs/crankshaft/crankshaft_env.sh /tmp/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
                    cp -f /tmp/bootfs/crankshaft/gpio2kbd.cfg /tmp/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
                    cp -f /tmp/bootfs/crankshaft/startup.py /tmp/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
                    cp -f /tmp/bootfs/crankshaft/startup.sh /tmp/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
                    cp -f /tmp/bootfs/crankshaft/triggerhappy.conf /tmp/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
                    cp -f /tmp/bootfs/crankshaft/brightness /tmp/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
                    cp -f /tmp/bootfs/crankshaft/brightness-night /tmp/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
                    cp -f /tmp/bootfs/crankshaft/volume /tmp/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
                    cp -f /tmp/bootfs/crankshaft/capvolume /tmp/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
                    cp -f /tmp/bootfs/crankshaft/openauto.ini /tmp/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
                    cp -f /tmp/bootfs/crankshaft/wallpaper.png /tmp/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
                    cp -f /tmp/bootfs/crankshaft/wallpaper-night.png /tmp/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
                    cp -f /tmp/bootfs/crankshaft/wallpaper-devmode.png /tmp/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
                    cp -f /tmp/bootfs/crankshaft/wallpaper-devmode-night.png /tmp/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
                    cp -f /tmp/bootfs/crankshaft/bluetooth-pairings.tar.gz /tmp/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
                    cp -f /tmp/bootfs/crankshaft/custom_brightness_command /tmp/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
                    cp -f /tmp/rootfs/etc/timezone /tmp/${PARTITION}/cs-backup/${SERIAL}/etc/ 2>/dev/null
                    cp -f /tmp/rootfs/etc/X11/xorg.conf.d/99-calibration.conf /tmp/${PARTITION}/cs-backup/${SERIAL}/etc/X11/xorg.conf.d/ 2>/dev/null
                    cp -f /tmp/rootfs/etc/pulse/client.conf /tmp/${PARTITION}/cs-backup/${SERIAL}/etc/pulse/ 2>/dev/null
                    sleep 1
                    # umount after backup
                    printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                    printf "[ ${CYAN}INFO${GRAY} ] Backup done - unmounting mmcblk0 (sdcard)\n" > /dev/tty3
                    printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                    printf "\n" > /dev/tty3
                    umount /tmp/bootfs
                    umount /tmp/rootfs
                    sleep 1
                    clear  >/dev/tty3
                    printf "[ ${BLUE}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                    printf "[ ${BLUE}INFO${GRAY} ] Crankshaft Flash & Backup System\n" >/dev/tty3
                    printf "[ ${BLUE}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                    printf "\n" >/dev/tty3
                    printf "[ ${RED}WARN${GRAY} ] *******************************************************\n" >/dev/tty3
                    printf "[ ${RED}WARN${GRAY} ] Don't remove the USB drive on first boot!\n" >/dev/tty3
                    printf "[ ${RED}WARN${GRAY} ] It contains current crankshaft config backup.\n" > /dev/tty3
                    printf "[ ${RED}WARN${GRAY} ] A backup restore will executed only one time!\n" > /dev/tty3
                    printf "[ ${RED}WARN${GRAY} ] *******************************************************\n" >/dev/tty3
                    sleep 1
                    printf "\n" >/dev/tty3
                    printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                    printf "[ ${CYAN}INFO${GRAY} ] Starting flash in 10 seconds...\n" > /dev/tty3
                    printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                    printf "\n" >/dev/tty3
                    sleep 10
                    clear  >/dev/tty3
                    printf "[ ${BLUE}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                    printf "[ ${BLUE}INFO${GRAY} ] Crankshaft Flash & Backup System\n" >/dev/tty3
                    printf "[ ${BLUE}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                    printf "\n" >/dev/tty3
                    printf "Flashing file ${YELLOW}${UPDATEFILE}${GRAY} to SD-Card...\n" >/dev/tty3
                    printf "\n" >/dev/tty3

                    # calc size in mb for progress
                    SIZE=$(($(stat -c%s /tmp/${PARTITION}/${UPDATEFILE})/1024/1024))

                    # risky part
                    dd if=/tmp/${PARTITION}/${UPDATEFILE} bs=1M | /usr/bin/pv -s ${SIZE}M | dd of=/dev/mmcblk0

                    if [ $? -ne 0 ]; then
                        clear  >/dev/tty3
                        printf "[ ${BLUE}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                        printf "[ ${BLUE}INFO${GRAY} ] Crankshaft Flash & Backup System\n" >/dev/tty3
                        printf "[ ${BLUE}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                        printf "\n" >/dev/tty3
                        printf "[ ${RED}FAIL${GRAY} ] *******************************************************\n" >/dev/tty3
                        printf "[ ${RED}FAIL${GRAY} ] Flashing failed! - System will be broken!\n" > /dev/tty3
                        printf "[ ${RED}FAIL${GRAY} ] Shutdown in 10 seconds - Flash sdcard manually!\n" > /dev/tty3
                        printf "[ ${RED}FAIL${GRAY} ] *******************************************************\n" >/dev/tty3
                        umount /tmp/${PARTITION}
                        sleep 10
                        poweroff -f
                    else
                        clear  >/dev/tty3
                        printf "[ ${BLUE}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                        printf "[ ${BLUE}INFO${GRAY} ] Crankshaft Flash & Backup System\n" >/dev/tty3
                        printf "[ ${BLUE}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                        printf "\n" >/dev/tty3
                        printf "[ ${GREEN}DONE${GRAY} ] *******************************************************\n" >/dev/tty3
                        printf "[ ${GREEN}DONE${GRAY} ] \n" >/dev/tty3
                        printf "[ ${GREEN}DONE${GRAY} ] Flashing successful!\n" >/dev/tty3
                        printf "[ ${GREEN}DONE${GRAY} ] \n" >/dev/tty3
                        printf "[ ${GREEN}DONE${GRAY} ] *******************************************************\n" >/dev/tty3
                        printf "\n" >/dev/tty3
                        sleep 2
                        printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                        printf "[ ${CYAN}INFO${GRAY} ] Restoring config.txt and crankshaft_env.sh\n" >/dev/tty3
                        printf "[ ${CYAN}INFO${GRAY} ] to get display and gpio's working on 1st boot\n" >/dev/tty3
                        printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
                        printf "\n" >/dev/tty3
                        sync
                        mount -o rw /dev/mmcblk0p1 /tmp/bootfs
                        cp -f  /tmp/${PARTITION}/cs-backup/${SERIAL}/boot/config.txt /tmp/bootfs/ 2>/dev/null
                        cp -f  /tmp/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/crankshaft_env.sh /tmp/bootfs/crankshaft/ 2>/dev/null
                        umount /tmp/bootfs
                        umount /tmp/${PARTITION}
                        printf "[ ${GREEN}EXEC${GRAY} ] *******************************************************\n" >/dev/tty3
                        printf "[ ${GREEN}EXEC${GRAY} ] Reboot...\n" > /dev/tty3
                        printf "[ ${GREEN}EXEC${GRAY} ] *******************************************************\n" >/dev/tty3
                        sleep 2
                        reboot -f
                    fi
                fi
                umount /tmp/${PARTITION}
                rmdir /tmp/${PARTITION}
            fi
        fi
    fi
done

exit 0
