#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
source /boot/crankshaft/crankshaft_env.sh

if [ $ENABLE_HOTSPOT -eq 1 ]; then
    if [ $1 == "start" ]; then
        # exit possible running wpa client sessions
        wpa_cli terminate
        # switch of down to re setup
        ifconfig wlan0 down
        # configure interface
        ifconfig wlan0 192.168.254.1 netmask 255.255.240.0 up # 10 ip's available
        #switch power management
        iwconfig wlan0 power on
        # delete existing rules
        /sbin/iptables -F
        /sbin/iptables -X
        /sbin/iptables -t nat -F
        # allow lookup
        /sbin/iptables -A INPUT -i lo -j ACCEPT
        /sbin/iptables -A OUTPUT -o lo -j ACCEPT
        # enable nat and Masq
        /sbin/iptables -A FORWARD -o eth0 -i wlan0 -m conntrack --ctstate NEW -j ACCEPT
        /sbin/iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
        /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
        # ip forwarding
        sysctl -w net.ipv4.ip_forward=1
        # set wpa password
        sed -i "s/^wpa_passphrase=.*$/wpa_passphrase=${HOTSPOT_PSK}/" /etc/hostapd/hostapd.conf
        sed -i "s/^country_code=.*$/country_code=${WIFI_COUNTRY}/" /etc/hostapd/hostapd.conf
        # sart of both is done by systemd service dependency
        SSID=$(cat /etc/hostapd/hostapd.conf | grep ssid | cut -d= -f2)
        PSK=$(cat /etc/hostapd/hostapd.conf | grep wpa_passphrase | cut -d= -f2)
        echo "[${CYAN}${BOLD} INFO ${RESET}]	${BLUE}${BOLD}SSID: ${SSID}${RESET}"
        echo "[${CYAN}${BOLD} INFO ${RESET}]	${BLUE}${BOLD}PSK:  1234567890${RESET}"
        exit 0
    fi

    if [ $1 == "stop" ]; then
        # stop hostapd and dnsmasq dhcp server after exit og hotspot
        systemctl stop hostapd
        systemctl stop dnsmasq
        # delete existing rules
        /sbin/iptables -F
        /sbin/iptables -X
        /sbin/iptables -t nat -F
        # configure blank interface
        ifconfig wlan0 0.0.0.0 netmask 0.0.0.0 up
        ifconfig wlan0 up
        #switch power management
        iwconfig wlan0 power on
        exit 0
    fi
else
    exit 1
fi
