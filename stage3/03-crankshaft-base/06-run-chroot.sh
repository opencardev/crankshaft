#!/bin/bash -e

apt-get purge wiringpi -y
hash -r
dpkg -i /root/wiringpi-latest.deb
