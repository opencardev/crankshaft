#!/bin/bash

# CREDIT TO THESE TUTORIALS:
# Ladyada's readonly fs script
# petr.io/en/blog/2015/11/09/read-only-raspberry-pi-with-jessie
# hallard.me/raspberry-pi-read-only
# k3a.me/how-to-make-raspberrypi-truly-read-only-reliable-and-trouble-free

if [ $(id -u) -ne 0 ]; then
        echo "###########################################################################"
	echo "Installer must be run as root."
	echo "Try 'sudo bash $0'"
        echo "###########################################################################"
	exit 1
fi

if [ -f /etc/fs_read_only_config ]; then
    echo "---------------------------------------------------------------------------"
    echo "Preparing os for read only mode was done before. Nothing to do."
    echo "---------------------------------------------------------------------------"
    exit 0
fi


# FEATURE PROMPTS ----------------------------------------------------------
# Installation doesn't begin until after all user input is taken.

INSTALL_HALT=0
SYS_TYPES=(Pi\ 3\ /\ Pi\ Zero\ W All\ other\ models)
WATCHDOG_MODULES=(bcm2835_wdt bcm2835_wdog bcm2708_wdt bcm2708_wdog)
OPTION_NAMES=(NO YES)

INSTALL_WATCHDOG=1
WD_TARGET=1

# START INSTALL ------------------------------------------------------------
# All selections have been validated at this point...


# Given a filename, a regex pattern to match and a replacement string:
# Replace string if found, else no change.
# (# $1 = filename, $2 = pattern to match, $3 = replacement)
replace() {
	grep $2 $1 >/dev/null
	if [ $? -eq 0 ]; then
		# Pattern found; replace in file
		sed -i "s/$2/$3/g" $1 >/dev/null
	fi
}

# Given a filename, a regex pattern to match and a replacement string:
# If found, perform replacement, else append file w/replacement on new line.
replaceAppend() {
	grep $2 $1 >/dev/null
	if [ $? -eq 0 ]; then
		# Pattern found; replace in file
		sed -i "s/$2/$3/g" $1 >/dev/null
	else
		# Not found; append on new line (silently)
		echo $3 | sudo tee -a $1 >/dev/null
	fi
}

# Given a filename, a regex pattern to match and a string:
# If found, no change, else append file with string on new line.
append1() {
	grep $2 $1 >/dev/null
	if [ $? -ne 0 ]; then
		# Not found; append on new line (silently)
		echo $3 | sudo tee -a $1 >/dev/null
	fi
}

# Given a filename, a regex pattern to match and a string:
# If found, no change, else append space + string to last line --
# this is used for the single-line /boot/cmdline.txt file.
append2() {
	grep $2 $1 >/dev/null
	if [ $? -ne 0 ]; then
		# Not found; insert in file before EOF
		sed -i "s/\'/ $3/g" $1 >/dev/null
	fi
}

mark_script_run() {
    touch /etc/fs_read_only_config
}

echo "---------------------------------------------------------------------------"
echo "Starting installation..."
echo "---------------------------------------------------------------------------"

# disable failed units due to readonly fs
systemctl disable systemd-rfkill.service

echo "---------------------------------------------------------------------------"
echo "Removing unwanted packages..."
echo "---------------------------------------------------------------------------"
#apt-get remove -y --force-yes --purge triggerhappy cron logrotate dbus \
# dphys-swapfile xserver-common lightdm fake-hwclock
# Let's keep dbus...that includes avahi-daemon, a la 'raspberrypi.local',
# also keeping xserver & lightdm for GUI login (WIP, not working yet)
apt-get remove -y --force-yes --purge \
 dphys-swapfile fake-hwclock
apt-get -y --force-yes autoremove --purge

echo "---------------------------------------------------------------------------"
echo "Configuring system..."
echo "---------------------------------------------------------------------------"

sed -i "s/#Storage=auto/Storage=volatile/" /etc/systemd/journald.conf

# Install watchdog if requested
if [ $INSTALL_WATCHDOG -ne 0 ]; then
	apt-get install -y --force-yes watchdog
	# $MODULE is specific watchdog module name
	MODULE=${WATCHDOG_MODULES[($WD_TARGET-1)]}
	# Add to /etc/modules, update watchdog config file
	append1 /etc/modules $MODULE $MODULE
	replace /etc/watchdog.conf "#watchdog-device" "watchdog-device"
	replace /etc/watchdog.conf "#max-load-1" "max-load-1"
	# Start watchdog at system start and start right away
	# Raspbian Stretch needs this package installed first
	apt-get install -y --force-yes insserv
	insserv watchdog
	# Additional settings needed on Jessie
	append1 /lib/systemd/system/watchdog.service "WantedBy" "WantedBy=multi-user.target"
	systemctl enable watchdog
	# Set up automatic reboot in sysctl.conf
	replaceAppend /etc/sysctl.conf "^.*kernel.panic.*$" "kernel.panic = 10"
fi

# Add fastboot, noswap and/or ro to end of /boot/cmdline.txt
append2 /boot/cmdline.txt fastboot fastboot
append2 /boot/cmdline.txt noswap noswap
append2 /boot/cmdline.txt ro^o^t ro

# Move /var/spool to /tmp
rm -rf /var/spool
ln -s /tmp /var/spool

# Voodoo stuff to get the home folder working
touch /tmp/openauto.ini
ln -s /tmp/openauto.ini /home/pi/openauto.ini
chown pi:pi /home/pi/openauto.ini
mkdir -p /tmp/.config
mkdir -p /tmp/.local
ln -s /tmp/.config /home/pi/
ln -s /tmp/.local /home/pi/

apt clean
rm -rf /var/cache/apt/

# Change spool permissions in var.conf (rondie/Margaret fix)
replace /usr/lib/tmpfiles.d/var.conf "spool\s*0755" "spool 1777"

# Move dhcpd.resolv.conf to tmpfs
touch /tmp/dhcpcd.resolv.conf
echo "nameserver 8.8.8.8" > /tmp/dhcpcd.resolv.conf
echo "nameserver 8.8.4.4" >> /tmp/dhcpcd.resolv.conf
rm /etc/resolv.conf
ln -s /tmp/dhcpcd.resolv.conf /etc/resolv.conf

# Make edits to fstab
# make / ro
# tmpfs /var/log tmpfs nodev,nosuid 0 0
# tmpfs /var/tmp tmpfs nodev,nosuid 0 0
# tmpfs /tmp     tmpfs nodev,nosuid 0 0
replace /etc/fstab "vfat\s*defaults\s" "vfat    defaults,ro "
replace /etc/fstab "ext4\s*defaults,noatime\s" "ext4    defaults,noatime,ro "
append1 /etc/fstab "/var/log" "tmpfs /var/log tmpfs nodev,nosuid 0 0"
append1 /etc/fstab "/var/tmp" "tmpfs /var/tmp tmpfs nodev,nosuid 0 0"
append1 /etc/fstab "\s/tmp"   "tmpfs /tmp    tmpfs nodev,nosuid 0 0"

mark_script_run

sync
exit 0
