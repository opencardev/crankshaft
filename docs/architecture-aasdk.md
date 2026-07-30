# Architecture - aasdk (src/aasdk)

## Executive Summary

aasdk is the Android Auto protocol library subtree used by core. It provides transport/channel protocol implementation and packaging/test infrastructure.

## Technology Stack

- C++17
- CMake-based library build
- Protobuf and optional Abseil/protobuf build controls
- OpenSSL/libusb/Boost integration in library build graph

## Architecture Pattern

Protocol library with modular channels/transports and explicit packaging/test support.

## Notable Build/Packaging Traits

- Multi-arch handling through TARGET_ARCH mapping (amd64/armhf/arm64/i386)
- Version override support and git metadata integration
- Deb package architecture detection and package naming logic
- Unit test and benchmark options in build flags

## Integration Role

- Built/installed as dependency for core runtime packaging/build flows
- Provides low-level Android Auto protocol and transport primitives consumed by backend services
