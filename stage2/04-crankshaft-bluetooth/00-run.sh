#!/bin/bash -e

# /etc
install -m 644 files/etc/systemd/system/btautopair.service              "${ROOTFS_DIR}/etc/systemd/system/"
install -m 644 files/etc/systemd/system/btautoconnect.service           "${ROOTFS_DIR}/etc/systemd/system/"
install -m 644 files/etc/systemd/system/btdevicedetect.service          "${ROOTFS_DIR}/etc/systemd/system/"
install -m 644 files/etc/systemd/system/btrestore.service               "${ROOTFS_DIR}/etc/systemd/system/"
install -m 644 files/etc/systemd/system/csng-bluetooth.service          "${ROOTFS_DIR}/etc/systemd/system/"
install -m 644 files/etc/dbus-1/system.d/bluetooth2.conf                "${ROOTFS_DIR}/etc/dbus-1/system.d/"
install -m 644 files/etc/dbus-1/system.d/dundee2.conf                   "${ROOTFS_DIR}/etc/dbus-1/system.d/"
install -m 644 files/etc/dbus-1/system.d/ofono2.conf                    "${ROOTFS_DIR}/etc/dbus-1/system.d/"

# /opt
install -d "${ROOTFS_DIR}/opt/crankshaft"
install -m 755 files/opt/crankshaft/service_bluetooth.sh                "${ROOTFS_DIR}/opt/crankshaft/"
install -m 755 files/opt/crankshaft/service_btautoconnect.sh            "${ROOTFS_DIR}/opt/crankshaft/"
install -m 755 files/opt/crankshaft/service_btautopair.py               "${ROOTFS_DIR}/opt/crankshaft/"
install -m 755 files/opt/crankshaft/service_btdevicedetect.sh           "${ROOTFS_DIR}/opt/crankshaft/"
install -m 755 files/opt/crankshaft/service_btrestore.sh                "${ROOTFS_DIR}/opt/crankshaft/"
install -m 644 files/opt/crankshaft/start_order                         "${ROOTFS_DIR}/opt/crankshaft/"

# /usr
install -d "${ROOTFS_DIR}/opt/crankshaft"
install -m 755 files/usr/local/bin/dial-number                          "${ROOTFS_DIR}/usr/local/bin/"
install -m 755 files/usr/local/bin/hangup-call                          "${ROOTFS_DIR}/usr/local/bin/"
