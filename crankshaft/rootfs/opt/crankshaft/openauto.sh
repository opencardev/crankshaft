#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /boot/crankshaft/crankshaft_env.sh

# Starts the Autoapp (OpenAuto) main program
if [ $START_X11 -ne 0 ] || [ `gpio -g read $X11_PIN` -eq 0 ] ; then
    # This is when the X11 pin is connected to ground (X11 enabled)
    # We don't call autoapp here, we call it in .xinitrc
    # xinit will read and call autoapp in .xinitrc
    # If you need to make any graphical program run before the Autoapp
    # edit /home/pi/.xinitrc
    sed -i "s/^OMXLayerIndex=.*$/OMXLayerIndex=0/" ~/openauto.ini
    xinit
else
    # EGLFS - crankshaft "normal" mode
    # we don't have to call xinit, just start autoapp directly
    sed -i "s/^OMXLayerIndex=.*$/OMXLayerIndex=2/" ~/openauto.ini
    /usr/local/bin/autoapp
fi

# Check if autoapp crashed
if [ $? -eq 0 ]; then
    # if it exits normally, it the user must have quit the app
    # save and shutdown
    /opt/crankshaft/dumb_suid openauto_settings_save.sh
    /opt/crankshaft/dumb_suid power_off.sh
else
    echo "Unfortunately, OpenAuto crashed. Please report this incident to Crankshaft."
fi
