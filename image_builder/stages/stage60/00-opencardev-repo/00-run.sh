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

# Write build-time config values to a temp env file so the chroot script can read them.
# Pi-gen does not propagate host env vars into the chroot automatically.
install -m 755 -d "${ROOTFS_DIR}/tmp"
cat > "${ROOTFS_DIR}/tmp/crankshaft-build-env.sh" <<EOF
CRANKSHAFT_APT_REPO="${CRANKSHAFT_APT_REPO:-https://apt.opencardev.org}"
CRANKSHAFT_APT_SUITE="${CRANKSHAFT_APT_SUITE:-trixie}"
CRANKSHAFT_ENABLE_NIGHTLY="${CRANKSHAFT_ENABLE_NIGHTLY:-false}"
EOF
chmod 600 "${ROOTFS_DIR}/tmp/crankshaft-build-env.sh"
echo "Build env written to rootfs"
