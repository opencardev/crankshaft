# Integration Architecture

## Parts and Interfaces

1. ui -> core
- Transport: WebSocket
- Direction: bidirectional
- Data: subscriptions, service commands, admin requests (localhost), event broadcast payloads

2. core -> aasdk
- Transport: in-process library integration (compiled dependency)
- Data: Android Auto protocol/session/channel primitives

3. image -> runtime artifacts
- Transport: build pipeline/package staging
- Data: package installation, service unit deployment, host tuning and enablement scripts

4. tools -> deployed system
- Transport: local shell command and filesystem inspection
- Data: logs, configs, service files, diagnostics metadata

## Data and Control Flow

- UI action -> websocket command -> core service manager -> service execution -> event bus publish -> websocket event fan-out
- Android Auto session events (core + aasdk) -> media/control state -> UI projection/status updates
- Image build pipeline packages core/ui/tools dependencies into deployable SD image outputs

## Security and Boundary Notes

- admin_api routes are restricted to loopback clients
- client contract checks enforce hello/version/capability requirements
- package/build boundaries keep protocol library concerns separated from UI layer
