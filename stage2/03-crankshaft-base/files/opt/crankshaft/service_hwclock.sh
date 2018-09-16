#!/bin/bash

source /opt/crankshaft/crankshaft_system_env.sh

echo "" >/dev/tty3
echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
echo "[${CYAN}${BOLD} INFO ${RESET}] Got RTC Time: $(hwclock -r)" >/dev/tty3
echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3

hwclock --hctosys
