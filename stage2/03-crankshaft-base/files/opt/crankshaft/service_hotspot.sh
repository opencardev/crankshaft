#!/bin/bash +e

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

if [ $ENABLE_HOTSPOT -eq 1 ] || [ -f /tmp/manual_hotspot_control ]; then
    log_echo "Exec hotspot script possible - action triggered: $1"
    if [ "$1" == "start" ]; then
        log_echo "Hotspot start triggered"
        if [ ! -f /tmp/hotspot_active ]; then
            log_echo "Kill running wpa clients"
            echo "" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Exit/kill wpa_supplicant (wifi client mode)" > /dev/tty3
            # exit possible running wpa client sessions
            sudo wpa_cli terminate > /dev/null 2>&1
            sudo killall wpa_supplicant > /dev/null 2>&1
            # switch of down to re setup
            log_echo "Switch off wlan0"
            echo "[${CYAN}${BOLD} INFO ${RESET}] Switch wifi off" > /dev/tty3
            sudo ifconfig wlan0 down
            # configure interface
            log_echo "Configure ip for wlan0"
            echo "[${CYAN}${BOLD} INFO ${RESET}] Configure interface ip" > /dev/tty3
            # 5 client ip's available (sum 6)
            sudo ifconfig wlan0 192.168.254.1 netmask 255.255.255.248 broadcast 192.168.254.7
            #switch power management
            log_echo "Switch on wlan0"
            # delete existing rules
            log_echo "Delete iptables"
            echo "[${CYAN}${BOLD} INFO ${RESET}] Deleting iptable rules" > /dev/tty3
            sudo /sbin/iptables -F
            sudo /sbin/iptables -X
            sudo /sbin/iptables -t nat -F
            # allow lookup
            log_echo "Setup iptables"
            echo "[${CYAN}${BOLD} INFO ${RESET}] Setup iptables for rounting" > /dev/tty3
            sudo /sbin/iptables -A INPUT -i lo -j ACCEPT
            sudo /sbin/iptables -A OUTPUT -o lo -j ACCEPT
            # enable nat and Masq
            sudo /sbin/iptables -A FORWARD -o eth0 -i wlan0 -m conntrack --ctstate NEW -j ACCEPT
            sudo /sbin/iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
            sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
            # ip forwarding
            log_echo "Allow forwarding"
            echo "[${CYAN}${BOLD} INFO ${RESET}] Allow forwarding" > /dev/tty3
            sudo sysctl -w net.ipv4.ip_forward=1 > /dev/null 2>&1
            # start services
            echo "[${CYAN}${BOLD} INFO ${RESET}] Start dnsmasq" > /dev/tty3
            sudo systemctl start dnsmasq
            echo "[${CYAN}${BOLD} INFO ${RESET}] Start hostapd" > /dev/tty3
            sudo systemctl start hostapd
            HOSTAPD=`systemctl status hostapd | grep running | awk {'print $3'} | cut -d'(' -f2 | cut -d')' -f1`
            if [ "$HOSTAPD" != "running" ]; then
                echo "[${RED}${BOLD} FAIL ${RESET}] Hostapd has failed to start!" > /dev/tty3
            else
                sudo killall hostapd_cli > /dev/null 2>&1
                sudo hostapd_cli -a '/opt/crankshaft/service_hostapdchange.sh' &
            fi
            DNSMASQ=`systemctl status dnsmasq | grep running | awk {'print $3'} | cut -d'(' -f2 | cut -d')' -f1`
            if [ "$DNSMASQ" != "running" ]; then
                echo "[${RED}${BOLD} FAIL ${RESET}] Dnsmasq has failed to start!" > /dev/tty3
            fi
            if [ "$HOSTAPD" == "running" ] && [ "$DNSMASQ" == "running" ]; then
                # cleanup possible lost state file
                sudo rm -f /tmp/hotspot_active > /dev/null 2>&1
                sudo touch /tmp/hotspot_active > /dev/null 2>&1
                sudo chmod 666 /tmp/hotspot_active > /dev/null 2>&1
            fi
            # show infos
            _SSID_WLAN0=$(cat /etc/hostapd/hostapd.conf | grep '^ssid' | cut -d= -f2)
            _PSK_WLAN0=$(cat /etc/hostapd/hostapd.conf | grep '^wpa_passphrase' | cut -d= -f2)
            _ENC_WLAN0=$(cat /etc/hostapd/hostapd.conf | grep '^wpa=' | cut -d= -f2)
            _IP_WLAN0=$(ifconfig wlan0 | grep 'inet ' | awk '{print $2}')
            echo "" >/dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] ${BLUE}${BOLD}${GREEN}wlan0: ${RESET}Mode       ${CYAN}Hotspot${RESET}" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] ${BLUE}${BOLD}${GREEN}wlan0: ${RESET}IP         ${MAGENTA}$_IP_WLAN0${RESET}" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] ${BLUE}${BOLD}${GREEN}wlan0: ${RESET}SSID       ${YELLOW}$_SSID_WLAN0${RESET}" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] ${BLUE}${BOLD}${GREEN}wlan0: ${RESET}PSK        ${YELLOW}$_PSK_WLAN0${RESET}" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] ${BLUE}${BOLD}${GREEN}wlan0: ${RESET}Type       ${YELLOW}WPA$_ENC_WLAN0${RESET}" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
            exit 0
        else
            log_echo "Hotspot start trigger ignored - hotspot mode still active"
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Hotspot Mode is still active${RESET}" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        fi
    fi

    if [ ! -f /var/run/nologin ]; then
        if [ "$1" == "stop" ]; then
            log_echo "Hotspot stop triggered"
            if [ -f /tmp/hotspot_active ]; then
                # stop hostapd and dnsmasq dhcp server
                log_echo "Stop hostapd"
                echo "" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] Stopping hostapd" > /dev/tty3
                sudo systemctl stop hostapd
                sudo killall hostapd_cli > /dev/null 2>&1
                log_echo "Stop dnsmasq"
                echo "[${CYAN}${BOLD} INFO ${RESET}] Stopping dnsmasq" > /dev/tty3
                sudo systemctl stop dnsmasq
                # delete existing rules
                log_echo "Delete iptables"
                echo "[${CYAN}${BOLD} INFO ${RESET}] Deleting iptable rules" > /dev/tty3
                sudo /sbin/iptables -F
                sudo /sbin/iptables -X
                sudo /sbin/iptables -t nat -F
                #switch power management
                log_echo "Switch on wlan0"
                #sudo iwconfig wlan0 power on
                log_echo "Bring wlan0 up"
                echo "[${CYAN}${BOLD} INFO ${RESET}] Bring up wlan0 interface" > /dev/tty3
                sudo ifconfig wlan0 up
                # configure blank interface
                echo "[${CYAN}${BOLD} INFO ${RESET}] Reconfigure ip wlan0" > /dev/tty3
                log_echo "Cleanup ip address for wlan0"
                sudo ip address del 192.168.254.1/29 dev wlan0
                # restaret dhcpcd to bring up network
                sudo systemctl restart dhcpcd
                echo "[${CYAN}${BOLD} INFO ${RESET}] Waiting for ip release..." > /dev/tty3
                log_echo "Waitin for ip release"
                # check 15 secs for valid ip config
                counter=0
                while [ $counter -lt 15 ]; do
                    # Get ip addresses by interface
                    if [ -d /sys/class/net/wlan0 ]; then
                        _IP_WLAN0=$(ifconfig wlan0 | grep 'inet ' | awk '{print $2}')
                        if [ "$_IP_WLAN0" ]; then
                            break
                        fi
                    fi
                    counter=$((counter+1))
                    sleep 1
                done
                # clanup state file
                sudo rm -f /tmp/hotspot_active > /dev/null 2>&1
                # show infos
                _SSID_WLAN0=$(wpa_cli -i wlan0 status | grep '^ssid' | cut -d= -f2)
                _FREQ_WLAN0=$(wpa_cli -i wlan0 status | grep '^freq' | cut -d= -f2)
                _ENC_WLAN0=$(wpa_cli -i wlan0 status | grep '^key_mgmt' | cut -d= -f2)
                echo "" >/dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] ${BLUE}${BOLD}${GREEN}wlan0: ${RESET}Mode       ${CYAN}Client${RESET}" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] ${BLUE}${BOLD}${GREEN}wlan0: ${RESET}IP         ${MAGENTA}$_IP_WLAN0${RESET}" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] ${BLUE}${BOLD}${GREEN}wlan0: ${RESET}SSID       ${YELLOW}$_SSID_WLAN0${RESET}" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] ${BLUE}${BOLD}${GREEN}wlan0: ${RESET}Frequency  ${YELLOW}$_FREQ_WLAN0 MHz${RESET}" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] ${BLUE}${BOLD}${GREEN}wlan0: ${RESET}Type       ${YELLOW}$_ENC_WLAN0${RESET}" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
                exit 0
            else
                log_echo "Hotspot stop trigger ignored - client mode still active"
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] Client Mode is still active${RESET}" > /dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
            fi
        fi
    else
        log_echo "Exec hotspot script ignored - diabled by nologin"
    fi
else
    log_echo "Exec hotspot script NOT possible - no autostart or manual control enabled"
fi
