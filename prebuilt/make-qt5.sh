#!/bin/bash

DOWNLOAD_URL=https://download.qt.io/official_releases/qt/5.10/5.10.1/single/qt-everywhere-src-5.10.1.tar.xz
OUTPUT_FN=qt-everywhere-src-5.10.1.tar.xz
OUTPUT_DIR=qt-everywhere-src-5.10.1

sudo apt update
sudo apt -y upgrade
sudo apt update
sudo apt -y install build-essential libfontconfig1-dev libdbus-1-dev libfreetype6-dev libicu-dev libsqlite3-dev libssl-dev libjpeg9-dev libglib2.0-dev  bluez libbluetooth-dev   libasound2-dev libgstreamer0.10-dev libgstreamer-plugins-base1.0-dev  libxkbcommon-dev libwayland-dev  libasound2-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev build-essential libfontconfig1-dev libdbus-1-dev libfreetype6-dev libicu-dev libinput-dev libxkbcommon-dev libsqlite3-dev  libglib2.0-dev libraspberrypi-dev libxcb1-dev libfontconfig1-dev libfreetype6-dev libx11-dev libxext-dev libxfixes-dev libxi-dev libxrender-dev libxcb1-dev libx11-xcb-dev libxcb-glx0-dev libts-dev pulseaudio libpulse-dev librtaudio5a librtaudio-dev libraspberrypi-bin libraspberrypi-dev
sudo apt clean 
if ! [ -f ${OUTPUT_FN} ]; then
wget ${DOWNLOAD_URL}
fi
tar -xvf  ${OUTPUT_FN}
mkdir qt5-build
cd qt5-build
../${OUTPUT_DIR}/configure \
-v -opengl es2 -eglfs -no-gtk -device linux-rasp-pi-g++ -device-option CROSS_COMPILE=/usr/bin/ -opensource -confirm-license -optimized-qmake -reduce-exports -release -prefix /usr/local/qt5 -sysroot / -fontconfig -glib -recheck -evdev -ssl -qt-xcb -make libs -nomake examples -no-compile-examples -nomake tests -skip qt3d -skip qtandroidextras -skip qtcanvas3d -skip qtcharts -skip qtdatavis3d -skip qtdoc -skip qtgamepad -skip qtlocation -skip qtmacextras -skip qtpurchasing -skip qtscript -skip qtscxml -skip qtspeech -skip qtsvg -skip qttools -skip qttranslations -skip qtwebchannel -skip qtwebengine -skip qtwebsockets -skip qtwebview -skip qtwinextras -skip qtxmlpatterns -no-feature-textodfwriter -no-feature-dom -no-feature-calendarwidget -no-feature-printpreviewwidget -no-feature-keysequenceedit -no-feature-colordialog -no-feature-printpreviewdialog -no-feature-wizard -no-feature-datawidgetmapper -no-feature-imageformat_ppm -no-feature-imageformat_xbm -no-feature-image_heuristic_mask -no-feature-cups -no-feature-paint_debug -no-feature-translation -no-feature-ftp -no-feature-socks5 -no-feature-bearermanagement -no-feature-fscompleter -no-feature-desktopservices -no-feature-mimetype -no-feature-undocommand -no-feature-undostack -no-feature-undogroup -no-feature-undoview -no-feature-statemachine
make -j4
sudo make install
cd ..
tar -cvf libQt5_OpenGLES2.tar.xz /usr/local/qt5

