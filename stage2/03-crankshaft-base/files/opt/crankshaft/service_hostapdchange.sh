#!/bin/bash

source /opt/crankshaft/crankshaft_system_env.sh

if [[ $2 == "AP-STA-CONNECTED" ]]
then
  echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] Someone has connected:" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] mac id $3 on $1" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
  log_echo "Someone has connected: mac id $3 on $1"
  sleep 5
  /usr/local/bin/autoapp_helper updaterecent
fi

if [[ $2 == "AP-STA-DISCONNECTED" ]]
then
  echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] Someone has disconnected:" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] mac id $3 on $1" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] Removing $3 from dnsmasq.leases..." >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
  log_echo "Someone has disconnected: mac id $3 on $1"
  log_echo "Removing $3 from dnsmasq.leases..."
  sed -i '/'$3'/d' /tmp/dnsmasq.leases
  sudo systemctl restart dnsmasq
  sleep 5
  /usr/local/bin/autoapp_helper updaterecent
fi
