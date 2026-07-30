# Development Guide - core

## Prerequisites

- Debian/Ubuntu style Linux environment
- CMake, compiler toolchain, Qt6 dev packages
- GStreamer, DBus, libusb, OpenSSL, protobuf packages

## Setup

```bash
cd src/crankshaft-core
./build.sh --install-deps
```

## Build and Test

```bash
cd src/crankshaft-core
./build.sh --clean
```

Quality and format checks:

```bash
CODE_QUALITY=ON FORMAT_CHECK=ON BUILD_TESTS=ON ./build.sh --clean
```

Coverage:

```bash
ENABLE_COVERAGE=ON BUILD_TESTS=ON ./build.sh --clean
```

## Packaging

```bash
BUILD_PACKAGE=ON ./build.sh --clean
```

SBOM:

```bash
BUILD_PACKAGE=ON BUILD_SBOM=ON ./build.sh --clean
```

## Notes

- AASDK must be available via pkg-config unless WITH_AASDK=0.
- Build script manages distro-specific package manifests and optional quality/coverage/SBOM extras.
