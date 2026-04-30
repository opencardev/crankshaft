#!/bin/bash -e

# Add OpenCarDev repository GPG key and repository configuration
echo "Adding OpenCarDev repository..."

# Create directory for GPG keys if it doesn't exist
install -m 755 -d "${ROOTFS_DIR}/usr/share/keyrings"

# Download and add the GPG key
curl -fsSL https://apt.opencardev.org/opencardev.gpg.key | \
    gpg --dearmor > "${ROOTFS_DIR}/usr/share/keyrings/opencardev-archive-keyring.gpg"

# Set proper permissions on the keyring
chmod 644 "${ROOTFS_DIR}/usr/share/keyrings/opencardev-archive-keyring.gpg"

echo "OpenCarDev GPG key added successfully"
