#!/bin/bash -e

on_chroot << EOF
pip3 install --upgrade pip
pip3 install smbus
pip3 install python-tsl2591
EOF
