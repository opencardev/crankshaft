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

for FSMOUNTPOINT in $(ls -d /media/USBDRIVES/* 2>/dev/null); do
    DEVICE="/dev/$(basename ${FSMOUNTPOINT})"
    if [ "$DEVICE" == "/dev/CSSTORAGE" ]; then
        DEVICE="$(mount | grep CSSTORAGE | awk {'print $1'})"
        PARTITION="CSSTORAGE"
    else
        PARTITION="$(basename ${DEVICE})"
    fi
    LABEL=$(blkid ${DEVICE} | sed 's/.*LABEL="//' | cut -d'"' -f1 | sed 's/ //g')
    FSTYPE=$(blkid ${DEVICE} | sed 's/.*TYPE="//' | cut -d'"' -f1)

    if [ -d /media/USBDRIVES/${PARTITION} ]; then
        UPDATEFILE=$(ls -Art /media/USBDRIVES/${PARTITION} | grep crankshaft-ng | grep .img | grep -v md5 | grep -v ^._ | tail -1)
        if [ ! -z ${UPDATEFILE} ]; then
            printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
            printf "[ ${CYAN}INFO${GRAY} ] Detected  Drive: ${DEVICE}\n" > /dev/tty3
            printf "[ ${CYAN}INFO${GRAY} ] Partition Label: ${LABEL}\n" > /dev/tty3
            printf "[ ${CYAN}INFO${GRAY} ] Part Filesystem: ${FSTYPE}\n" > /dev/tty3
            printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
            printf "\n" > /dev/tty3
            printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
            printf "[ ${CYAN}INFO${GRAY} ] Update file found on ${DEVICE} (${LABEL})\n" > /dev/tty3
            printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
            printf "\n" > /dev/tty3
            sleep 1
            # lets go
            printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
            printf "[ ${CYAN}INFO${GRAY} ] Mount ${DEVICE} in rw mode for backup\n" > /dev/tty3
            printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
            printf "\n" > /dev/tty3
            if [ "$DEVICE" != "/dev/CSSTORAGE" ]; then
                mount -o remount,rw ${DEVICE}
            fi
            sleep 1
            printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
            printf "[ ${CYAN}INFO${GRAY} ] Mounting mmcblk0 (sdcard) for backup...\n" > /dev/tty3
            printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
            printf "\n" > /dev/tty3
            sleep 1
            mkdir /tmp/bootfs
            mkdir /tmp/rootfs
            mount -o ro /dev/mmcblk0p1 /tmp/bootfs
            mount -o ro /dev/mmcblk0p2 /tmp/rootfs
            rm -rf /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}
            mkdir -p /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft
            mkdir -p /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/custom
            mkdir -p /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/etc
            mkdir -p /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/etc/X11/xorg.conf.d/
            mkdir -p /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/etc/pulse
            mkdir -p /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/etc/hostapd
            mkdir -p /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/etc/plymouth
            printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
            printf "[ ${CYAN}INFO${GRAY} ] Backing up cranksahft config files...\n" > /dev/tty3
            printf "[ ${CYAN}INFO${GRAY} ] *******************************************************\n" >/dev/tty3
            printf "\n" > /dev/tty3
            cp -f /tmp/bootfs/config.txt /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/crankshaft_env.sh /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/gpio2kbd.cfg /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/startup.py /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/startup.sh /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/triggerhappy.conf /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/volume /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/capvolume /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/alsactl.state /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/openauto.ini /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/wallpaper.png /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/wallpaper-night.png /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/wallpaper-classic.png /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/wallpaper-classic-night.png /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/wallpaper-eq.png /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/splash.png /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/shutdown.png /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/button_1 /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/button_2 /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/button_3 /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/button_4 /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/button_5 /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/button_6 /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/bluetooth-pairings.tar.gz /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/wpa_supplicant.conf /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/network0.conf /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -f /tmp/bootfs/crankshaft/network1.conf /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/ 2>/dev/null
            cp -rf /tmp/bootfs/crankshaft/custom/. /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/crankshaft/custom/ 2>/dev/null
            cp -f /tmp/rootfs/etc/timezone /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/etc/ 2>/dev/null
            cp -f /tmp/rootfs/etc/X11/xorg.conf.d/99-calibration.conf /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/etc/X11/xorg.conf.d/ 2>/dev/null
            cp -f /tmp/rootfs/etc/pulse/client.conf /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/etc/pulse/ 2>/dev/null
            cp -f /tmp/rootfs/etc/hostapd/hostapd.conf /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/etc/hostapd/ 2>/dev/null
            cp -f /tmp/rootfs/etc/cs_lightsensor /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/etc/ 2>/dev/null
            cp -f /tmp/rootfs/etc/plymouth/plymouthd.conf /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/etc/plymouth/ 2>/dev/null
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
            SIZE=$(($(stat -c%s /media/USBDRIVES/${PARTITION}/${UPDATEFILE})/1024/1024))

            # risky part
            dd if=/media/USBDRIVES/${PARTITION}/${UPDATEFILE} bs=1M | /usr/bin/pv -s ${SIZE}M | dd of=/dev/mmcblk0

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
                mount -o rw /dev/mmcblk0p2 /tmp/rootfs
                cp -f  /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/boot/config.txt /tmp/bootfs/ 2>/dev/null
                cp -f  /media/USBDRIVES/${PARTITION}/cs-backup/${SERIAL}/etc/modules /tmp/rootfs/etc/ 2>/dev/null
                chmod 644 /tmp/rootfs/etc/modules 2>/dev/null
                umount /tmp/bootfs
                umount /tmp/rootfs
                umount /media/USBDRIVES/${PARTITION}
                printf "[ ${GREEN}EXEC${GRAY} ] *******************************************************\n" >/dev/tty3
                printf "[ ${GREEN}EXEC${GRAY} ] Reboot...\n" > /dev/tty3
                printf "[ ${GREEN}EXEC${GRAY} ] *******************************************************\n" >/dev/tty3
                sleep 2
                reboot -f
            fi
        fi
    fi
    umount /media/USBDRIVES/${PARTITION}
done

# No flash file detected / switch system back to normal mode
printf "[ ${RED}WARN${GRAY} ] *******************************************************\n" >/dev/tty3
printf "[ ${RED}WARN${GRAY} ] No flash file found.\n" > /dev/tty3
printf "[ ${RED}WARN${GRAY} ] \n" > /dev/tty3
printf "[ ${RED}WARN${GRAY} ] Removing setup for flash mode and rebooting to normal\n" > /dev/tty3
printf "[ ${RED}WARN${GRAY} ] system in 5 seconds ...\n" > /dev/tty3
printf "[ ${RED}WARN${GRAY} ] *******************************************************\n" >/dev/tty3
printf "\n" >/dev/tty3
sleep 5
printf "[ ${RED}WARN${GRAY} ] *******************************************************\n" >/dev/tty3
printf "[ ${RED}WARN${GRAY} ] Switching back to normal boot ...\n" > /dev/tty3
printf "[ ${RED}WARN${GRAY} ] *******************************************************\n" >/dev/tty3
printf "\n" >/dev/tty3

mkdir /tmp/bootfs > /dev/null 2>&1
mount -o rw /dev/mmcblk0p1 /tmp/bootfs
rm /boot/initrd.img > /dev/null 2>&1
sed -i '/./,/^$/!d' /tmp/bootfs/config.txt
sed -i 's/^# Initramfs params for flashsystem//' /tmp/bootfs/config.txt
sed -i 's/^initramfs initrd.img followkernel//' /tmp/bootfs/config.txt
sed -i 's/^ramfsfile=initrd.img//' /tmp/bootfs/config.txt
sed -i 's/^ramfsaddr=-1//' /tmp/bootfs/config.txt
sed -i 's/rootdelay=10//' /tmp/bootfs/cmdline.txt
sed -i 's/initrd=-1//' /tmp/bootfs/cmdline.txt
sed -i 's/splash //' /tmp/bootfs/cmdline.txt
sed -i 's/vt.global_cursor_default=0 //' /tmp/bootfs/cmdline.txt
sed -i 's/plymouth.ignore-serial-consoles //' /tmp/bootfs/cmdline.txt
sed -i 's/ *$//' /tmp/bootfs/cmdline.txt
sed -i 's/$/ vt.global_cursor_default=0/' /tmp/bootfs/cmdline.txt
sed -i 's/$/ plymouth.ignore-serial-consoles/' /tmp/bootfs/cmdline.txt
sed -i 's/$/ splash/' /tmp/bootfs/cmdline.txt
sed -i '/./,/^$/!d' /tmp/bootfs/config.txt
sync
umount /tmp/bootfs

printf "[ ${GREEN}DONE${GRAY} ] *******************************************************\n" >/dev/tty3
printf "[ ${GREEN}DONE${GRAY} ] Done. Rebooting now ...\n" > /dev/tty3
printf "[ ${GREEN}DONE${GRAY} ] *******************************************************\n" >/dev/tty3
sleep 3
reboot -f

exit 0
