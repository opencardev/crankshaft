#!/bin/bash -e

# /etc
install -d "${ROOTFS_DIR}/etc/X11/xorg.conf.d"
install -m 644 files/etc/X11/xorg.conf.d/10-monitor.conf                "${ROOTFS_DIR}/etc/X11/xorg.conf.d/10-monitor.conf"
