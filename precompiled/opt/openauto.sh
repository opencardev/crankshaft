#!/bin/bash

X11_PIN=26
gpio -g mode $X11_PIN up

#/opt/crankshaft/openauto_settings_restore.sh
cp ~/.openauto_saved.ini ~/.config/openauto.ini
if [ `gpio -g read $X11_PIN` -eq 0 ] ; then
    sed -i "s/^OMXLayerIndex=.*$/OMXLayerIndex=1/" ~/.config/openauto.ini
    xinit
else
    sed -i "s/^OMXLayerIndex=.*$/OMXLayerIndex=2/" ~/.config/openauto.ini
    /usr/local/bin/autoapp
fi
/opt/crankshaft/dumb_suid openauto_settings_save.sh
/opt/crankshaft/dumb_suid power_off.sh
