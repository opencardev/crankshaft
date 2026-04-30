#!/bin/bash
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

# Build Metadata Generation Script
# Captures version, hash, build date, and environment info for the image

set -e

# Script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Output file (can be overridden)
OUTPUT_FILE="${OUTPUT_FILE:-${SCRIPT_DIR}/../build/build-metadata.json}"

echo "Generating build metadata..."
echo "Repository root: ${REPO_ROOT}"
echo "Output file: ${OUTPUT_FILE}"

# Ensure output directory exists
mkdir -p "$(dirname "${OUTPUT_FILE}")"

# Get git information
if [ -d "${REPO_ROOT}/.git" ]; then
    GIT_COMMIT=$(git -C "${REPO_ROOT}" rev-parse HEAD 2>/dev/null || echo "unknown")
    GIT_BRANCH=$(git -C "${REPO_ROOT}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    GIT_TAG=$(git -C "${REPO_ROOT}" describe --tags --exact-match 2>/dev/null || echo "none")
    GIT_DIRTY=$(git -C "${REPO_ROOT}" diff --quiet 2>/dev/null && echo "false" || echo "true")
else
    GIT_COMMIT="unknown"
    GIT_BRANCH="unknown"
    GIT_TAG="none"
    GIT_DIRTY="false"
fi

# Build timestamp
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_TIMESTAMP=$(date -u +%s)

# System information
BUILD_ARCH=$(uname -m)
BUILD_OS=$(uname -s)
BUILD_KERNEL=$(uname -r)

# Pi-gen specific
PI_GEN_BRANCH="${PI_GEN_BRANCH:-master}"
IMG_NAME="${IMG_NAME:-crankshaft}"
RELEASE="${RELEASE:-trixie}"

# Crankshaft version (from git tag or commit)
if [ "${GIT_TAG}" != "none" ]; then
    CRANKSHAFT_VERSION="${GIT_TAG}"
else
    CRANKSHAFT_VERSION="${GIT_BRANCH}-${GIT_COMMIT:0:8}"
fi

# Generate JSON metadata
cat > "${OUTPUT_FILE}" << EOF
{
  "build": {
    "date": "${BUILD_DATE}",
    "timestamp": ${BUILD_TIMESTAMP},
    "arch": "${BUILD_ARCH}",
    "os": "${BUILD_OS}",
    "kernel": "${BUILD_KERNEL}",
    "user": "${USER:-unknown}",
    "host": "${HOSTNAME:-unknown}"
  },
  "git": {
    "commit": "${GIT_COMMIT}",
    "branch": "${GIT_BRANCH}",
    "tag": "${GIT_TAG}",
    "dirty": ${GIT_DIRTY}
  },
  "image": {
    "name": "${IMG_NAME}",
    "version": "${CRANKSHAFT_VERSION}",
    "release": "${RELEASE}",
    "pi_gen_branch": "${PI_GEN_BRANCH}"
  },
  "crankshaft": {
    "version": "${CRANKSHAFT_VERSION}",
    "repository": "https://github.com/opencardev/crankshaft.core",
    "license": "GPL-3.0-or-later"
  }
}
EOF

echo "Build metadata generated successfully"
echo "Content:"
cat "${OUTPUT_FILE}"

# Also create a human-readable version
HUMAN_OUTPUT="${OUTPUT_FILE%.json}.txt"
cat > "${HUMAN_OUTPUT}" << EOF
Crankshaft Build Metadata
==========================

Image: ${IMG_NAME}
Version: ${CRANKSHAFT_VERSION}
Release: ${RELEASE}

Build Date: ${BUILD_DATE}
Build Architecture: ${BUILD_ARCH}
Pi-Gen Branch: ${PI_GEN_BRANCH}

Git Commit: ${GIT_COMMIT}
Git Branch: ${GIT_BRANCH}
Git Tag: ${GIT_TAG}
Git Dirty: ${GIT_DIRTY}

Repository: https://github.com/opencardev/crankshaft.core
License: GPL-3.0-or-later
EOF

echo ""
echo "Human-readable metadata: ${HUMAN_OUTPUT}"

exit 0
