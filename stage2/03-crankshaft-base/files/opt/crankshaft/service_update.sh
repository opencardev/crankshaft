#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
if [ -f /boot/crankshaft/crankshaft_env.sh ];then
    source /boot/crankshaft/crankshaft_env.sh
fi

if [ "`ping -c 1 google.com`" ];then
    log_echo "Internet connection available"
    # Check udev rules
    wget -q -O /tmp/51-android.rules.md5 --no-check-certificate https://raw.githubusercontent.com/opencardev/prebuilts/master/udev/51-android.rules.md5
    REMOTE_UDEV=$(cat /tmp/51-android.rules.md5 | awk {'print $1'})
    LOCAL_UDEV=$(md5sum /etc/udev/rules.d/51-android.master | awk {'print $1'})
    rm /tmp/51-android.rules.md5

    # Check crankshaft amangement tool
    wget -q --no-check-certificate -O /tmp/crankshaft.md5 https://raw.githubusercontent.com/opencardev/prebuilts/master/csmt/crankshaft.md5
    REMOTE_CSMT=$(cat /tmp/crankshaft.md5 | awk {'print $1'})
    LOCAL_CSMT=$(md5sum /usr/local/bin/crankshaft | awk {'print $1'})
    rm /tmp/crankshaft.md5

    # Notifications

    # udev
    if [ "$REMOTE_UDEV" != "$LOCAL_UDEV" ];then
        log_echo "New udev rules available"
        echo "[${RED}${BOLD} NOTE ${RESET}] *******************************************************" >/dev/tty3
        echo "[${RED}${BOLD} NOTE ${RESET}] New udev device rules are available." >/dev/tty3
        echo "[${RED}${BOLD} NOTE ${RESET}] Login and use 'crankshaft update udev' to update." >/dev/tty3
        echo "[${RED}${BOLD} NOTE ${RESET}] *******************************************************" >/dev/tty3
    fi
    # csmt
    if [ "$REMOTE_CSMT" != "$LOCAL_CSMT" ];then
        log_echo "New csmt available"
        echo "[${RED}${BOLD} NOTE ${RESET}] *******************************************************" >/dev/tty3
        echo "[${RED}${BOLD} NOTE ${RESET}] New crankshaft management tool is available." >/dev/tty3
        echo "[${RED}${BOLD} NOTE ${RESET}] Login and use 'crankshaft update csmt' to update." >/dev/tty3
        echo "[${RED}${BOLD} NOTE ${RESET}] *******************************************************" >/dev/tty3
    fi
fi

exit 0
