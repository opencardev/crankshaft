#!/bin/bash

case $1 in
	unlock)
		mount -o remount,rw /
		;;
	lock)
		mount -o remount,ro /
		sync
		;;
	unlock_boot)
		mount -o remount,rw /boot/
		;;
	lock_boot)
		mount -o remount,ro /boot/
		sync
		;;
esac