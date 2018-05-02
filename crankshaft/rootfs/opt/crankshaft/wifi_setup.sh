#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /boot/crankshaft/crankshaft_env.sh

enable(){
    # Setup base file
    sudo echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" > /etc/wpa_supplicant/wpa_supplicant.conf
    sudo echo "update_config=1" >> /etc/wpa_supplicant/wpa_supplicant.conf
    sudo echo "country=${WIFI_COUNTRY}" >> /etc/wpa_supplicant/wpa_supplicant.conf
    sudo chmod 644 /etc/wpa_supplicant/wpa_supplicant.conf
    # import ssid and password and setup config
    sudo wpa_passphrase "${WIFI_SSID}" "${WIFI_PSK}" >> /etc/wpa_supplicant/wpa_supplicant.conf
}

disable(){
    # Setup base file with blank entry
    sudo echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" > /etc/wpa_supplicant/wpa_supplicant.conf
    sudo echo "update_config=1" >> /etc/wpa_supplicant/wpa_supplicant.conf
    sudo echo "country=${WIFI_COUNTRY}" >> /etc/wpa_supplicant/wpa_supplicant.conf
    sudo chmod 644 /etc/wpa_supplicant/wpa_supplicant.conf
}

case $1 in
	enable)
		enable
		;;
	disable)
		disable
		;;
esac

exit 0
