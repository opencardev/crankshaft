#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

if [ "${CUSTOM_BRIGHTNESS_COMMAND}" != "" ] && [ -f ${CUSTOM_BRIGHTNESS_COMMAND} ]; then
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] Custom brightness command set - start service loop" >/dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
    oldvalue=0
    while true; do
        if [ -f /tmp/custombrightness ];then
            currentvalue=$(cat /tmp/custombrightness)
            if [ $currentvalue -ne $oldvalue ]; then
                ${CUSTOM_BRIGHTNESS_COMMAND} $currentvalue
                oldvalue=$currentvalue
            fi
        fi
        sleep 0.25
    done
else
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] Custom brightness command not used - ignore" >/dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
fi
