#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /opt/crankshaft/crankshaft_system_env.sh

splash=1
# give pulse audio a moment to check for audio hardware
sleep 2

#
# check outputs
#
pa_device=$(cat /etc/pulse/client.conf | grep 'default-sink =' | cut -d= -f2 | sed 's/\t//g' | sed 's/^ //' | sed 's/ *$//')
# available device count
countdevices=$(pactl list sinks short | grep -v bluez | awk {'print $2'} | wc -l)

if [ "$countdevices" == "1" ]; then
    card=$(pactl list sinks short | grep -v bluez | awk {'print $2'})
    if [ "$card" == "auto_null" ]; then
        if [ $splash -eq 1 ]; then
            show_clear_screen
            show_cursor
            splash=0
        fi
        echo "${RESET}" > /dev/tty3
        echo "[${RED}${BOLD} FAIL ${RESET}] *******************************************************" > /dev/tty3
        echo "[${RED}${BOLD} FAIL ${RESET}] Pulseaudio: no output device!" > /dev/tty3
        echo "[${RED}${BOLD} FAIL ${RESET}] *******************************************************" > /dev/tty3
    else
        if [ "$card" != "$pa_device" ]; then
            if [ $splash -eq 1 ]; then
                show_clear_screen
                show_cursor
                splash=0
            fi
            echo "${RESET}" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Pulseaudio: changed output device! -> Configure..." > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            /usr/local/bin/crankshaft filesystem system unlock
            sed -i 's/.*default-sink.*//' /etc/pulse/client.conf
            sed -i 's/^# Crankshaft selected output device.*//' /etc/pulse/client.conf
            sed -i 's/^# no output selected -> default.*//' /etc/pulse/client.conf
            sed -i '/./,/^$/!d' /etc/pulse/client.conf
            echo "" >>  /etc/pulse/client.conf
            echo "# Crankshaft selected output device" >> /etc/pulse/client.conf
            echo "default-sink = $card" >> /etc/pulse/client.conf
            /usr/local/bin/crankshaft filesystem system lock
        fi
    fi
else
    if [ $splash -eq 1 ]; then
        show_clear_screen
        show_cursor
        splash=0
    fi
    if [ "$countdevices" == "0" ]; then
        echo "${RESET}" > /dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] Pulseaudio has detected no outputs!" > /dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] Add an audio output device!" > /dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
    else
        echo "${RESET}" > /dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] Pulseaudio has detected multiple outputs!" > /dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] Enter settings in openauto and select your card!" > /dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
    fi
fi

#
# check inputs
#
pa_inputdevice=$(cat /etc/pulse/client.conf | grep 'default-source =' | cut -d= -f2 | sed 's/\t//g' | sed 's/^ //' | sed 's/ *$//')
# available device count
countinputdevices=$(pactl list sources short | grep -v bluez | grep -v monitor | awk {'print $2'} | wc -l)

if [ "$countinputdevices" == "1" ]; then
    inputcard=$(pactl list sources short | grep -v bluez | grep -v monitor | awk {'print $2'})
    if [ "$card" == "auto_null" ]; then
        if [ $splash -eq 1 ]; then
            show_clear_screen
            show_cursor
            splash=0
        fi
        echo "${RESET}" > /dev/tty3
        echo "[${RED}${BOLD} FAIL ${RESET}] *******************************************************" > /dev/tty3
        echo "[${RED}${BOLD} FAIL ${RESET}] Pulseaudio: no input device!" > /dev/tty3
        echo "[${RED}${BOLD} FAIL ${RESET}] *******************************************************" > /dev/tty3
    else
        if [ "$inputcard" != "$pa_inputdevice" ]; then
            if [ $splash -eq 1 ]; then
                show_clear_screen
                show_cursor
                splash=0
            fi
            echo "${RESET}" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Pulseaudio: changed input device! -> Configure..." > /dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
            /usr/local/bin/crankshaft filesystem system unlock
            sed -i 's/.*default-source.*//' /etc/pulse/client.conf
            sed -i 's/^# Crankshaft selected input device.*//' /etc/pulse/client.conf
            sed -i 's/^# no input selected -> default.*//' /etc/pulse/client.conf
            sed -i '/./,/^$/!d' /etc/pulse/client.conf
            echo "" >>  /etc/pulse/client.conf
            echo "# Crankshaft selected input device" >> /etc/pulse/client.conf
            echo "default-source = $inputcard" >> /etc/pulse/client.conf
            /usr/local/bin/crankshaft filesystem system lock
        fi
    fi
else
    if [ $splash -eq 1 ]; then
        show_clear_screen
        show_cursor
        splash=0
    fi
    if [ "$countinputdevices" == "0" ]; then
        echo "${RESET}" > /dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] Pulseaudio has detected no inputs!" > /dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] Add an audio input device!" > /dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
    else
        echo "${RESET}" > /dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] Pulseaudio has detected multiple inputs!" > /dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] Enter settings in openauto and select your card!" > /dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" > /dev/tty3
    fi
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
        if [ $splash -eq 1 ]; then
            show_clear_screen
            show_cursor
            splash=0
        fi
        echo "${RESET}" > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] Pulseaudio: params need adjustment - Configure..." > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}]" > /dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] Device: $pa_device" > /dev/tty3
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
        if [ -f /tmp/usb_debug_mode ]; then
            systemctl restart pulseaudio-debug
        else
            systemctl restart pulseaudio
        fi
    fi
fi

exit 0
