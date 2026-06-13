#!/bin/bash -e

# Enable and start Crankshaft systemd services
# This runs in chroot context so systemd is available

echo "Stage60/05: Enabling Crankshaft services..."

# Configure PipeWire defaults for Android Auto audio (48 kHz path).
install -d -m 755 /etc/pipewire/pipewire.conf.d
cat > /etc/pipewire/pipewire.conf.d/10-crankshaft.conf << 'EOF'
context.properties = {
	default.clock.rate = 48000
	default.clock.allowed-rates = [ 48000 ]
}
EOF

# Route Crankshaft system services to the crankshaft user's PipeWire/Pulse sockets.
install -d -m 755 /etc/systemd/system/crankshaft-core.service.d
cat > /etc/systemd/system/crankshaft-core.service.d/20-pipewire-runtime.conf << 'EOF'
[Service]
Environment="XDG_RUNTIME_DIR=/run/user/%U"
Environment="PIPEWIRE_RUNTIME_DIR=/run/user/%U"
Environment="PULSE_SERVER=unix:/run/user/%U/pulse/native"
EOF

install -d -m 755 /etc/systemd/system/crankshaft-ui-slim.service.d
cat > /etc/systemd/system/crankshaft-ui-slim.service.d/20-pipewire-runtime.conf << 'EOF'
[Service]
Environment="XDG_RUNTIME_DIR=/run/user/%U"
Environment="PIPEWIRE_RUNTIME_DIR=/run/user/%U"
Environment="PULSE_SERVER=unix:/run/user/%U/pulse/native"
EOF

# Enable services for multi-user and graphical targets
systemctl enable crankshaft-core.service
systemctl enable crankshaft-ui-slim-display-setup.service
systemctl enable crankshaft-ui-slim.service

# Enable PipeWire user units globally and prefer PipeWire over PulseAudio daemon.
systemctl --global enable pipewire.service pipewire.socket pipewire-pulse.service pipewire-pulse.socket wireplumber.service
systemctl --global mask pulseaudio.service pulseaudio.socket || true

# Keep the crankshaft user manager alive at boot so audio daemons are available
# to system services that run as User=crankshaft.
install -d -m 755 /var/lib/systemd/linger
touch /var/lib/systemd/linger/crankshaft

CRANKSHAFT_UID=$(id -u crankshaft)
systemctl enable "user@${CRANKSHAFT_UID}.service"

echo "Stage60/05: Services enabled successfully"
echo "  - crankshaft-core.service"
echo "  - crankshaft-ui-slim-display-setup.service"
echo "  - crankshaft-ui-slim.service"
echo "  - pipewire.service (user/global)"
echo "  - pipewire-pulse.service (user/global)"
echo "  - wireplumber.service (user/global)"
