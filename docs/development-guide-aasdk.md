# Development Guide - aasdk

## Prerequisites

- C++ toolchain + CMake
- Protobuf/OpenSSL/libusb/Boost dependencies

## Build

```bash
cd src/aasdk
./build.sh debug
./build.sh release
```

## Test and Package

```bash
./build.sh debug test
./build.sh release package
```

## Optional Flags

- --skip-protobuf
- --skip-absl
- --install-deps
- --sbom / --sbom-only
