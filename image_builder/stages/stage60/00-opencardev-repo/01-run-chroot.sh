#!/bin/bash -e

# Add OpenCarDev repository to sources list
# This runs in chroot context so we can use dpkg and lsb_release

echo "Configuring OpenCarDev repository sources..."

# Get architecture and release codename
ARCH=$(dpkg --print-architecture)
REPO_URL=${CRANKSHAFT_APT_REPO:-https://apt.opencardev.org}
REPO_SUITE=${CRANKSHAFT_APT_SUITE:-$(lsb_release -cs)}
REPO_COMPONENT=${CRANKSHAFT_APT_COMPONENT:-stable}

# Create the repository configuration
cat > /etc/apt/sources.list.d/opencardev.list << EOF
deb [arch=${ARCH} signed-by=/usr/share/keyrings/opencardev-archive-keyring.gpg] ${REPO_URL} ${REPO_SUITE} ${REPO_COMPONENT}
EOF

echo "OpenCarDev repository configured: $(cat /etc/apt/sources.list.d/opencardev.list)"
# Update package lists
echo "Updating package lists..."
apt-get update

echo "OpenCarDev repository setup completed successfully"
