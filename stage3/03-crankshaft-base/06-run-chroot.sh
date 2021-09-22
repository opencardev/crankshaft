#!/bin/bash -e

apt-get purge wiringpi -y
hash -r
wget https://project-downloads.drogon.net/wiringpi-latest.deb
dpkg -i wiringpi-latest.deb
