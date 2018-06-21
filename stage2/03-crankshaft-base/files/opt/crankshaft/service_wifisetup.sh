#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
source /boot/crankshaft/crankshaft_env.sh

# Setup base file
echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" > /tmp/wpa_supplicant.conf
echo "update_config=1" >> /tmp/wpa_supplicant.conf
echo "country=${WIFI_COUNTRY}" >> /tmp/wpa_supplicant.conf
chmod 644 /tmp/wpa_supplicant.conf
# import ssid and password and setup config
wpa_passphrase "${WIFI_SSID}" "${WIFI_PSK}" >> /tmp/wpa_supplicant.conf

exit 0
