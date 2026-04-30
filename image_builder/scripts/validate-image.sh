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

#!/usr/bin/env bash

set -e

# ====================================================================
# validate-image.sh
# 
# Validates a Crankshaft Raspberry Pi image after build
# 
# Usage: ./validate-image.sh <image-file>
# 
# Performs validation for:
# - T008a: Default user account configuration
# - T009a: Filesystem resize capability
# - T010: SSH server configuration
# - T011a: Build reproducibility metadata
# ====================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly IMAGE_FILE="${1:-}"

# Exit codes
readonly E_NO_IMAGE=1
readonly E_MOUNT_FAILED=2
readonly E_VALIDATION_FAILED=3

# Color output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Validation results
declare -i TESTS_PASSED=0
declare -i TESTS_FAILED=0
declare -a FAILED_TESTS=()

# ====================================================================
# Helper Functions
# ====================================================================

log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

test_passed() {
    local test_name="$1"
    log_info "✓ ${test_name}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

test_failed() {
    local test_name="$1"
    local reason="$2"
    log_error "✗ ${test_name}: ${reason}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_TESTS+=("${test_name}: ${reason}")
}

# ====================================================================
# Mount Image Partitions
# ====================================================================

mount_image() {
    local image="$1"
    local mount_point="$2"
    
    log_info "Mounting image ${image}..."
    
    # Create mount point
    mkdir -p "${mount_point}"
    
    # Detect loop device
    local loop_device
    loop_device=$(sudo losetup --find --show --partscan "${image}")
    
    if [ -z "${loop_device}" ]; then
        log_error "Failed to create loop device"
        return ${E_MOUNT_FAILED}
    fi
    
    log_info "Loop device: ${loop_device}"
    
    # Wait for partitions to appear
    sleep 2
    
    # Mount rootfs (usually partition 2)
    if [ -e "${loop_device}p2" ]; then
        sudo mount "${loop_device}p2" "${mount_point}"
        log_info "Mounted rootfs at ${mount_point}"
    else
        log_error "Rootfs partition not found"
        sudo losetup -d "${loop_device}"
        return ${E_MOUNT_FAILED}
    fi
    
    # Mount boot partition (usually partition 1)
    if [ -e "${loop_device}p1" ]; then
        sudo mount "${loop_device}p1" "${mount_point}/boot"
        log_info "Mounted boot at ${mount_point}/boot"
    else
        log_warn "Boot partition not found"
    fi
    
    echo "${loop_device}"
}

unmount_image() {
    local mount_point="$1"
    local loop_device="$2"
    
    log_info "Unmounting image..."
    
    # Unmount filesystems
    sudo umount "${mount_point}/boot" 2>/dev/null || true
    sudo umount "${mount_point}" 2>/dev/null || true
    
    # Detach loop device
    if [ -n "${loop_device}" ]; then
        sudo losetup -d "${loop_device}" 2>/dev/null || true
    fi
    
    # Clean up mount point
    rmdir "${mount_point}" 2>/dev/null || true
}

# ====================================================================
# Validation Tests
# ====================================================================

# T008a: Validate default user account
validate_user_account() {
    local rootfs="$1"
    
    log_info "=== T008a: Validating default user account ==="
    
    # Check if pi user exists in passwd
    if ! grep -q '^pi:' "${rootfs}/etc/passwd"; then
        test_failed "User Account" "User 'pi' not found in /etc/passwd"
        return
    fi
    
    # Check if pi user is in sudo group
    if ! grep -q '^sudo:.*pi' "${rootfs}/etc/group"; then
        test_failed "User Account" "User 'pi' not in sudo group"
        return
    fi
    
    # Check home directory
    if [ ! -d "${rootfs}/home/pi" ]; then
        test_failed "User Account" "/home/pi directory not found"
        return
    fi
    
    test_passed "Default user account (pi) configured correctly"
}

# T009a: Validate filesystem resize capability
validate_resize_capability() {
    local rootfs="$1"
    
    log_info "=== T009a: Validating filesystem resize capability ==="
    
    # Check if resize script exists
    if [ ! -f "${rootfs}/usr/local/bin/resize-rootfs.sh" ]; then
        test_failed "Resize Capability" "resize-rootfs.sh not found in /usr/local/bin/"
        return
    fi
    
    # Check if script is executable
    if [ ! -x "${rootfs}/usr/local/bin/resize-rootfs.sh" ]; then
        test_failed "Resize Capability" "resize-rootfs.sh is not executable"
        return
    fi
    
    # Check if systemd service exists
    if [ ! -f "${rootfs}/etc/systemd/system/resize-rootfs.service" ]; then
        test_failed "Resize Capability" "resize-rootfs.service not found"
        return
    fi
    
    # Check if service is enabled (symlink should exist)
    if [ ! -L "${rootfs}/etc/systemd/system/basic.target.wants/resize-rootfs.service" ]; then
        test_failed "Resize Capability" "resize-rootfs.service not enabled"
        return
    fi
    
    test_passed "Filesystem resize capability configured correctly"
}

# T010: Validate SSH server configuration
validate_ssh_config() {
    local rootfs="$1"
    
    log_info "=== T010: Validating SSH server configuration ==="
    
    # Check if SSH service is enabled
    local ssh_enabled=false
    
    if [ -L "${rootfs}/etc/systemd/system/multi-user.target.wants/ssh.service" ] || \
       [ -L "${rootfs}/etc/systemd/system/sshd.service.wants/sshd.service" ]; then
        ssh_enabled=true
    fi
    
    if [ "${ssh_enabled}" = false ]; then
        test_failed "SSH Configuration" "SSH service not enabled"
        return
    fi
    
    # Check if SSH config file exists
    if [ ! -f "${rootfs}/etc/ssh/sshd_config" ]; then
        test_failed "SSH Configuration" "/etc/ssh/sshd_config not found"
        return
    fi
    
    test_passed "SSH server configured and enabled"
    log_warn "Security reminder: Default credentials (pi/raspberry) are enabled for MVP testing"
}

# T011a: Validate build reproducibility metadata
validate_build_metadata() {
    local rootfs="$1"
    
    log_info "=== T011a: Validating build reproducibility metadata ==="
    
    # Check for metadata files in /usr/share/crankshaft/
    local metadata_dir="${rootfs}/usr/share/crankshaft"
    
    if [ ! -d "${metadata_dir}" ]; then
        test_failed "Build Metadata" "/usr/share/crankshaft/ directory not found"
        return
    fi
    
    # Check for build-metadata.json
    if [ ! -f "${metadata_dir}/build-metadata.json" ]; then
        test_failed "Build Metadata" "build-metadata.json not found"
        return
    fi
    
    # Validate JSON structure
    if ! command -v jq &>/dev/null; then
        log_warn "jq not installed, skipping JSON validation"
    else
        if ! jq empty "${metadata_dir}/build-metadata.json" 2>/dev/null; then
            test_failed "Build Metadata" "build-metadata.json is not valid JSON"
            return
        fi
        
        # Check for required fields
        local required_fields=("git_commit" "git_branch" "build_timestamp")
        for field in "${required_fields[@]}"; do
            if ! jq -e ".${field}" "${metadata_dir}/build-metadata.json" &>/dev/null; then
                test_failed "Build Metadata" "Missing required field: ${field}"
                return
            fi
        done
    fi
    
    test_passed "Build metadata present and valid"
}

# Validate Crankshaft service configuration
validate_crankshaft_service() {
    local rootfs="$1"
    
    log_info "=== Validating Crankshaft systemd service ==="
    
    # Check if service file exists
    if [ ! -f "${rootfs}/etc/systemd/system/crankshaft.service" ]; then
        test_failed "Crankshaft Service" "crankshaft.service not found"
        return
    fi
    
    # Check if service is enabled
    if [ ! -L "${rootfs}/etc/systemd/system/graphical.target.wants/crankshaft.service" ] && \
       [ ! -L "${rootfs}/etc/systemd/system/multi-user.target.wants/crankshaft.service" ]; then
        test_failed "Crankshaft Service" "crankshaft.service not enabled"
        return
    fi
    
    test_passed "Crankshaft systemd service configured and enabled"
}

# Validate boot configuration
validate_boot_config() {
    local rootfs="$1"
    
    log_info "=== Validating boot configuration ==="
    
    # Check if boot config.txt exists
    if [ ! -f "${rootfs}/boot/config.txt" ]; then
        test_failed "Boot Configuration" "/boot/config.txt not found"
        return
    fi
    
    # Check for critical HDMI settings
    if ! grep -q 'hdmi_force_hotplug' "${rootfs}/boot/config.txt"; then
        test_failed "Boot Configuration" "HDMI configuration missing from config.txt"
        return
    fi
    
    test_passed "Boot configuration present with HDMI settings"
}

# ====================================================================
# Main Execution
# ====================================================================

main() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║         Crankshaft Image Validation Script                  ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Check if image file provided
    if [ -z "${IMAGE_FILE}" ]; then
        log_error "Usage: $0 <image-file>"
        exit ${E_NO_IMAGE}
    fi
    
    # Check if image exists
    if [ ! -f "${IMAGE_FILE}" ]; then
        log_error "Image file not found: ${IMAGE_FILE}"
        exit ${E_NO_IMAGE}
    fi
    
    log_info "Image: ${IMAGE_FILE}"
    log_info "Size: $(du -h "${IMAGE_FILE}" | cut -f1)"
    echo ""
    
    # Create temporary mount point
    local mount_point
    mount_point=$(mktemp -d -t crankshaft-validate-XXXXXX)
    
    # Mount image
    local loop_device
    if ! loop_device=$(mount_image "${IMAGE_FILE}" "${mount_point}"); then
        log_error "Failed to mount image"
        exit ${E_MOUNT_FAILED}
    fi
    
    # Run all validation tests
    validate_user_account "${mount_point}"
    validate_resize_capability "${mount_point}"
    validate_ssh_config "${mount_point}"
    validate_build_metadata "${mount_point}"
    validate_crankshaft_service "${mount_point}"
    validate_boot_config "${mount_point}"
    
    # Unmount image
    unmount_image "${mount_point}" "${loop_device}"
    
    # Report results
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                   Validation Results                         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Tests Passed: ${TESTS_PASSED}"
    echo "Tests Failed: ${TESTS_FAILED}"
    echo ""
    
    if [ ${TESTS_FAILED} -gt 0 ]; then
        log_error "Validation failed with ${TESTS_FAILED} errors:"
        for failure in "${FAILED_TESTS[@]}"; do
            echo "  - ${failure}"
        done
        exit ${E_VALIDATION_FAILED}
    else
        log_info "All validation tests passed! ✓"
        echo ""
        log_info "Image is ready for deployment"
    fi
}

# Run main function
main "$@"
