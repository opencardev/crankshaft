# Crankshaft Settings Reference

All `crankshaft-ui-slim` settings are persisted via `PreferencesService` using
an INI file at:

```
/var/lib/crankshaft/slim-ui/.local/share/slim-ui-preferences.ini
```

The file is read by `crankshaft-ui-slim-display-setup.sh` on every boot
(for display rotation) and by `PreferencesFacade` on service start.

All keys use a `slim_ui.*` prefix to isolate slim-UI settings from any other
preferences stored by core services.

### Runtime config handoff

| Path | Writer | Reader | Purpose |
|------|--------|--------|---------|
| `/var/lib/crankshaft/slim-ui/.local/share/slim-ui-preferences.ini` | `PreferencesFacade` | `PreferencesFacade`, `crankshaft-ui-slim-display-setup.sh` | Persisted UI settings |
| `/run/crankshaft/ui-slim-display.env` | `crankshaft-ui-slim-display-setup.sh` | `crankshaft-ui-slim.service` | Boot-time Qt platform and display rotation environment |

These two files are the main bridge between persistent UI configuration and
the runtime display session:

- The INI file stores the source of truth for settings changed in the UI.
- The env file is regenerated on boot from the INI file and the current DRM
  display state.
- If the display settings change, the env file takes effect on the next boot or
  service restart.

---

## Settings keys

### Display

| Key | Type | Default | Valid range | Description |
|-----|------|---------|-------------|-------------|
| `slim_ui.display.brightness` | `int` | `50` | 0–100 | Display backlight brightness (%) |
| `slim_ui.display.rotation` | `int` | `0` | 0, 90, 180, 270 | Display rotation in degrees |
| `slim_ui.display.aaFullscreenDelaySeconds` | `int` | `0` | 0–30 | Seconds after projection starts before window enters fullscreen. `0` disables automatic fullscreen. |

### Audio

| Key | Type | Default | Valid range | Description |
|-----|------|---------|-------------|-------------|
| `slim_ui.audio.volume` | `int` | `50` | 0–100 | Master volume (%) |

### Connection

| Key | Type | Default | Valid values | Description |
|-----|------|---------|--------------|-------------|
| `slim_ui.connection.preference` | `string` | `USB` | `USB`, `WIRELESS` | Preferred Android Auto transport |
| `slim_ui.device.lastConnected` | `string` | _(empty)_ | Any string | Last successfully connected device ID |

### Theme

| Key | Type | Default | Valid values | Description |
|-----|------|---------|--------------|-------------|
| `slim_ui.theme.mode` | `string` | `DARK` | `LIGHT`, `DARK` | UI colour theme |

### Schema versioning

| Key | Type | Description |
|-----|------|-------------|
| `slim_ui.schema_version` | `int` | Schema version used by `SettingsMigration` to detect and run migrations |

---

## Validation rules

`PreferencesFacade` enforces the following on every read and write:

- **Percentage values** (`brightness`, `volume`): clamped to `[0, 100]`.
- **Rotation**: rejected if not exactly 0, 90, 180, or 270; reset to 0.
- **Fullscreen delay**: clamped to `[0, 30]`.
- **Connection preference**: rejected if not `USB` or `WIRELESS`.
- **Theme mode**: rejected if not `LIGHT` or `DARK`.

Corrupted or out-of-range values are detected in `detectAndRecoverCorruption()`
and reset to factory defaults. A `settingsRecovered(fields)` signal is emitted
listing the recovered field names.

---

## Factory defaults

| Key | Default |
|-----|---------|
| `slim_ui.display.brightness` | `50` |
| `slim_ui.display.rotation` | `0` |
| `slim_ui.display.aaFullscreenDelaySeconds` | `0` |
| `slim_ui.audio.volume` | `50` |
| `slim_ui.connection.preference` | `USB` |
| `slim_ui.device.lastConnected` | _(empty)_ |
| `slim_ui.theme.mode` | `DARK` |

Invoking **Reset to defaults** from the Settings panel calls
`PreferencesFacade::resetToDefaults()` which restores all of the above and
persists them immediately.

---

## Display rotation and boot interaction

`crankshaft-ui-slim-display-setup.sh` reads `slim_ui.display.rotation` from
the INI file before `crankshaft-ui-slim` starts. It writes the value as
`QT_QPA_EGLFS_ROTATION` into `/run/crankshaft/ui-slim-display.env`, which the
service sources via `EnvironmentFile`.  This means rotation changes made in the
settings panel take effect on the **next service restart**.

---

## AA projection fullscreen delay

When `slim_ui.display.aaFullscreenDelaySeconds` is greater than `0`, the UI
starts a countdown as soon as the Android Auto projection view becomes the
active view (and the settings panel is closed).

- The projection toolbar shows `AndroidAuto Projection (fullscreen in <N>s)`
  during the countdown.
- After the timer fires, `Window.visibility` is set to `Window.FullScreen`.
- Opening settings, closing projection, or losing the connection cancels the
  timer and returns the window to `Window.Windowed`.
- The countdown restarts if projection becomes active again.

Setting the value to `0` completely disables the feature; the window remains
in its initial state.

---

## Reading settings from the shell

```bash
# Print all current slim-UI settings
cat /var/lib/crankshaft/slim-ui/.local/share/slim-ui-preferences.ini

# Read a specific key (INI awk one-liner)
awk -F= '$1 == "slim_ui.display.rotation" { print $2 }' \
    /var/lib/crankshaft/slim-ui/.local/share/slim-ui-preferences.ini
```
