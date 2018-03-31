#!/bin/bash

# crankshaft

# adapted from Raspberry Pi ME Cleaner image customization script
# Written by Huan Truong <htruong@tnhh.net>, 2018
# This script is licensed under GNU Public License v3

###############################################################################

print_banner() {
    echo "---- WELCOME TO THE RASPBERRY PI IMAGE CUSTOMIZER --------------"
    echo " Congratulations, we have gone a long way."
    echo " I will prepare some software for you, sit tight."
    echo ""
    echo ""
    echo ""
}

get_deps() {
    apt update
    #apt upgrade
    apt install --no-install-recommends -y \
        libprotobuf10 libpulse0 libboost-log1.62.0 libboost-test1.62.0 \
        libboost-thread1.62.0 libboost-date-time1.62.0 libboost-chrono1.62.0 \
        libboost-atomic1.62.0 libpulse-mainloop-glib0 libfontconfig1 \
        libinput10 libxkbcommon0 pulseaudio librtaudio5a \
        fbi \
	libts-0.0-0 tsconf \
        xinit xserver-xorg-video-fbdev xserver-xorg-legacy xserver-xorg-input-libinput xserver-xorg-input-mouse libgl1-mesa-dri xserver-xorg-input-evdev \
        wiringpi

    apt clean
    rm -rf /var/cache/apt/
    #update raspi firmware
    #SKIP_WARNING=1 rpi-update
    ln -s /opt/vc/lib/libbrcmGLESv2.so /usr/lib/arm-linux-gnueabihf/libGLESv2.so
    ln -s /opt/vc/lib/libbrcmEGL.so /usr/lib/arm-linux-gnueabihf/libEGL.so
}

mark_script_run() {
    touch /etc/customizer_done
}

house_keeping() {
    # we don't need to resize the root part
    sed -i 's/ init\=.*$//' /boot/cmdline.txt
    sed -i 's/console=tty1/console=tty3/' /boot/cmdline.txt
    echo "disable_splash=1" >> /boot/config.txt
    echo -e "# Disable the PWR LED.\ndtparam=pwr_led_trigger=none\ndtparam=pwr_led_activelow=off" >> /boot/config.txt
    echo "logo.nologo splash loglevel=0 vt.global_cursor_default=0" >> /boot/cmdline.txt


    # make sure everything has the right owner
    chown -R root:root /usr/local/
    chown -R root:root /opt/crankshaft/
    chown root:root /etc/systemd/system/autoapp.service
    chown root:root /etc/systemd/system/crankshaft_startup.service
    chown root:root /etc/udev/rules.d/openauto.rules
    
    cat /root/pulseaudio_daemon.conf >> /etc/pulse/daemon.conf
    
    chmod u+s /opt/crankshaft/dumb_suid
    
    sed -i 's/load-module module-udev-detect/load-module module-udev-detect tsched=0/' /etc/pulse/default.pa
    echo 'set-sink-volume 0 52428' >> /etc/pulse/default.pa

    if [ -f /etc/wpa_supplicant/wpa_supplicant.conf ]; then
        chown root:root /etc/wpa_supplicant/wpa_supplicant.conf
    fi

    # some magic to get X11 openauto to work
    echo "allowed_users=anybody" > /etc/X11/Xwrapper.config
    echo "exec autoapp --platform xcb" > /home/pi/.xinitrc
    sudo usermod -aG tty pi
    chown pi:pi /home/pi/.xinitrc

    chown pi:pi /home/pi/.openauto_saved.ini

    # wallaper magic :)
    mv /root/wallpaper.png /boot/wallpaper.png
    ln -s /boot/wallpaper.png /home/pi/wallpaper.png
    chown pi:pi /home/pi/wallpaper.png

    # set the hostname
    echo "crankshaft" > /etc/hostname
    sed -i "s/raspberrypi/crankshaft/" /etc/hosts
    
    # enable the startup actions
    systemctl enable splashscreen.service
    systemctl enable autoapp.service
    systemctl enable crankshaft_startup.service
    
    systemctl disable resize2fs_once.service
    /opt/crankshaft/devmode.sh disable
}


###############################################################################

if [ -f /etc/customizer_done ]; then
    echo "This script has been run before. Nothing to do."
    exit 0
fi

cd /root/ 

print_banner

get_deps

house_keeping

mark_script_run
