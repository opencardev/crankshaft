#!/bin/bash -e

install -d "${ROOTFS_DIR}/etc/systemd/system/getty@tty3.service.d"
install -m 644 files/noclear.conf "${ROOTFS_DIR}/etc/systemd/system/getty@tty3.service.d/noclear.conf"
