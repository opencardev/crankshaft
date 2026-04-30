#!/bin/bash -e

# Add OpenCarDev tweaks
echo "Adding OpenCarDev tweaks..."

# Copy zram-generator configuration
install -m 644 files/etc/systemd/zram-generator.conf "${ROOTFS_DIR}/etc/systemd/"

# Apply sysctl tweaks
install -m 644 files/etc/sysctl.conf "${ROOTFS_DIR}/etc/"

echo "OpenCarDev tweaks added successfully"
