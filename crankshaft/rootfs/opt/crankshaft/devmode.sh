#!/bin/bash

# dev mode related utility

source /opt/crankshaft/crankshaft_default_env.sh
source /boot/crankshaft/crankshaft_env.sh

DEV_FILE=/etc/dev_mode_enabled

enable_dev_mode() {
	systemctl disable autoapp.service
	systemctl disable splashscreen.service
	if ! [ -f /etc/crankshaft_ssh_keys_generated ]; then
            systemctl start regenerate_ssh_host_keys.service
            touch /etc/crankshaft_ssh_keys_generated
	fi
	systemctl enable networking.service
	systemctl enable dhcpd.service
	systemctl enable avahi-daemon.service
	systemctl enable ssh
	systemctl enable ntp.service
	systemctl enable wpa_supplicant.service
	/opt/crankshaft/wifi_setup.sh enable
	sed -i 's/console=tty3/console=tty1/' /boot/cmdline.txt
	sed -i 's/ logo.nologo loglevel=0 vt.global_cursor_default=0 splash//' /boot/cmdline.txt
}

disable_dev_mode() {
	systemctl enable autoapp.service
	systemctl enable splashscreen.service
	systemctl disable ssh
	systemctl disable avahi-daemon.service
	systemctl disable dhcpd.service
	systemctl disable networking.service
	systemctl disable ntp.service
	systemctl disable wpa_supplicant.service
	/opt/crankshaft/wifi_setup.sh disable
	sed -i 's/console=tty1/console=tty3/' /boot/cmdline.txt
	sed -i 's/$/ logo.nologo loglevel=0 vt.global_cursor_default=0 splash/' /boot/cmdline.txt
}

get_status() {
	if [ -f ${DEV_FILE} ]; then
		echo "enabled"
	else
		echo "disabled"
	fi
}

gpio_autoset() {
	if [ $DEV_MODE -ne 0 ] || [ `gpio -g read $DEV_PIN` -eq 0 ] ; then
		# the development mode pin is there
		/opt/crankshaft/filesystem.sh unlock
		/opt/crankshaft/filesystem.sh unlock_boot
		# ... but we don't see it being enabled
		if ! [ -f $DEV_FILE ]; then
			/opt/crankshaft/devmode.sh enable
			touch $DEV_FILE
			reboot
		fi
	else
		# the development mode pin is not there
		# ... but there is a dev file
		if [ -f $DEV_FILE ]; then
			/opt/crankshaft/filesystem.sh unlock
			/opt/crankshaft/filesystem.sh unlock_boot
			/opt/crankshaft/devmode.sh disable
			rm -f $DEV_FILE
			reboot
		fi
	fi
}

case $1 in
	status)
		get_status
		;;
	enable)
		enable_dev_mode
		;;
	disable)
		disable_dev_mode
		;;
	autoset)
		gpio_autoset
		;;
esac

exit 0
