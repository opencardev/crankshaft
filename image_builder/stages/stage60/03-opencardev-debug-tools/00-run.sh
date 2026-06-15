#!/bin/bash -e

echo "Stage60/03: Installing OpenCarDev debug tools"

install -d -m 755 "${ROOTFS_DIR}/usr/local/bin"
install -d -m 755 "${ROOTFS_DIR}/usr/share/crankshaft"

# Install the modular collector project from repo root into the image so
# the wrapper in /usr/local/bin can import collector modules directly.
cp -a ../../../tools/crankshaft-debug-collector "${ROOTFS_DIR}/usr/share/crankshaft/debug-collector"

install -m 755 \
	../../../tools/crankshaft-debug-collector/scripts/crankshaft-debug-collect \
	"${ROOTFS_DIR}/usr/local/bin/crankshaft-debug-collect"

echo "Stage60/03: OpenCarDev debug tools installed"
