#!/bin/bash -e

# some magic to get X11 openauto to work
echo "allowed_users=anybody" > /etc/X11/Xwrapper.config
echo "xset -dpms" >> /home/pi/.xinitrc
echo "xset s off" >> /home/pi/.xinitrc
echo "xset s noblank" >> /home/pi/.xinitrc
echo "exec autoapp --platform xcb" >> /home/pi/.xinitrc
usermod -aG tty pi
chown pi:pi /home/pi/.xinitrc
