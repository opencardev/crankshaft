#!/bin/bash -e

on_chroot << EOF
pip install --upgrade pip
pip install smbus
pip install python-tsl2591
EOF
