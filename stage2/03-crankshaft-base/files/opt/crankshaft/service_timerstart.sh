#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
if [ -f /boot/crankshaft/crankshaft_env.sh ]; then
    source /boot/crankshaft/crankshaft_env.sh
fi

if [ ! -f /tmp/dev_mode_enabled ]; then
    log_echo "Start timers"
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] Starting timers" >/dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
    /usr/local/bin/crankshaft timers start &
else
    log_echo "Skip starting  timers"
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] Skipping start timers by dev mode enabled..." >/dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
fi

exit 0
