#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

if [ ! -f /boot/crankshaft/wpa_supplicant.conf ] || [ "${WIFI_PSK}" != "xxxxxxxxx" ] || [ "${WIFI2_PSK}" != "xxxxxxxxx" ]; then
    echo "" >/dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] Setting up wifi client credentials" >/dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
    # Setup base wpa_supplicant.conf file
    log_echo "Setting up wifi client credentials"
    sudo rm /tmp/wpa_supplicant.conf > /dev/null 2>&1
    echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" > /tmp/wpa_supplicant.conf
    echo "update_config=1" >> /tmp/wpa_supplicant.conf
    echo "country=${WIFI_COUNTRY}" >> /tmp/wpa_supplicant.conf

    crankshaft filesystem boot unlock

    # import ssid and password and setup config
    if [ "${WIFI_PSK}" != "xxxxxxxxx" ]; then
        if [ "${WIFI_SSID}" != "sample" ]; then
            show_screen
        fi
        if [ ${#WIFI_PSK} -ge 8 ]; then
            log_echo "Generating new config file for wifi config 0"
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Generating new config file for wifi config 0" >/dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
            wpa_passphrase "${WIFI_SSID}" "${WIFI_PSK}" > /boot/crankshaft/network0.conf
            sed -i '/#psk=.*/d' /boot/crankshaft/network0.conf
            # clean plaintext passwords in config
            sed -i 's/WIFI_PSK=.*/WIFI_PSK=\"xxxxxxxxx\"/' /boot/crankshaft/crankshaft_env.sh
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Done." >/dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        else
            if [ "${WIFI_SSID}" != "sample" ]; then
                log_echo "Ignoring config 0 - password must have 8 chars or more!"
                echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" >/dev/tty3
                echo "[${RED}${BOLD} WARN ${RESET}] Ignoring config 0 - password must have 8 chars or more!" >/dev/tty3
                echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" >/dev/tty3
                echo "" > /boot/crankshaft/network0.conf
                sleep 5
            else
                echo "" > /boot/crankshaft/network0.conf
            fi
        fi
    fi

    if [ "${WIFI2_PSK}" != "xxxxxxxxx" ]; then
        if [ "${WIFI2_SSID}" != "sample" ]; then
            show_screen
        fi
        if [ ${#WIFI2_PSK} -ge 8 ]; then
            log_echo "Generating new config file for wifi config 1"
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Generating new config file for wifi config 1" >/dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
            wpa_passphrase "${WIFI2_SSID}" "${WIFI2_PSK}" > /boot/crankshaft/network1.conf
            sed -i '/#psk=.*/d' /boot/crankshaft/network1.conf
            # clean plaintext passwords in config
            sed -i 's/WIFI2_PSK=.*/WIFI2_PSK=\"xxxxxxxxx\"/' /boot/crankshaft/crankshaft_env.sh
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Done." >/dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        else
            if [ "${WIFI2_SSID}" != "sample" ]; then
                log_echo "Ignoring config 1 - password must have 8 chars or more!"
                echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" >/dev/tty3
                echo "[${RED}${BOLD} WARN ${RESET}] Ignoring config 1 - password must have 8 chars or more!" >/dev/tty3
                echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" >/dev/tty3
                echo "" > /boot/crankshaft/network1.conf
                sleep 5
            else
                echo "" > /boot/crankshaft/network1.conf
            fi
        fi
    fi

    # add network configs to wpa_supplicant.conf
    cat /boot/crankshaft/network0.conf >> /tmp/wpa_supplicant.conf
    cat /boot/crankshaft/network1.conf >> /tmp/wpa_supplicant.conf
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
