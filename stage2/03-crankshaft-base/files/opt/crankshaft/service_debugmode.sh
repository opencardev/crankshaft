#!/bin/bash

# debug mode related stuff

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
source /boot/crankshaft/crankshaft_env.sh

echo "[${BLUE}${BOLD}DEBUG ${RESET}] Debug Mode Enabled"
echo "nameserver 8.8.8.8" > /tmp/resolv.conf
echo "nameserver 8.8.4.4" >> /tmp/resolv.conf
systemctl start ssh.service &
echo "[${BLUE}${BOLD}DEBUG ${RESET}] Debug Mode - Start SSH"
systemctl start dhcpcd.service & > /dev/null 2>&1
echo "[${BLUE}${BOLD}DEBUG ${RESET}] Debug Mode - Start DHCPCD"
systemctl start networking.service &
echo "[${BLUE}${BOLD}DEBUG ${RESET}] Debug Mode - Start NET"
