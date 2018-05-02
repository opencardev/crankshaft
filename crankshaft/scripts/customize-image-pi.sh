#!/bin/bash

# crankshaft

# adapted from Raspberry Pi ME Cleaner image customization script
# Written by Huan Truong <htruong@tnhh.net>, 2018
# This script is licensed under GNU Public License v3

###############################################################################

print_banner() {
    echo "---------------------------------------------------------------------------"
    echo "Preparing packeges and customize inside image..."
    echo "---------------------------------------------------------------------------"
}

get_deps() {
    echo "---------------------------------------------------------------------------"
    echo "Install / remove packages via apt..."
    echo "---------------------------------------------------------------------------"
    apt update
    apt install --no-install-recommends -y \
        libprotobuf10 libpulse0 libboost-log1.62.0 libboost-test1.62.0 \
        libboost-thread1.62.0 libboost-date-time1.62.0 libboost-chrono1.62.0 \
        libboost-atomic1.62.0 libpulse-mainloop-glib0 libfontconfig1 \
        libinput10 libxkbcommon0 pulseaudio librtaudio5a \
        fbi \
        libts-0.0-0 tsconf \
        xinit xserver-xorg-video-fbdev xserver-xorg-legacy xserver-xorg-input-libinput xserver-xorg-input-mouse libgl1-mesa-dri xserver-xorg-input-evdev \
        wiringpi ntp

    apt -y upgrade
    apt autoremove --purge

    #update raspi firmware
    # SKIP_WARNING=1 SKIP_BACKUP=1 rpi-update
}

mark_script_run() {
    echo "---------------------------------------------------------------------------"
    echo "Customization done"
    echo "---------------------------------------------------------------------------"
    touch /etc/customizer_done
}

house_keeping() {
    echo "---------------------------------------------------------------------------"
    echo "House keeping..."
    echo "---------------------------------------------------------------------------"
    # make sure everything has the right owner
    chown -R root:root /root/rootfs
    rsync -avr /root/rootfs/ /
    rm -rf /root/rootfs/

    ldconfig

    cp /opt/crankshaft/crankshaft_default_env.sh /boot/crankshaft/crankshaft_env.sh

    # we don't need to resize the root part
    sed -i 's/ init\=.*$//' /boot/cmdline.txt

    echo "disable_splash=1" >> /boot/config.txt
    echo "gpu_mem=256" >> /boot/config.txt
    echo "gpu_mem_256=128" >> /boot/config.txt
    echo -e "# Disable the PWR LED.\ndtparam=pwr_led_trigger=none\ndtparam=pwr_led_activelow=off" >> /boot/config.txt

    cat /root/scripts/misc/pulseaudio_daemon.conf >> /etc/pulse/daemon.conf

    sed -i 's/user nobody/user pi/' /lib/systemd/system/triggerhappy.service

    chmod u+s /opt/crankshaft/dumb_suid

    sed -i 's/load-module module-udev-detect/load-module module-udev-detect tsched=0/' /etc/pulse/default.pa

    echo 'load-module module-mmkbd-evdev device=/dev/gpio2kbd' >> /etc/pulse/default.pa

    echo 'set-sink-volume 0 52428' >> /etc/pulse/default.pa

    # some magic to get X11 openauto to work
    echo "allowed_users=anybody" > /etc/X11/Xwrapper.config
    echo "exec autoapp --platform xcb" > /home/pi/.xinitrc

    sudo usermod -aG tty pi
    chown pi:pi /home/pi/.xinitrc

    # wallaper magic :)
    ln -s /boot/crankshaft/wallpaper.png /home/pi/wallpaper.png
    chown pi:pi /home/pi/wallpaper.png

    # make the triggergappy happy
    ln -s /boot/crankshaft/triggerhappy.conf /etc/triggerhappy/triggers.d/crankshaft.conf

    # set the hostname
    echo "crankshaft" > /etc/hostname
    sed -i "s/raspberrypi/crankshaft/" /etc/hosts

    # fix watchdog module (seems to be renamed on latest versions)
    CHECK=`modprobe --dry-run bcm2835_wdt`
    if [ $CHECK == "" ]; then
        sed -i "s/bcm2835_wdog/bcm2835_wdt/" /etc/modules
    fi
    CHECK=`modprobe --dry-run bcm2708_wdt`
    if [ $CHECK == "" ]; then
        sed -i "s/bcm2708_wdog/2708_wdt/" /etc/modules
    fi

    # link needed libs to run openauto
    ln -s /opt/vc/lib/libbrcmEGL.so /usr/lib/arm-linux-gnueabihf/libEGL.so
    ln -s /opt/vc/lib/libbrcmGLESv2.so /usr/lib/arm-linux-gnueabihf/libGLESv2.so
    ln -s /opt/vc/lib/libbrcmOpenVG.so /usr/lib/arm-linux-gnueabihf/libOpenVG.so
    ln -s /opt/vc/lib/libbrcmWFC.so /usr/lib/arm-linux-gnueabihf/libWFC.so

    # enable the startup actions
    systemctl enable splashscreen.service
    systemctl enable gpio2kbd.service
    systemctl enable crankshaft_startup.service
    systemctl enable autoapp.service
    systemctl enable user_startup.service

    systemctl disable resize2fs_once.service
    systemctl disable ntp.service
    /opt/crankshaft/devmode.sh disable
}


###############################################################################

if [ -f /etc/customizer_done ]; then
    echo "---------------------------------------------------------------------------"
    echo "Customization was already done before. Nothing to do."
    echo "---------------------------------------------------------------------------"
    exit 0
fi

cd /root/

print_banner
get_deps
house_keeping
mark_script_run
