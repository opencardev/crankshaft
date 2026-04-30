#!/bin/bash -e

echo "Stage60/03: Applying Raspberry Pi OS optimization files"

install -d -m 755 "${ROOTFS_DIR}/etc/sysctl.d"
install -d -m 755 "${ROOTFS_DIR}/etc/systemd/journald.conf.d"

install -m 644 files/etc/sysctl.d/60-crankshaft-rpi.conf "${ROOTFS_DIR}/etc/sysctl.d/"
install -m 644 files/etc/systemd/journald.conf.d/60-crankshaft.conf "${ROOTFS_DIR}/etc/systemd/journald.conf.d/"

echo "Stage60/03: Optimization files staged"
