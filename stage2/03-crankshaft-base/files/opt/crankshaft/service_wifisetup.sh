#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

if [ ! -f /boot/crankshaft/wpa_supplicant.conf ] && [ "${WIFI_PSK}" != "xxxxxxxxx" ]; then
    # Setup base file
    log_echo "Setting up wifi client credentials"
    echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" > /tmp/wpa_supplicant.conf
    echo "update_config=1" >> /tmp/wpa_supplicant.conf
    echo "country=${WIFI_COUNTRY}" >> /tmp/wpa_supplicant.conf
    chmod 644 /tmp/wpa_supplicant.conf
    # import ssid and password and setup config
    wpa_passphrase "${WIFI_SSID}" "${WIFI_PSK}" >> /tmp/wpa_supplicant.conf
    crankshaft filesystem boot unlock
    sed -i 's/WIFI_PSK=.*/WIFI_PSK=\"xxxxxxxxx\"/' /boot/crankshaft/crankshaft_env.sh
    sed -i '/#psk=.*/d' /tmp/wpa_supplicant.conf
    cp /tmp/wpa_supplicant.conf /boot/crankshaft/wpa_supplicant.conf
    crankshaft filesystem boot lock
else
    log_echo "Copy wifi client config"
    cp /boot/crankshaft/wpa_supplicant.conf /tmp/
    chmod 644 /tmp/wpa_supplicant.conf
fi

exit 0
