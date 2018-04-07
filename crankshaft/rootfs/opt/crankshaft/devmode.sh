#!/bin/bash

if [ "$1" = "enable" ]; then
    systemctl disable autoapp.service
    systemctl disable splashscreen.service
    if ! [ -f /etc/crankshaft_ssh_keys_generated ]; then
        systemctl start regenerate_ssh_host_keys.service
	touch /etc/crankshaft_ssh_keys_generated
    fi
    systemctl enable networking.service
    systemctl enable dhcpd.service
    systemctl enable avahi-daemon.service
    systemctl enable ssh
    sed -i 's/console=tty3/console=tty1/' /boot/cmdline.txt
    sed -i 's/ logo.nologo loglevel=0 vt.global_cursor_default=0 splash//' /boot/cmdline.txt
else
    systemctl enable autoapp.service
    systemctl enable splashscreen.service
    systemctl disable ssh
    systemctl disable avahi-daemon.service
    systemctl disable dhcpd.service
    systemctl disable networking.service
    sed -i 's/console=tty1/console=tty3/' /boot/cmdline.txt
    sed -i 's/$/ logo.nologo loglevel=0 vt.global_cursor_default=0 splash/' /boot/cmdline.txt
fi

exit 0
