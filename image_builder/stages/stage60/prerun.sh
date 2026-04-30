#!/bin/bash -e

if [ ! -d "${ROOTFS_DIR}" ]; then
	copy_previous
fi

# Configure apt for better mirror reliability and retry behavior
echo "Configuring apt for better mirror reliability..."
cat > "${ROOTFS_DIR}/etc/apt/apt.conf.d/99build-reliability" << 'EOF'
# Build reliability configuration for better mirror handling
Acquire::Retries "5";
Acquire::http::Timeout "30";
Acquire::https::Timeout "30";
Acquire::ftp::Timeout "30";
APT::Get::fix-missing "true";
APT::Install-Recommends "false";
APT::Install-Suggests "false";
EOF

echo "APT configuration added for build reliability"
