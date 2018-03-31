#!/bin/bash

X11_PIN=26
gpio -g mode $X11_PIN up

if [ `gpio -g read $X11_PIN` -eq 0 ] ; then
    sed -i "s/^OMXLayerIndex=.*$/OMXLayerIndex=0/" ~/.config/openauto.ini
    xinit
else
    sed -i "s/^OMXLayerIndex=.*$/OMXLayerIndex=2/" ~/.config/openauto.ini
    /usr/local/bin/autoapp
fi
if [ $? -eq 0 ]; then
	/opt/crankshaft/dumb_suid openauto_settings_save.sh
	/opt/crankshaft/dumb_suid power_off.sh
else
	echo "Unfortunately, OpenAuto crashed. Please report this incident to Crankshaft."
fi
