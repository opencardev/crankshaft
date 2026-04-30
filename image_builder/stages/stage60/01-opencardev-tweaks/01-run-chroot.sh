#!/bin/bash -e

# Add OpenCarDev tweaks
echo "Adding OpenCarDev tweaks..."

# This runs in chroot context so we can use normal file paths
systemctl daemon-reload && systemctl start systemd-zram-setup@zram0.service

# Apply sysctl tweaks
sysctl --system

echo "OpenCarDev tweaks setup completed successfully"
