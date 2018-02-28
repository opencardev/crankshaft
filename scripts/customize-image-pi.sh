#!/bin/bash

# crankshaft

# adapted from Raspberry Pi ME Cleaner image customization script
# Written by Huan Truong <htruong@tnhh.net>, 2018
# This script is licensed under GNU Public License v3

###############################################################################

print_banner() {
    echo "---- WELCOME TO THE RASPBERRY PI IMAGE CUSTOMIZER --------------"
    sleep 1
    echo " Congratulations, we have gone a long way."
    sleep 1
    echo " I will prepare some software for you, sit tight."
    sleep 1
    echo ""
    echo ""
    echo ""
}

get_deps() {
    apt update
    #apt upgrade
    apt install -y libprotobuf10 libpulse0 libboost-log1.62.0 libboost-test1.62.0 libboost-thread1.62.0 libboost-date-time1.62.0 libboost-chrono1.62.0 libboost-atomic1.62.0 libpulse-mainloop-glib0 libfontconfig1 pulseaudio
    #update raspi firmware
    SKIP_WARNING=1 rpi-update
}

mark_script_run() {
    touch /etc/customizer_done
}

house_keeping() {
    # make sure everything has the right owner
    chown -R root:staff /usr/local/
    chown root:staff /etc/systemd/system/autoapp.service
    chown root:staff /etc/systemd/system/autoapp_brightness.service
    chown root:staff /etc/udev/rules.d/openauto.rules
    chown root:staff /etc/pulse/daemon.conf

    # enable the startup actions
    systemctl enable autoapp.service
    systemctl enable autoapp_brightness.service
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
