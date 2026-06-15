# Crankshaft Service Reference

This document describes the services and runtime files that the debug collector
captures.

## Service order

- `crankshaft-ui-slim-display-setup.service` runs first.
- `crankshaft-core.service` starts next.
- `crankshaft-ui-slim.service` starts after the display setup and core service.

## crankshaft-core.service

Purpose:

- Android Auto backend runtime
- transport, audio, video, Bluetooth, and configuration coordination

Key properties:

- Binary: `/usr/bin/crankshaft-core`
- User / group: `crankshaft:crankshaft`
- Type: `simple`
- Wanted by: `multi-user.target`
- After: `network.target`

Useful diagnostics:

```bash
systemctl status crankshaft-core
journalctl -u crankshaft-core -b
systemctl cat crankshaft-core
```

## crankshaft-ui-slim-display-setup.service

Purpose:

- Detects whether a physical DRM display is attached
- Writes the boot-time Qt platform environment file
- Reads the persisted display rotation from the slim-UI preferences file

Key properties:

- Binary: `/usr/libexec/crankshaft/crankshaft-ui-slim-display-setup.sh`
- Type: `oneshot`
- `RemainAfterExit=yes`
- Before: `crankshaft-ui-slim.service`

Generated file:

- `/run/crankshaft/ui-slim-display.env`

What the file contains:

- `QT_QPA_PLATFORM=eglfs` when a physical display is detected
- `QT_QPA_PLATFORM=vnc:size=1280x720:port=5900` when no display is detected
- `QT_QPA_EGLFS_ROTATION=<0|90|180|270>` when EGLFS mode is active

Useful diagnostics:

```bash
systemctl status crankshaft-ui-slim-display-setup
cat /run/crankshaft/ui-slim-display.env
journalctl -u crankshaft-ui-slim-display-setup -b
```

## crankshaft-ui-slim.service

Purpose:

- Qt 6 / QML Android Auto frontend
- projection rendering, touch forwarding, settings UI, and Bluetooth UI

Key properties:

- Binary: `/usr/bin/crankshaft-ui-slim`
- User / group: `crankshaft:crankshaft`
- Type: `notify`
- Wanted by: `graphical.target`
- Requires: `crankshaft-ui-slim-display-setup.service`, `crankshaft-core.service`

Important environment:

- `QT_QPA_PLATFORM=eglfs` by default
- `QT_QPA_EGLFS_INTEGRATION=eglfs_kms`
- `SLIM_UI_LOG_FILE=/var/log/crankshaft/ui_slim.log`
- `QT_MULTIMEDIA_PREFERRED_PLUGINS=pulseaudio,alsa`
- `HOME=/var/lib/crankshaft/slim-ui`

Useful diagnostics:

```bash
systemctl status crankshaft-ui-slim
journalctl -u crankshaft-ui-slim -b
systemctl cat crankshaft-ui-slim
```

## Captured config files

The collector archives the following runtime/persistent files for these
services:

- `/var/lib/crankshaft/slim-ui/`
- `/run/crankshaft/ui-slim-display.env`
- `/etc/systemd/system/crankshaft-core.service.d/20-pipewire-runtime.conf`
- `/etc/systemd/system/crankshaft-ui-slim.service.d/20-pipewire-runtime.conf`

The entire slim-UI state folder is archived so both `QSettings` backends are
covered automatically:

- INI-backed builds write `slim-ui-preferences.ini` into the folder.
- DB-backed builds write `slim-ui-preferences.db` into the folder.

The display env file is regenerated on each boot and is consumed by
`crankshaft-ui-slim.service`.
