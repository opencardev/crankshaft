#!/bin/bash +e

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

function checkdevice {
    device=$1
    dline=$(echo $device | cut -c1)
    drow=$(echo $device | cut -c2)
    if [ "$drow" == "a" ]; then
        drow=10
    fi
    if [ "$drow" == "b" ]; then
        drow=11
    fi
    if [ "$drow" == "c" ]; then
        drow=12
    fi
    if [ "$drow" == "d" ]; then
        drow=13
    fi
    if [ "$drow" == "e" ]; then
        drow=14
    fi
    if [ "$drow" == "f" ]; then
        drow=15
    fi
    counter=0
    i2cdetect -y 1 | tail -n8 | while read line; do
        line=$(echo $line | cut -d: -f2)
        if [ "$counter" == "0" ]; then
            line="-- -- -- $line"
        fi
        IFS=' ' read -r -a array <<< "$line"
        if [ "$dline" == "$counter" ]; then
            if [ "${array[$drow]}" == "$device" ]; then
                return 1
            elif [ "${array[$drow]}" == "UU" ]; then
                return 1
            else
                return 0
            fi
        fi
        counter=$((counter+1))
    done
}

if [ "$(i2cdetect -l | grep i2c-1)" != "" ]; then
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] I2C bus enabled." > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
    log_echo "I2C bus enabled."

    # check for rtc in config.txt
    RTC=$(cat /boot/config.txt | grep dtoverlay=i2c-rtc | tail -n1)

    if [ "$RTC" != "" ]; then
        checkdevice 68
        if [ $? -eq 1 ]; then
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Check for rtc ok. Device at 0x68 is present." > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
        else
            show_screen
            echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
            echo "[${RED}${BOLD} WARN ${RESET}] Check for rtc failed. Device at 0x68 is missing!" > /dev/tty3
            echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
            log_echo "Check for rtc failed. Seems device at 0x68 is missing!"
        fi
    fi

    # check for lightsensor
    if [ -f /etc/cs_lightsensor ]; then
        checkdevice 39
        if [ $? -eq 1 ]; then
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Check for tsl2561 ok. Device at 0x39 is present." > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
        else
            show_screen
            echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
            echo "[${RED}${BOLD} WARN ${RESET}] Check for tsl2561 failed. Device at 0x39 is missing!" > /dev/tty3
            echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
            log_echo "Check for tsl2561 failed. Seems device at 0x39 is missing!"
        fi
    fi
else
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] I2C bus disabled - skip checks." > /dev/tty3
    echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
    log_echo "I2C bus disabled - skip checks."
fi

exit 0
