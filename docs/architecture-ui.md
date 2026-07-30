# Architecture - ui (src/crankshaft-ui-slim)

## Executive Summary

ui is a Qt/QML desktop client responsible for projection display, user interaction, settings/state control, and websocket integration with core.

## Technology Stack

- C++20 + QML
- Qt6 Core/Gui/Qml/Quick/QuickControls2/Multimedia/Network/WebSockets/Sql/DBus
- Optional GStreamer WebRTC receiver path

## Architecture Pattern

Thin-client pattern: C++ service/client layer under src with QML as presentation layer.

## Component Overview

C++ application/control layer:

- SlimUiApplicationRunner, ServiceProvider
- CoreClient (websocket transport)
- AndroidAutoFacade, AndroidAutoWebRtcSession, AndroidAutoWebRtcReceiver
- ConnectionStateMachine, DeviceManager, ErrorHandler
- PreferencesFacade/PreferencesService/SettingsMigration
- AudioBridge, AudioVolumeController, DisplayBrightnessController

QML presentation layer:

- Main flow: main.qml, ApplicationController.qml, ViewNavigationController.qml
- Projection/status: AAProjectionView.qml, ConnectionStatusView.qml, ReconnectionPrompt.qml
- Settings: SettingsPanel + settings tabs
- Reusable components: settings slider, toggles, cards, segmented controls, WebRTC video output

## Integration with core

- WebSocket client in CoreClient with event/topic handling
- Contract-aware startup via hello/capability expectations from backend
- UI sends commands/preferences/display parameters and receives projection/media/system events

## Data and State

- SQLite-backed preferences service for UI settings persistence
- Settings migration/versioning via SettingsMigration and schema version keys

## Testing Strategy

- Unit tests in src/tests for facade, connection state machine, preferences, settings persistence
- Benchmark targets in src/benchmarks

## Deployment/Packaging

- Packaging files under src/packaging/ui-slim
- systemd units for UI runtime and display setup script
