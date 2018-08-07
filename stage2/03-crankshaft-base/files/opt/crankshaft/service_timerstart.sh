#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
if [ -f /boot/crankshaft/crankshaft_env.sh ]; then
    source /boot/crankshaft/crankshaft_env.sh
fi

if [ ! -f /tmp/dev_mode_enabled ]; then
    log_echo "Start timers"
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] Starting Timers" >/dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
    /usr/local/bin/crankshaft timers start
fi

exit 0
