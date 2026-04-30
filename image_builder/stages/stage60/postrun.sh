#!/bin/bash
#
# Project: Crankshaft
# This file is part of Crankshaft project.
# Copyright (C) 2025 OpenCarDev Team
#
#  Crankshaft is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  Crankshaft is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with Crankshaft. If not, see <http://www.gnu.org/licenses/>.

# Post-run script for stage60 (Crankshaft configuration)
# Performs final image configuration and generates metadata

set -e

echo "Stage 60: Post-run Crankshaft configuration"

# Set root filesystem path
if [ -z "$ROOTFS_DIR" ]; then
    ROOTFS_DIR="${STAGE_WORK_DIR}/rootfs"
fi

# Create OpenCarDev metadata directory
METADATA_DIR="${ROOTFS_DIR}/etc/opencardev"
mkdir -p "${METADATA_DIR}"

# Generate version information
cat > "${METADATA_DIR}/version.txt" << EOF
Crankshaft Infotainment System
Build Date: $(date -u +%Y-%m-%d)
Pi-Gen Branch: ${PI_GEN_BRANCH:-unknown}
Architecture: ${ARCHITECTURE:-unknown}
Debian Release: ${DEBIAN_RELEASE:-unknown}
EOF

# Generate SBOM metadata (simplified)
cat > "${METADATA_DIR}/manifest.json" << 'EOF'
{
  "name": "Crankshaft Pi Image",
  "version": "1.0",
  "components": [
    {
      "name": "Crankshaft",
      "type": "application",
      "repository": "https://github.com/opencardev/crankshaft"
    {
      "name": "Raspberry Pi OS Lite",
      "type": "os",
      "repository": "https://github.com/RPi-Distro/pi-gen"
    }
  ]
}
EOF

echo "Metadata generated"

# ====================================================================
# FINAL CLEANUP
# ====================================================================
echo "Running final cleanup..."

# Ensure SSH is enabled
run_root systemctl is-enabled ssh || run_root systemctl enable ssh

# Verify user account
run_root grep "^pi:" /etc/passwd || echo "Warning: pi user not found"

# Clean package manager cache
run_root apt-get clean || true
run_root rm -rf /var/lib/apt/lists/* || true

echo "Stage 60 post-run configuration complete"
