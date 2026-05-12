#!/bin/bash -e

# Enable and start Crankshaft systemd services
# This runs in chroot context so systemd is available

echo "Stage60/05: Enabling Crankshaft services..."

# Enable services for multi-user and graphical targets
systemctl enable crankshaft-core.service
systemctl enable crankshaft-ui-slim-display-setup.service
systemctl enable crankshaft-ui-slim.service

echo "Stage60/05: Services enabled successfully"
echo "  - crankshaft-core.service"
echo "  - crankshaft-ui-slim-display-setup.service"
echo "  - crankshaft-ui-slim.service"
