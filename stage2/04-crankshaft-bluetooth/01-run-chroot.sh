#!/bin/bash -e

# enable headset mode and allow auto switch between hfp and a2dp
sed -i 's/load-module module-bluetooth-discover.*/load-module module-bluetooth-discover headset=auto/' /etc/pulse/default.pa

# enable correct service state
systemctl disable bluetooth
systemctl disable hciuart
systemctl disable ofono
systemctl disable autopair
systemctl disable autoconnect
systemctl enable csng-bluetooth
