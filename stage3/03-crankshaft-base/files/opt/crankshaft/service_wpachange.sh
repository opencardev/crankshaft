#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

function update_network() {
    sudo rm /tmp/wifi_network >/dev/null 2>&1
    sudo rm /tmp/mobile_hotspot_detected >/dev/null 2>&1
    sudo rm /tmp/gateway_wlan0 >/dev/null 2>&1
    sudo rm /tmp/wifi_ssid >/dev/null 2>&1
    SSID=`wpa_cli -iwlan0 status | grep ^ssid | cut -d= -f2`
    if [ ! -z "$SSID" ]; then
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] WPA-EVENT: USING WIFI SSID: $SSID" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        log_echo "WPA-EVENT: USING WIFI SSID: $SSID"
        echo $SSID > /tmp/wifi_ssid
        COUNTER=0
        #check for 30 seconds for dhcp lease assigned
        while [ $COUNTER -lt 30 ]; do
            if [ -f /var/run/resolvconf/interfaces/wlan0.dhcp ]; then
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] DHCP-EVENT: $SSID got a lease" >/dev/tty3
                echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
                log_echo "DHCP-EVENT: $SSID got a lease"
                DEFROUTE=$(route -n | grep '^0.0.0.0' | grep wlan0 | awk {'print $2'})
                if [ "$DEFROUTE" != "" ]; then
                    sudo rm /tmp/gateway_wlan0 >/dev/null 2>&1
                    echo $DEFROUTE > /tmp/gateway_wlan0
                    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
                    echo "[${CYAN}${BOLD} INFO ${RESET}] ROUTE: Default route set to $DEFROUTE" >/dev/tty3
                    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
                    log_echo "ROUTE: Default route set to $DEFROUTE"
                    if [ "$SSID" == "${WIFI2_SSID}" ]; then
                        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
                        echo "[${CYAN}${BOLD} INFO ${RESET}] MOBILE HOTSPOT DETECTED: SSID (${WIFI2_SSID})" >/dev/tty3
                        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
                        touch /tmp/mobile_hotspot_detected
                    fi
                fi
                exit 0
            fi
            let COUNTER=COUNTER+1
            sleep 1
        done
    else
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] WPA-EVENT: NO SSID available" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        log_echo "WPA-EVENT: NO SSID available"
    fi
}

if [[ $2 == "CONNECTED" ]]; then
  echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] WPA-EVENT: $1 $2" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
  log_echo "WPA-EVENT: $1 $2"
  update_network
fi

if [[ $2 == "DISCONNECTED" ]]; then
  echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] WPA-EVENT: $1 $2" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
  log_echo "WPA-EVENT: $1 $2"
  update_network
fi

if [[ $1 == "INIT" ]]; then
    update_network
fi
