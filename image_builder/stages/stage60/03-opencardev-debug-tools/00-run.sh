#!/bin/bash -e

echo "Stage60/03: Installing OpenCarDev debug tools"

install -d -m 755 "${ROOTFS_DIR}/usr/local/bin"
install -m 755 files/usr/local/bin/crankshaft-debug-collect "${ROOTFS_DIR}/usr/local/bin/crankshaft-debug-collect"

echo "Stage60/03: OpenCarDev debug tools installed"
