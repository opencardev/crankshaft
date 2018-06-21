#!/bin/bash

# colors
RED=`tput setaf 1 -T xterm`
GREEN=`tput setaf 2 -T xterm`
YELLOW=`tput setaf 3 -T xterm`
CYAN=`tput setaf 6 -T xterm`
MAGENTA=`tput setaf 5 -T xterm`
RESET=`tput sgr0 -T xterm`
BOLD=`tput bold -T xterm`

# set gpio default pin levels if global activated
if [ ! -z $ENABLE_GPIO ]; then
    if [ $ENABLE_GPIO -eq 1 ]; then
        sudo /usr/bin/gpio -g mode $DEV_PIN up
        sudo /usr/bin/gpio -g mode $INVERT_PIN up
        sudo /usr/bin/gpio -g mode $X11_PIN up
    else
        # make sure flag is correctly set if
        # ENABLE_GPIO is not set to 1 or missing
        # to prevent from errors
        ENABLE_GPIO=0
    fi
fi
