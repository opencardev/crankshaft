#!/bin/bash -e

# Add OpenCarDev repository to sources list
# This runs in chroot context so we can use dpkg and lsb_release

echo "Configuring OpenCarDev repository sources..."

# Source build-time env written by the host-side 00-run.sh.
# Pi-gen does not propagate host env vars into the chroot automatically.
if [ -f /tmp/crankshaft-build-env.sh ]; then
    # shellcheck source=/dev/null
    . /tmp/crankshaft-build-env.sh
    rm -f /tmp/crankshaft-build-env.sh
fi

# Get architecture and release codename
ARCH=$(dpkg --print-architecture)
REPO_URL=${CRANKSHAFT_APT_REPO:-https://apt.opencardev.org}
REPO_SUITE=${CRANKSHAFT_APT_SUITE:-$(lsb_release -cs)}

# Always configure the stable component.
cat > /etc/apt/sources.list.d/opencardev.list <<EOF
deb [arch=${ARCH} signed-by=/usr/share/keyrings/opencardev-archive-keyring.gpg] ${REPO_URL} ${REPO_SUITE} stable
EOF

# Conditionally add the nightly component as a separate line.
if [ "${CRANKSHAFT_ENABLE_NIGHTLY:-false}" = "true" ]; then
    echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/opencardev-archive-keyring.gpg] ${REPO_URL} ${REPO_SUITE} nightly" \
        >> /etc/apt/sources.list.d/opencardev.list
    echo "Nightly component enabled"
fi

echo "OpenCarDev repository configured:"
cat /etc/apt/sources.list.d/opencardev.list

# Update package lists
echo "Updating package lists..."
apt-get update

echo "OpenCarDev repository setup completed successfully"
