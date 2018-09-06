#!/bin/bash

sudo systemctl stop pulseaudio
sudo /usr/bin/pulseaudio --daemonize=no --system --realtime --disable-shm --disallow-exit -vvvv
sudo systemctl start pulseaudio
