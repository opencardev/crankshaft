# API Contracts - core

## Transport

- Protocol: WebSocket JSON
- Server component: src/crankshaft-core/src/services/websocket/WebSocketServer
- Mode: ws:// (optional secure mode support in server)

## Message Categories

### Client -> Server Actions

- subscribe(topic)
- unsubscribe(topic)
- publish(topic, payload)
- command(command, params)
- admin_api (localhost-only request envelope)

### Server -> Client

- event(topic, payload, timestamp)
- service_response(command, success, error?, data?, timestamp)
- admin_api_response(id, ok, status, path, body, error?, timestamp)
- error(message)

## Service Commands

- reload_services
- start_service (requires params.service)
- stop_service (requires params.service)
- restart_service (requires params.service)
- get_running_services
- get_android_auto_usb_vendor_filters

## Admin API Routes (localhost enforced)

- GET /admin/v1/status
- GET /admin/v1/config
- POST /admin/v1/config/set
- POST /admin/v1/services/reload
- POST /admin/v1/services/{service}/start
- POST /admin/v1/services/{service}/stop
- POST /admin/v1/services/{service}/restart
- GET /admin/v1/android-auto/usb-filters

## Contract and Policy Controls

- Client hello and contract satisfaction checks before privileged flow
- Protocol version compatibility and major-version floor
- Capability gating (including android-auto capability requirement when enabled)
- Unknown routes/commands return explicit error payloads
