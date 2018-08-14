#!/bin/bash

# Start only if trigger file is detected
if [ -f /tmp/start_openauto ]; then
    source /opt/crankshaft/crankshaft_default_env.sh
    source /opt/crankshaft/crankshaft_system_env.sh
    if [ -f /boot/crankshaft/crankshaft_env.sh ];then
        source /boot/crankshaft/crankshaft_env.sh
    fi

    # Restore openauto.ini
    log_echo "Restoring settings"
    /usr/local/bin/crankshaft settings restore

    # restore alsa state - volumes restored by openauto
    log_echo "Restoring alsastate"
    /usr/local/bin/crankshaft audio alsastate restore

    # Make sure display is on
    /usr/local/bin/crankshaft display on

    # check for day/night on startup
    if [ $RTC_DAYNIGHT -eq 1 ]; then
        if [ $(date +%H) -gt $((RTC_DAY_START-1)) ] && [ $(date +%H) -lt $RTC_NIGHT_START ]; then
            sudo rm /tmp/night_mode_enabled
            /usr/local/bin/crankshaft brightness restore
        else
            touch /tmp/night_mode_enabled
            /usr/local/bin/crankshaft brightness restore
        fi
    fi

    # Check gpio if activated
    if [ $ENABLE_GPIO -eq 1 ] && [ $X11_PIN -ne 0 ]; then
        X11_MODE_GPIO=`gpio -g read $X11_PIN`
    else
        X11_MODE_GPIO=1 # 1 = untriggered
    fi

    # start pulseaudio
    log_echo "Starting pulseaudio"
    sudo killall pulseaudio
    # remove old temp files
    sudo rm -f /tmp/get_inputs > /dev/null 2>&1
    sudo rm -f /tmp/get_outputs > /dev/null 2>&1
    sudo rm -f /tmp/get_default_input > /dev/null 2>&1
    sudo rm -f /tmp/get_default_output > /dev/null 2>&1
    sudo runuser -l pi -c 'pulseaudio --start --log-target syslog'
    sleep 1 # give a small relax time
    # check for pulseaudio dummy output
    nodevice=$(sudo runuser -l pi -c 'pactl list sinks' | grep 'Description: Dummy Output' | sed 's/"//g' | sed 's/\t//g' | sed 's/ //g' | sed 's/://g' | tail -n1)
    if [ $nodevice == "" ]; then
        log_echo "Re-Starting pulseaudio cause no device available"
        echo "" >/dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" >/dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] Pulseaudio could not detect a device - Restarting..." >/dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" >/dev/tty3
        # restart pulseaudio cause no hardware device was available
        sudo killall pulseaudio
        # remove old temp files
        sudo rm -f /tmp/get_inputs > /dev/null 2>&1
        sudo rm -f /tmp/get_outputs > /dev/null 2>&1
        sudo rm -f /tmp/get_default_input > /dev/null 2>&1
        sudo rm -f /tmp/get_default_output > /dev/null 2>&1
        sudo runuser -l pi -c 'pulseaudio --start --log-target syslog'
        sleep 1 # give a small relax time
    fi

    if [ $START_X11 -ne 0 ] || [ $X11_MODE_GPIO -ne 1 ]; then
        # This is when the X11 pin is connected to ground (X11 enabled)
        # We don't call autoapp here, we call it in .xinitrc
        # xinit will read and call autoapp in .xinitrc
        # If you need to make any graphical program run before the Autoapp
        # edit /home/pi/.xinitrc
        log_echo "Starting OpenAuto in X11 Mode"
        echo "" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] Starting OpenAuto in X11 Mode" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        # short delay to be sure system is ready
        sleep 2
        sed -i "s/^OMXLayerIndex=.*$/OMXLayerIndex=0/" /tmp/openauto.ini
        # Starts the Autoapp (OpenAuto) main program via x-server
        sudo runuser -l pi -c 'xinit'
    else
        # EGLFS - crankshaft "normal" mode
        # we don't have to call xinit, just start autoapp directly
        log_echo "Starting OpenAuto in EGL Mode"
        echo "" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] Starting OpenAuto in EGL Mode" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        sed -i "s/^OMXLayerIndex=0.*$/OMXLayerIndex=2/" /tmp/openauto.ini
        # Starts the Autoapp (OpenAuto) main program
        sudo runuser -l pi -c '/usr/local/bin/autoapp'
    fi

    # Check if autoapp crashed
    if [ $? -eq 0 ]; then
        log_echo "Clean exit openauto"
        # if it exits normally, it the user must have quit the app
        # save and shutdown
        log_echo "Saving settings"
        echo "" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] Saving settings..." >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        /usr/local/bin/crankshaft settings save
        log_echo "Saving brightness"
        echo "" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] Saving brightness..." >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        /usr/local/bin/crankshaft brightness save
        log_echo "Saving alsastate"
        echo "" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] Saving alsastate..." >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        /usr/local/bin/crankshaft audio alsastate save

        if [ $ENABLE_BLUETOOTH -eq 1 ]; then
            log_echo "Saving bluetooth"
            echo "" >/dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] Saving bluetooth..." >/dev/tty3
            echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
            /usr/local/bin/crankshaft bluetooth save
        fi

        if [ ! -f /etc/cs_first_start_done ]; then
            /usr/local/bin/crankshaft filesystem system unlock
            log_echo "Set first start done"
            sudo touch /etc/cs_first_start_done
            /usr/local/bin/crankshaft filesystem system lock
        fi

        if [ ! -f /tmp/dev_mode_enabled ]; then
            if [ -f /tmp/reboot ]; then
                log_echo "Exit openauto - reboot"
                sudo reboot
            else
                log_echo "Exit openauto - shutdown"
                sudo shutdown -P now
            fi
        else
            if [ $DEV_MODE_APP -eq 1 ]; then
                if [ -f /tmp/reboot ]; then
                    log_echo "Exit openauto - dev mode - wait to reboot"
                    echo "" >/dev/tty3
                    echo "[${RED}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
                    echo "[${RED}${BOLD} INFO ${RESET}] You are in Dev Mode OpenAuto." >/dev/tty3
                    echo "[${RED}${BOLD} INFO ${RESET}] System will reboot in 60 seconds automatically." >/dev/tty3
                    echo "[${RED}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
                    sudo shutdown -r -t 1
                else
                    log_echo "Exit openauto - dev mode - wait to shutdown"
                    echo "" >/dev/tty3
                    echo "[${RED}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
                    echo "[${RED}${BOLD} INFO ${RESET}] You are in Dev Mode OpenAuto." >/dev/tty3
                    echo "[${RED}${BOLD} INFO ${RESET}] System will shutdown in 60 seconds automatically." >/dev/tty3
                    echo "[${RED}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
                    sudo shutdown -t 1
                fi
            else
                log_echo "Dev mode shell - no reboot"
                echo "" >/dev/tty3
                echo "[${RED}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
                echo "[${RED}${BOLD} INFO ${RESET}] You are in Dev Mode Shell." >/dev/tty3
                echo "[${RED}${BOLD} INFO ${RESET}] System will not reboot automatically." >/dev/tty3
                echo "[${RED}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
            fi
        fi
    else
        log_echo "Openauto crashed"
        echo "" >/dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" >/dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] Unfortunately, OpenAuto crashed." >/dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] Please report this incident to Crankshaft." >/dev/tty3
        echo "[${RED}${BOLD} WARN ${RESET}] *******************************************************" >/dev/tty3
    fi

    exit 0
else
    exit 1
fi
