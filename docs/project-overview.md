# crankshaft - Project Overview

Date: 2026-07-21
Type: monorepo
Architecture: multi-part (backend + desktop UI + CLI tooling + infra image pipeline + protocol library)

## Executive Summary

Crankshaft is a Raspberry Pi focused Android Auto platform. This repository is a monorepo that combines:

- a backend runtime for Android Auto session control and media routing,
- a slim Qt/QML desktop UI client,
- an image build pipeline for producing deployable Pi images,
- an operational debug collector,
- and a vendored AASDK protocol implementation.

The backend and UI communicate over a versioned WebSocket contract, with WebRTC as the preferred projection/video transport path and operational fallback paths in the backend.

## Project Classification

- Repository Type: monorepo with submodules/parts
- Project Parts:
  - core: src/crankshaft-core (backend)
  - ui: src/crankshaft-ui-slim (desktop)
  - tools: tools/crankshaft-debug-collector (cli)
  - image: image_builder (infra)
  - aasdk: src/aasdk (library)
- Primary Languages: C++, QML, Python, Shell, YAML
- Architecture Pattern: service-oriented backend + desktop client + build/infra pipeline

## Technology Stack Summary

### core (backend)

- Language: C++20
- Build: CMake >= 3.16 + Bash build orchestrator
- Runtime: Qt6 (Core/Network/WebSockets/DBus/Sql/Multimedia), GStreamer, DBus, libusb, OpenSSL, Protobuf
- Service boundaries: Android Auto, media, bluetooth, websocket, config, diagnostics, profile, preferences

### ui (desktop)

- Language: C++20 + QML
- Build: CMake >= 3.16 + Bash build orchestrator
- Runtime: Qt6 (Qml/Quick/QuickControls2/Multimedia/WebSockets/Sql/DBus), optional GStreamer WebRTC receiver
- Presentation: QML views/components under src/qml

### tools (cli)

- Language: Python >= 3.11
- Build/packaging: uv + hatchling (pyproject)
- Runtime: stdlib-only collector with CLI entrypoint crankshaft-debug-collect

### image (infra)

- Build system: GitHub Actions + pi-gen custom stage60 overlays
- Tooling: Shell scripts, apt repo setup, stage scripts for package install/tweaks/service enablement

### aasdk (library)

- Language: C++17
- Build: CMake + Bash build orchestrator
- Scope: Android Auto protocol stack, transport and channel primitives, packaging and tests

## Key Features

- Android Auto backend lifecycle management and transport handling
- WebSocket pub/sub and command surface for UI/backend coordination
- Optional admin API routes over localhost WebSocket channel
- WebRTC-first projection signaling path with service-level controls
- Persistent settings/session state via SQLite-backed services
- Dedicated support-bundle debug collector CLI
- Reproducible Pi image build pipeline for armhf/arm64

## Architecture Highlights

- Core is client-agnostic and exposes capability/version-gated contracts.
- UI remains thin and delegates behavior through websocket/core client abstractions.
- Build and packaging are strongly script-driven with CI matrix support.
- AASDK is isolated as a dedicated library subtree with its own release/testing concerns.

## Development Overview

### Prerequisites

- Linux (Debian/Ubuntu family for provided install flows)
- CMake >= 3.16
- Qt6 toolchain
- Python 3.11+ (for debug collector)
- Access to package repositories for runtime/build dependencies

### Getting Started

1. Build backend core using src/crankshaft-core/build.sh
2. Build UI using src/crankshaft-ui-slim/build.sh
3. Run CLI tooling from tools/crankshaft-debug-collector
4. Use image_builder scripts/CI for image production

### Key Commands

#### core

- Install deps: ./build.sh --install-deps
- Build/test: ./build.sh --clean

#### ui

- Install deps: ./build.sh --install-deps
- Build/test: ./build.sh --clean

#### tools

- Run collector: uv run crankshaft-debug-collect --output-dir /tmp
- Tests: uv run python -m unittest discover -s tests -p "test_*.py" -v

#### image

- CI path: .github/workflows/build-pi-gen-lite.yml
- Local helpers: image_builder/scripts/build-docker.sh

#### aasdk

- Debug build: ./build.sh debug
- Release package build: ./build.sh release package

## Repository Structure

See source-tree-analysis.md for a full annotated tree and critical directories.

## Documentation Map

- index.md - master index
- source-tree-analysis.md - annotated tree and critical paths
- architecture-core.md, architecture-ui.md, architecture-tools.md, architecture-image.md, architecture-aasdk.md
- development-guide-*.md per part

Generated using BMAD document-project workflow.
