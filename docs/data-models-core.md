# Data Models - core

## Persistence Overview

core uses SQLite-backed services for persistent runtime data.

## Preferences Model

Primary service: src/crankshaft-core/src/services/preferences/PreferencesService

Conceptual table shape (key-value):

- key: text primary identifier
- value: serialized variant/value payload

Behavior:

- create schema on initialization
- load cache from database at startup
- set/get/remove/clear operations with logging and error handling

## Session Model

Primary service: src/crankshaft-core/src/services/session/SessionStore

Responsibilities:

- initialize session schema
- store/retrieve active session metadata
- coordinate lifecycle-safe updates for projection/runtime state

## Related Runtime Struct Models

Representative in-memory models include:

- AndroidDevice / profile structs (android auto + profile manager)
- BluetoothDevice / WiFiNetwork structs (wireless HAL)
- Audio/video config structs (multimedia HAL)

These structs represent runtime contract objects and are serialized to event payloads/config where needed.
