#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
source /boot/crankshaft/crankshaft_env.sh

# Check udev rules
REMOTE_UDEV=`wget --no-check-certificate https://raw.githubusercontent.com/opencardev/prebuilts/master/udev/51-android.rules --spider --server-response -O - 2>&1 | sed -ne '/Content-Length/{s/.*: //;p}'`

if [ -f /etc/udev/rules.d/51-android.master ]; then
    LOCAL_UDEV=`wc -c /etc/udev/rules.d/51-android.master | awk '{print $1}'`
else
    LOCAL_UDEV=0
fi

# Check crankshaft amangement tool
REMOTE_CSMT=`wget --no-check-certificate https://raw.githubusercontent.com/opencardev/prebuilts/master/csmt/crankshaft --spider --server-response -O - 2>&1 | sed -ne '/Content-Length/{s/.*: //;p}'`

if [ -f /usr/local/bin/crankshaft ]; then
    LOCAL_CSMT=`wc -c /usr/local/bin/crankshaft | awk '{print $1}'`
else
    LOCAL_CSMT=0
fi

if [ "`ping -c 1 google.com`" ];then
    # udev
    if [ "$REMOTE_UDEV" != "$LOCAL_UDEV" ];then
        echo "[${RED}${BOLD} NOTE ${RESET}] *******************************************************" >/dev/tty3
        echo "[${RED}${BOLD} NOTE ${RESET}] New udev device rules are available." >/dev/tty3
        echo "[${RED}${BOLD} NOTE ${RESET}] Login and use 'crankshaft update udev' to update." >/dev/tty3
        echo "[${RED}${BOLD} NOTE ${RESET}] *******************************************************" >/dev/tty3
    fi
    # csmt
    if [ "$REMOTE_CSMT" != "$LOCAL_CSMT" ];then
        echo "[${RED}${BOLD} NOTE ${RESET}] *******************************************************" >/dev/tty3
        echo "[${RED}${BOLD} NOTE ${RESET}] New crankshaft management tool is available." >/dev/tty3
        echo "[${RED}${BOLD} NOTE ${RESET}] Login and use 'crankshaft update csmt' to update." >/dev/tty3
        echo "[${RED}${BOLD} NOTE ${RESET}] *******************************************************" >/dev/tty3
    fi
fi

exit 0
