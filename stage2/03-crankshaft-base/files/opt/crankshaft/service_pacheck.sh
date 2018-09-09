#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh
if [ -f /boot/crankshaft/crankshaft_env.sh ]; then
    source /boot/crankshaft/crankshaft_env.sh
fi

# give pulse audio a moment to check for soundcards
sleep 2

# get possible set soundcard
pa_device=$(cat /etc/pulse/client.conf | grep 'default-sink =' | cut -d= -f2 | sed 's/\t//g' | sed 's/^ //' | sed 's/ *$//')
# available device count
countdevices=$(pactl list sinks short | awk {'print $2'} | wc -l)

if [ "$countdevices" == "1" ]; then
    card=$(pactl list sinks short | awk {'print $2'})
    if [ "$card" == "auto_null" ]; then
        show_clear_screen
        show_cursor
        echo "${RESET}" > /dev/tty3
        echo "[${RED}${BOLD} FAIL ${RESET}] *******************************************************" > /dev/tty3
        echo "[${RED}${BOLD} FAIL ${RESET}] Pulseaudio has not detected a soundcard" > /dev/tty3
        echo "[${RED}${BOLD} FAIL ${RESET}] *******************************************************" > /dev/tty3
        exit 0
    else
        if [ "$card" != "$pa_device" ]; then
            show_clear_screen
            show_cursor
            echo "${RESET}" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Pulseaudio has detected changed soundcard! -> Setup..." > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            /usr/local/bin/crankshaft filesystem system unlock
            sed -i 's/.*default-sink.*//' /etc/pulse/client.conf
            sed -i 's/^# Crankshaft selected output device.*//' /etc/pulse/client.conf
            sed -i 's/^# no output selected -> default.*//' /etc/pulse/client.conf
            sed -i '/./,/^$/!d' /etc/pulse/client.conf
            echo "" >>  /etc/pulse/daemon.conf
            echo "# Crankshaft selected output device" >> /etc/pulse/client.conf
            echo "default-sink = $card" >> /etc/pulse/client.conf
            /usr/local/bin/crankshaft filesystem system lock
        fi
    fi
else
    show_clear_screen
    show_cursor
    echo "${RESET}" > /dev/tty3
    echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
    echo "[${RED}${BOLD} WARN ${RESET}] Pulseaudio has detected multiple soundcards!" > /dev/tty3
    echo "[${RED}${BOLD} WARN ${RESET}] Enter settings in openauto and select your card!" > /dev/tty3
    echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
fi

# Set samplerate and sampleformat
pa_device=$(cat /etc/pulse/client.conf | grep 'default-sink =' | cut -d= -f2 | sed 's/\t//g' | sed 's/^ //' | sed 's/ *$//')
pa_samplerate=$(cat /etc/pulse/daemon.conf | grep 'default-sample-rate =' | cut -d= -f2 | sed 's/\t//g' | sed 's/^ //' | sed 's/ *$//')
pa_sampleformat=$(cat /etc/pulse/daemon.conf | grep 'default-sample-format =' | cut -d= -f2 | sed 's/\t//g' | sed 's/^ //' | sed 's/ *$//')

if [ ! -z $pa_device ]; then
    hw_samplerate=$(pactl list sinks short | grep $pa_device | tail -n1 | awk {'print $6'} | sed 's/Hz//' | sed 's/^ //' | sed 's/ *$//')
    hw_sampleformat=$(pactl list sinks short | grep $pa_device | tail -n1 | awk {'print $4'} | sed 's/^ //' | sed 's/ *$//')
fi

if [ ! -z $pa_device ] && [ ! -z $hw_samplerate ] && [ ! -z $hw_sampleformat ] && [ "$countdevices" == "1" ]; then
    if [ "$hw_samplerate" != "$pa_samplerate" ] || [ "$hw_sampleformat" != "$pa_sampleformat" ]; then
        show_clear_screen
        show_cursor
        echo "${RESET}" > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] Pulseaudio params needs adjustment - setup..." > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}]" > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] Device: $pa_device" > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}]" > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] HW Samplerate  : $hw_samplerate" > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] HW Sampleformat: $hw_sampleformat" > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
        /usr/local/bin/crankshaft filesystem system unlock
        # sample rate
        sed -i 's/^# Crankshaft detected sample rate.*//' /etc/pulse/daemon.conf
        sed -i 's/.*default-sample-rate =.*//' /etc/pulse/daemon.conf
        sed -i '/./,/^$/!d' /etc/pulse/daemon.conf
        echo "" >>  /etc/pulse/daemon.conf
        echo "# Crankshaft detected sample rate" >>  /etc/pulse/daemon.conf
        echo "default-sample-rate = $hw_samplerate" >>  /etc/pulse/daemon.conf
        # sample format
        sed -i 's/^# Crankshaft detected sample format.*//' /etc/pulse/daemon.conf
        sed -i 's/.*default-sample-format =.*//' /etc/pulse/daemon.conf
        sed -i '/./,/^$/!d' /etc/pulse/daemon.conf
        echo "" >>  /etc/pulse/daemon.conf
        echo "# Crankshaft detected sample format" >>  /etc/pulse/daemon.conf
        echo "default-sample-format = $hw_sampleformat" >>  /etc/pulse/daemon.conf
        /usr/local/bin/crankshaft filesystem system lock
        systemctl restart pulseaudio
    else
        echo "[${GREEN}${BOLD}  OK  ${RESET}] *******************************************************" > /dev/tty3
        echo "[${GREEN}${BOLD}  OK  ${RESET}] Pulseaudio setup is ok" > /dev/tty3
        echo "[${GREEN}${BOLD}  OK  ${RESET}] *******************************************************" > /dev/tty3
    fi
fi

exit 0
