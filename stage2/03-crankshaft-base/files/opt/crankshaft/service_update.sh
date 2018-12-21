#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

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

    # Check openauto
    wget -q --no-check-certificate -O /tmp/autoapp.md5 https://raw.githubusercontent.com/opencardev/prebuilts/master/openauto/autoapp.md5
    REMOTE_OPENAUTO=$(cat /tmp/autoapp.md5 | awk {'print $1'})
    LOCAL_OPENAUTO=$(md5sum /usr/local/bin/autoapp | awk {'print $1'})
    rm /tmp/autoapp.md5

    # Notifications

    # udev
    if [ "$REMOTE_UDEV" != "$LOCAL_UDEV" ];then
        echo "[${RED}${BOLD} NOTE ${RESET}] *******************************************************" >/dev/tty3
        echo "[${RED}${BOLD} NOTE ${RESET}] New udev device rules are available." >/dev/tty3
        echo "[${RED}${BOLD} NOTE ${RESET}] Login and use 'crankshaft update udev' to update." >/dev/tty3
        echo "[${RED}${BOLD} NOTE ${RESET}] *******************************************************" >/dev/tty3
        log_echo "New udev rules available"
        touch /tmp/udev_update_available
    fi
    # csmt
    if [ "$REMOTE_CSMT" != "$LOCAL_CSMT" ];then
        echo "[${RED}${BOLD} NOTE ${RESET}] *******************************************************" >/dev/tty3
        echo "[${RED}${BOLD} NOTE ${RESET}] New crankshaft management tool is available." >/dev/tty3
        echo "[${RED}${BOLD} NOTE ${RESET}] Login and use 'crankshaft update csmt' to update." >/dev/tty3
        echo "[${RED}${BOLD} NOTE ${RESET}] *******************************************************" >/dev/tty3
        log_echo "New csmt available"
        touch /tmp/csmt_update_available
    fi
    # openauto
    if [ "$REMOTE_OPENAUTO" != "$LOCAL_OPENAUTO" ];then
        echo "[${RED}${BOLD} NOTE ${RESET}] *******************************************************" >/dev/tty3
        echo "[${RED}${BOLD} NOTE ${RESET}] New openauto build is available." >/dev/tty3
        echo "[${RED}${BOLD} NOTE ${RESET}] Login and use 'crankshaft update openauto' to update." >/dev/tty3
        echo "[${RED}${BOLD} NOTE ${RESET}] *******************************************************" >/dev/tty3
        log_echo "New openauto available"
        touch /tmp/openauto_update_available
    fi
    # no updates
    if [ "$REMOTE_CSMT" == "$LOCAL_CSMT" ] && [ "$REMOTE_UDEV" == "$LOCAL_UDEV" ] && [ "$REMOTE_OPENAUTO" == "$LOCAL_OPENAUTO" ];then
        echo "[${GREEN}${BOLD}  OK  ${RESET}] *******************************************************" >/dev/tty3
        echo "[${GREEN}${BOLD}  OK  ${RESET}] No new updates." >/dev/tty3
        echo "[${GREEN}${BOLD}  OK  ${RESET}] *******************************************************" >/dev/tty3
        log_echo "No new updates"
    fi


fi

exit 0
