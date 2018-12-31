#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

if [ ! -f /boot/crankshaft/wpa_supplicant.conf ] || [ "${WIFI_PSK}" != "xxxxxxxxx" ] || [ "${WIFI2_PSK}" != "xxxxxxxxx" ]; then
    # Setup base file
    log_echo "Setting up wifi client credentials"
    sudo rm /tmp/wpa_supplicant.conf > /dev/null 2>&1
    echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" > /tmp/wpa_supplicant.conf
    echo "update_config=1" >> /tmp/wpa_supplicant.conf
    echo "country=${WIFI_COUNTRY}" >> /tmp/wpa_supplicant.conf

    crankshaft filesystem boot unlock

    # import ssid and password and setup config
    if [ "${WIFI_PSK}" != "xxxxxxxxx" ]; then
        wpa_passphrase "${WIFI_SSID}" "${WIFI_PSK}" > /boot/crankshaft/network0.conf
        sed -i '/#psk=.*/d' /boot/crankshaft/network0.conf
    fi
    cat /boot/crankshaft/network0.conf >> /tmp/wpa_supplicant.conf

    if [ "${WIFI2_PSK}" != "xxxxxxxxx" ]; then
        wpa_passphrase "${WIFI2_SSID}" "${WIFI2_PSK}" > /boot/crankshaft/network1.conf
        sed -i '/#psk=.*/d' /boot/crankshaft/network1.conf
    fi
    cat /boot/crankshaft/network1.conf >> /tmp/wpa_supplicant.conf

    # clean plaintext passwords in config
    sed -i 's/WIFI_PSK=.*/WIFI_PSK=\"xxxxxxxxx\"/' /boot/crankshaft/crankshaft_env.sh
    sed -i 's/WIFI2_PSK=.*/WIFI2_PSK=\"xxxxxxxxx\"/' /boot/crankshaft/crankshaft_env.sh

    cp /tmp/wpa_supplicant.conf /boot/crankshaft/wpa_supplicant.conf
    chmod 644 /tmp/wpa_supplicant.conf

    crankshaft filesystem boot lock
else
    log_echo "Copy wifi client config and ensure country code is set"
    cp /boot/crankshaft/wpa_supplicant.conf /tmp/
    chmod 644 /tmp/wpa_supplicant.conf
    sed -i 's/country=.*$/country='"${WIFI_COUNTRY}"'/' /tmp/wpa_supplicant.conf
fi

# disable wifi power management
iw wlan0 set power_save off

exit 0
