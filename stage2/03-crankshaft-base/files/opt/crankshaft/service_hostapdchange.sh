#!/bin/bash

source /opt/crankshaft/crankshaft_system_env.sh

if [[ $2 == "AP-STA-CONNECTED" ]]
then
  echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] Someone has connected:" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] mac id $3 on $1" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
fi

if [[ $2 == "AP-STA-DISCONNECTED" ]]
then
  echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] Someone has disconnected:" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] mac id $3 on $1" >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] Removing $3 from dnsmasq.leases..." >/dev/tty3
  echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
  sed -i '/'$3'/d' /tmp/dnsmasq.leases
  sudo systemctl restart dnsmasq
fi
