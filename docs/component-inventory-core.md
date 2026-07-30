# Component Inventory - core

## Service Components

- AndroidAutoService / RealAndroidAutoService
- WebSocketServer
- MediaService
- BluetoothService
- PreferencesService
- SessionStore
- ConfigService
- DiagnosticsEndpoint / MetricsEndpoint
- ProfileManager
- ServiceManager

## HAL Components

- multimedia: AudioHAL, VideoHAL, MediaPipeline, GStreamerVideoDecoder, GStreamerWebRtcBridge
- wireless: WiFiHAL/WiFiManager, BluetoothHAL/BluetoothManager, NetworkService
- transport: Transport, UARTTransport
- functional: GPS/CAN and device abstractions

## Reuse Notes

Backend components are service-oriented and can be extended through ServiceManager/EventBus patterns without UI-specific branching.
