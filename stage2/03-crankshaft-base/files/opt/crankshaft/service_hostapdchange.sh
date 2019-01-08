#!/bin/bash

source /opt/crankshaft/crankshaft_system_env.sh

function update_recent() {
    if [ -f /tmp/dnsmasq.leases ]; then
        rm /tmp/temp_recent_list >/dev/null 2>&1
        num=0
        sudo sh -c 'echo "[Recent]" > /tmp/openauto_wifi_recent.ini'
        sudo sh -c 'echo "EntiresCount=0" >> /tmp/openauto_wifi_recent.ini'
        cat /tmp/dnsmasq.leases | awk {'print $3'} | while read -r wificlient; do
            sudo sh -c 'echo "Entry_$num='$wificlient'" >> /tmp/openauto_wifi_recent.ini'
            if [ "$wificlient" != "" ]; then
                log_echo "IP added to recent list: $wificlient"
                sudo sh -c 'echo "'$wificlient'" >> /tmp/temp_recent_list'
            fi
            num=$((num+1))
        done
        entries=$(cat /tmp/openauto_wifi_recent.ini | grep Entry_ | wc -l)
        sed -i 's|^EntiresCount=.*|EntiresCount='"$entries"'|' /tmp/openauto_wifi_recent.ini
        sudo chmod 666 /tmp/openauto_wifi_recent.ini
    fi
}

if [[ $2 == "AP-STA-CONNECTED" ]]; then
  echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] Someone has connected:" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] mac id $3 on $1" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
  log_echo "Someone has connected: mac id $3 on $1"
  sleep 5
  update_recent
fi

if [[ $2 == "AP-STA-DISCONNECTED" ]]; then
  echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] Someone has disconnected:" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] mac id $3 on $1" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] Removing $3 from dnsmasq.leases..." >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
  log_echo "Someone has disconnected: mac id $3 on $1"
  log_echo "Removing $3 from dnsmasq.leases..."
  sed -i '/'$3'/d' /tmp/dnsmasq.leases
  sudo systemctl restart dnsmasq
  update_recent
fi
