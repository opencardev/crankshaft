#!/bin/bash -e

# enable headset mode and allow auto switch between hfp and a2dp
sed -i 's/load-module module-bluetooth-discover.*/load-module module-bluetooth-discover headset=auto/' /etc/pulse/default.pa

# enable correct service state
systemctl disable bluetooth
systemctl disable hciuart
systemctl enable ofono
systemctl enable csng-bluetooth
systemctl enable btautopair
systemctl enable btautoconnect
systemctl enable btdevicedetect

# config.txt
echo "" >> /boot/config.txt
echo "# Bluetooth" >> /boot/config.txt
echo "dtoverlay=pi3-disable-bt" >> /boot/config.txt
