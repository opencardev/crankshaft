# Architecture - core (src/crankshaft-core)

## Executive Summary

core is the backend runtime responsible for Android Auto lifecycle, transport/media orchestration, system integration, and external client contract serving.

## Technology Stack

- C++20, CMake, Bash build orchestration
- Qt6 Core/Network/WebSockets/DBus/Sql/Multimedia
- GStreamer modules (app/video/audio/webrtc/sdp)
- Protobuf, OpenSSL, libusb, DBus

## Architecture Pattern

Service-oriented backend with explicit service manager + event bus + websocket gateway.

## Component Overview

- CoreApplicationRunner: startup and application lifecycle
- ServiceManager: service composition and control
- WebSocketServer: client contract edge, pub/sub relay, command handling
- AndroidAutoService/RealAndroidAutoService: AA projection protocol orchestration
- AudioRouter/MediaPipeline: media path routing and bridge
- ConfigService/PreferencesService/SessionStore: runtime and persistent state
- DiagnosticsEndpoint/MetricsEndpoint: observability surface

## API and Contract Surface

Primary external interface is websocket JSON messaging:

- action: subscribe/unsubscribe/publish/command
- command handlers include reload/start/stop/restart/get_running_services and USB vendor filter query
- admin_api localhost-only routes:
  - GET /admin/v1/status
  - GET /admin/v1/config
  - POST /admin/v1/config/set
  - POST /admin/v1/services/reload
  - POST /admin/v1/services/{service}/start|stop|restart
  - GET /admin/v1/android-auto/usb-filters

Contract enforcement includes client hello, protocol version, major-version floor, and capability checks.

## Data Architecture

Persistent stores:

- PreferencesService -> SQLite key/value preferences
- SessionStore -> SQLite-backed session lifecycle state

Configuration:

- src/config/crankshaft.json
- dynamic updates via ConfigService and admin_api config/set route (optional persist)

## Source Tree Focus

- src/services/android_auto/*
- src/services/websocket/*
- src/services/media/*
- src/services/preferences/*
- src/services/session/*
- src/hal/*

## Testing Strategy

- Unit tests in src/tests (android auto transport mode, audio router, logger, error classification)
- Benchmark targets in src/benchmarks
- Build script supports coverage and quality gates

## Deployment/Packaging

- Packaging scripts under src/packaging/core
- systemd unit: crankshaft-core.service
- Deb/TGZ package generation through build.sh and CPack flows
