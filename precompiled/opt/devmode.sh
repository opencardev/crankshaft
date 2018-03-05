#!/bin/bash

if [ "$1" = "enable" ]; then
    systemctl disable autoapp.service
	systemctl disable splashscreen.service
	systemctl start regenerate_ssh_host_keys.service
	systemctl enable networking.service
	systemctl enable dhcpd.service
	systemctl enable avahi-daemon.service
	systemctl enable ssh
else
    systemctl enable autoapp.service
    systemctl enable splashscreen.service
    systemctl disable ssh
    systemctl disable avahi-daemon.service
    systemctl disable dhcpd.service
    systemctl disable networking.service
fi

exit 0
