#!/bin/bash -e

# some magic to get X11 openauto to work
echo "allowed_users=anybody" > /etc/X11/Xwrapper.config
echo "xset -dpms" >> /home/pi/.xinitrc
echo "xset s off" >> /home/pi/.xinitrc
echo "xset s noblank" >> /home/pi/.xinitrc
echo "exec stdbuf -i0 -o0 -e0 autoapp --platform xcb >> /tmp/openauto.log" >> /home/pi/.xinitrc
usermod -aG tty pi
chown pi:pi /home/pi/.xinitrc
