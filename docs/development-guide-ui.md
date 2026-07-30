# Development Guide - ui

## Prerequisites

- Debian/Ubuntu style Linux environment
- CMake, compiler toolchain, Qt6 QML/Quick toolchain
- Optional GStreamer WebRTC plugins for full projection path

## Setup

```bash
cd src/crankshaft-ui-slim
./build.sh --install-deps
```

## Build and Test

```bash
cd src/crankshaft-ui-slim
./build.sh --clean
```

Disable tests:

```bash
BUILD_TESTS=OFF ./build.sh --clean
```

Quality checks:

```bash
CODE_QUALITY=ON FORMAT_CHECK=ON BUILD_TESTS=OFF ./build.sh --clean
```

Coverage:

```bash
ENABLE_COVERAGE=ON BUILD_TESTS=ON ./build.sh --clean
```

## Packaging and SBOM

```bash
BUILD_PACKAGE=ON ./build.sh --clean
BUILD_PACKAGE=ON BUILD_SBOM=ON ./build.sh --clean
```
