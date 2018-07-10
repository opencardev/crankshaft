#!/bin/bash

# Start only if trigger file is detected
if [ -f /tmp/start_openauto ]; then
    source /opt/crankshaft/crankshaft_default_env.sh
    source /opt/crankshaft/crankshaft_system_env.sh
    source /boot/crankshaft/crankshaft_env.sh

    # Restore openauto.ini
    /usr/local/bin/crankshaft settings restore
    /usr/local/bin/crankshaft audio volume restore

    # Make sure display is on
    /usr/local/bin/crankshaft display on

    # Check gpio if activated
    if [ $ENABLE_GPIO -eq 1 ] && [ $X11_PIN -ne 0 ]; then
        X11_MODE_GPIO=`gpio -g read $X11_PIN`
    else
        X11_MODE_GPIO=1 # 1 = untriggered
    fi

    if [ $START_X11 -ne 0 ] || [ $X11_MODE_GPIO -ne 1 ]; then
        # This is when the X11 pin is connected to ground (X11 enabled)
        # We don't call autoapp here, we call it in .xinitrc
        # xinit will read and call autoapp in .xinitrc
        # If you need to make any graphical program run before the Autoapp
        # edit /home/pi/.xinitrc
        echo "" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] Starting OpenAuto in X11 Mode" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        sed -i "s/^OMXLayerIndex=.*$/OMXLayerIndex=0/" /tmp/openauto.ini
        # Starts the Autoapp (OpenAuto) main program via x-server
        sudo runuser -l pi -c 'xinit'
    else
        # EGLFS - crankshaft "normal" mode
        # we don't have to call xinit, just start autoapp directly
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
        # if it exits normally, it the user must have quit the app
        # save and shutdown
        echo "" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] Saving settings..." >/dev/tty3
        echo "[${CYAN}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
        /usr/local/bin/crankshaft settings save
        /usr/local/bin/crankshaft brightness save
        /usr/local/bin/crankshaft audio volume save

        if [ ! -f /etc/cs_first_start_done ]; then
            /usr/local/bin/crankshaft filesystem system unlock
            sudo touch /etc/cs_first_start_done
            /usr/local/bin/crankshaft filesystem system lock
        fi

        if [ ! -f /tmp/dev_mode_enabled ]; then
            if [ -f /tmp/reboot ]; then
                sudo reboot
            else
                sudo shutdown -P now
            fi
        else
            if [ $DEV_MODE_APP -eq 1 ]; then
                if [ -f /tmp/reboot ]; then
                    echo "" >/dev/tty3
                    echo "[${RED}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
                    echo "[${RED}${BOLD} INFO ${RESET}] You are in Dev Mode OpenAuto." >/dev/tty3
                    echo "[${RED}${BOLD} INFO ${RESET}] System will reboot in 60 seconds automatically." >/dev/tty3
                    echo "[${RED}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
                    sudo shutdown -r -t 1
                else
                    echo "" >/dev/tty3
                    echo "[${RED}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
                    echo "[${RED}${BOLD} INFO ${RESET}] You are in Dev Mode OpenAuto." >/dev/tty3
                    echo "[${RED}${BOLD} INFO ${RESET}] System will shutdown in 60 seconds automatically." >/dev/tty3
                    echo "[${RED}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
                    sudo shutdown -P -t 1
                fi
            else
                echo "" >/dev/tty3
                echo "[${RED}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
                echo "[${RED}${BOLD} INFO ${RESET}] You are in Dev Mode Shell." >/dev/tty3
                echo "[${RED}${BOLD} INFO ${RESET}] System will not reboot automatically." >/dev/tty3
                echo "[${RED}${BOLD} INFO ${RESET}] *******************************************************" >/dev/tty3
            fi
        fi
    else
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
