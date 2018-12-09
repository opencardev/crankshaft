#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

if [ ! -f /tmp/dev_mode_enabled ]; then
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] Starting timers" >/dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
    log_echo "Start timers"
    /usr/local/bin/crankshaft timers start &
else
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] Skipping start timers by dev mode enabled..." >/dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
    log_echo "Skip starting  timers"
fi

exit 0
