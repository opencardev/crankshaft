#!/bin/bash -e

# enable headset mode and allow auto switch between hfp and a2dp
sed -i 's/load-module module-bluetooth-discover.*/load-module module-bluetooth-discover headset=auto/' /etc/pulse/default.pa
sed -i 's/load-module module-bluetooth-discover.*/load-module module-bluetooth-discover headset=auto/' /etc/pulse/system.pa

# enable correct service state
systemctl disable bluetooth
systemctl disable hciuart
systemctl disable ofono
systemctl enable csng-bluetooth
systemctl enable btautopair
systemctl enable btdevicedetect
systemctl enable btrestore

# config.txt
echo "" >> /boot/config.txt
echo "# Bluetooth" >> /boot/config.txt
echo "dtoverlay=pi3-disable-bt" >> /boot/config.txt

usermod -G bluetooth -a pi
usermod -G bluetooth -a pulse
usermod -G bluetooth -a root

# Enable compat and disable sap
sed -i 's/ExecStart=.*/ExecStart=\/usr\/lib\/bluetooth\/bluetoothd --compat --noplugin=sap/' /lib/systemd/system/bluetooth.service

# Set default bt privacy
sed -i '/# Privacy = off/Privacy = off/' /etc/bluetooth/main.conf

#link test script files
ln -s /usr/share/doc/bluez-test-scripts/examples/list-devices /usr/local/bin/list-devices
ln -s /usr/share/doc/bluez-test-scripts/examples/monitor-bluetooth /usr/local/bin/monitor-bluetooth
ln -s /usr/share/doc/bluez-test-scripts/examples/test-adapter /usr/local/bin/test-adapter
ln -s /usr/share/doc/bluez-test-scripts/examples/test-heartrate /usr/local/bin/test-heartrate
ln -s /usr/share/doc/bluez-test-scripts/examples/test-manager /usr/local/bin/test-manager
ln -s /usr/share/doc/bluez-test-scripts/examples/test-nap /usr/local/bin/test-nap
ln -s /usr/share/doc/bluez-test-scripts/examples/test-network /usr/local/bin/test-network
ln -s /usr/share/doc/bluez-test-scripts/examples/test-profile /usr/local/bin/test-profile
ln -s /usr/share/doc/bluez-test-scripts/examples/test-proximity /usr/local/bin/test-proximity
ln -s /usr/share/doc/bluez-test-scripts/examples/test-sap-server /usr/local/bin/test-sap-server
ln -s /usr/share/doc/bluez-test-scripts/examples/test-thermometer /usr/local/bin/test-thermometer
