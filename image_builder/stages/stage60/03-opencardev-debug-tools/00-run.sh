#!/bin/bash -e

echo "Stage60/03: Staging debug collector project into image"

install -d -m 755 "${ROOTFS_DIR}/usr/share/crankshaft"

# Stage the modular collector project into the image filesystem.
# The chroot step (01-run-chroot.sh) will install uv and then use it to
# install the package so the entry point lands in /usr/local/bin automatically.
cp -a ../../../tools/crankshaft-debug-collector \
    "${ROOTFS_DIR}/usr/share/crankshaft/debug-collector"

echo "Stage60/03: Debug collector project staged at /usr/share/crankshaft/debug-collector"
