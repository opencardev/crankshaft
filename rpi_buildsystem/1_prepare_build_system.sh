#!/bin/bash

# Init
sudo apt-get update
sudo apt-get -y -q upgrade

# Apt packages to build aasdk
sudo apt-get install -y -q libboost-all-dev libusb-1.0.0-dev libssl-dev cmake libprotobuf-dev protobuf-c-compiler protobuf-compiler git

# Apt packages to build qt5
sudo apt-get -y -q install build-essential libfontconfig1-dev libdbus-1-dev libfreetype6-dev libicu-dev libsqlite3-dev libssl-dev libjpeg9-dev libglib2.0-dev  bluez libbluetooth-dev   libasound2-dev libgstreamer0.10-dev libgstreamer-plugins-base1.0-dev  libxkbcommon-dev libwayland-dev  libasound2-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev build-essential libfontconfig1-dev libdbus-1-dev libfreetype6-dev libicu-dev libinput-dev libxkbcommon-dev libsqlite3-dev  libglib2.0-dev libraspberrypi-dev libxcb1-dev libfontconfig1-dev libfreetype6-dev libx11-dev libxext-dev libxfixes-dev libxi-dev libxrender-dev libxcb1-dev libx11-xcb-dev libxcb-glx0-dev libts-dev pulseaudio libpulse-dev librtaudio5a librtaudio-dev libraspberrypi-bin libraspberrypi-dev

# Apt packages to build ilclient
sudo apt-get -y -q install rpi-update

# Apt packages to build openauto
#sudo apt-get install -y libqt5multimedia5 libqt5multimedia5-plugins libqt5multimediawidgets5 qtmultimedia5-dev libqt5bluetooth5 libqt5bluetooth5-bin qtconnectivity5-dev pulseaudio librtaudio-dev librtaudio5a
sudo apt-get remove --purge -y -q libqt5multimedia5 libqt5multimedia5-plugins libqt5multimediawidgets5 qtmultimedia5-dev libqt5bluetooth5 libqt5bluetooth5-bin qtconnectivity5-dev
sudo apt-get install -y -q pulseaudio librtaudio-dev librtaudio5a

# Custom packages for script
sudo apt-get -y -q install pv unzip kpartx zerofree qemu-user-static binfmt-support

# Cleanup
sudo apt-get clean

# Firmware update
updatecheck=`sudo JUST_CHECK=1 rpi-update | grep commit`
if [ $updatecheck != "" ]; then
    sudo rpi-update
    echo "############################################################################"
    echo ""
    echo "Firmware was updated - please reboot now!"
    echo "You can run next step after reboot."
    echo ""
    echo "############################################################################"
else
    echo "############################################################################"
    echo ""
    echo "System ready - you can run next step now."
    echo ""
    echo "############################################################################"
fi
