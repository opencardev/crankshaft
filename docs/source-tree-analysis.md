# crankshaft - Source Tree Analysis

Date: 2026-07-21

## Overview

The repository is organized as a monorepo with five primary parts and supporting BMAD workflow assets.

## Multi-Part Structure

- core (src/crankshaft-core): backend runtime and service orchestration
- ui (src/crankshaft-ui-slim): Qt/QML client
- tools (tools/crankshaft-debug-collector): support bundle CLI
- image (image_builder): pi-gen image build customizations
- aasdk (src/aasdk): Android Auto protocol library

## Annotated Directory Structure

```text
crankshaft/
├── src/
│   ├── crankshaft-core/                # Backend runtime and service host
│   │   ├── src/
│   │   │   ├── services/               # websocket, android_auto, media, config, diagnostics
│   │   │   ├── hal/                    # transport, multimedia, wireless, functional abstractions
│   │   │   ├── tests/                  # unit tests for service/runtime behavior
│   │   │   ├── benchmarks/             # perf/regression benchmarks
│   │   │   └── packaging/core/         # systemd unit + package lifecycle scripts
│   │   ├── build.sh                    # canonical build/install-deps/test/package command
│   │   ├── CMakeLists.txt
│   │   └── docs/
│   ├── crankshaft-ui-slim/             # Desktop client (Qt/QML)
│   │   ├── src/
│   │   │   ├── qml/                    # view layer and reusable UI components
│   │   │   ├── tests/                  # unit/behavior tests for UI C++ layer
│   │   │   ├── packaging/ui-slim/      # systemd service + package hooks
│   │   │   └── *.cpp/*.h               # core client, session, settings, controls
│   │   ├── build.sh
│   │   └── docs/
│   └── aasdk/                          # Protocol library subtree
│       ├── src/                        # protocol/channel implementation
│       ├── protobuf/                   # generated proto support
│       ├── unit_test/                  # unit/integration test coverage
│       ├── build.sh
│       └── docs/
├── tools/
│   └── crankshaft-debug-collector/
│       ├── src/crankshaft_debug_collector/
│       ├── tests/
│       ├── scripts/
│       └── pyproject.toml
├── image_builder/
│   ├── scripts/                        # image build/validation helpers
│   ├── pi-gen-stages/config-template
│   └── stages/stage60/                 # custom stage scripts/packages/service enablement
├── docs/
│   └── ADR/                            # architecture decision records
└── .github/workflows/                  # CI/build/release automation
```

## Critical Directories

### src/crankshaft-core/src/services

Purpose: backend business logic and transport/event contracts.
Contains: websocket server, android auto orchestration, config/diagnostics/media services.
Entry points: main.cpp -> runCoreApplication -> service manager graph.

### src/crankshaft-ui-slim/src/qml

Purpose: user-facing projection/settings/connection UX.
Contains: projection view, connection status, settings tabs, reusable controls.
Entry points: main.qml and ApplicationController.

### tools/crankshaft-debug-collector/src/crankshaft_debug_collector

Purpose: support bundle capture orchestration.
Contains: command runner, filesystem copy helpers, analysis writer, CLI wrapper.
Entry points: cli.py main() mapped to crankshaft-debug-collect script.

### image_builder/stages/stage60

Purpose: final image customization stage.
Contains: apt repo setup, package install, tuning, debug tools, service enablement scripts.
Integration: consumed by pi-gen workflow in GitHub Actions.

### src/aasdk

Purpose: protocol-level implementation and packaging.
Contains: CMake modules, protocol source, protobuf, tests, docs.
Entry points: library build via build.sh/CMake; consumed by core packages.

## Integration Points

- ui -> core: WebSocket contract (pub/sub, service commands, admin API localhost paths)
- core -> aasdk: packaged library/runtime integration for Android Auto transport stack
- image -> all runtime artifacts: stage60 pipeline installs/tunes packaged components
- tools -> deployed system: captures logs/config/services from runtime targets

## Entry Points

- core: src/crankshaft-core/src/main.cpp
- ui: src/crankshaft-ui-slim/src/main.cpp
- tools: tools/crankshaft-debug-collector/src/crankshaft_debug_collector/cli.py
- image: image_builder/scripts/build-docker.sh and .github/workflows/build-pi-gen-lite.yml
- aasdk: src/aasdk/build.sh and src/aasdk/CMakeLists.txt

## Configuration and CI

- Repo CI orchestration: .github/workflows/ci.yml
- Pi image pipeline: .github/workflows/build-pi-gen-lite.yml
- Per-part package/dependency manifests live in each part's deps/ and packaging/ paths.
