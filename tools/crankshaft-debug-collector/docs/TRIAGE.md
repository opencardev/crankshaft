# Triage Guide

This guide explains how to use the debug collector output to diagnose common
Crankshaft problems. Archive structure and artifact locations mirror the
collector's capture policy in `constants.py`.

---

## Running the collector

```bash
# As root (recommended – captures all logs without permission gaps)
sudo crankshaft-debug-collect --output-dir /tmp

# Non-root (some journal entries may be missing)
crankshaft-debug-collect --output-dir ~/crankshaft-debug
```

The tool produces:

```
/tmp/crankshaft-debug-<timestamp>/
  analysis.txt          # Quick pass/fail check summary
  commands/             # One .txt file per diagnostic command
  config/               # Captured config files (etc/, boot/)
  logs/                 # Captured log files (/var/log/)

/tmp/crankshaft-debug-<timestamp>.tar.gz   # Archive for filing a bug report
```

---

## Start with analysis.txt

`analysis.txt` is the first triage artifact. It reports:

1. **Service checks** — `OK`, `WARN`, or `FAIL` for each service.
2. **Package checks** — whether core packages are installed.
3. **Repo check** — whether the OpenCarDev apt source is configured.
4. **Log markers** — count of keywords (`error`, `failed`, `usb`, etc.)
   across journal and dmesg output.
5. **Captured artifacts** — lists every config and log path successfully copied.

```bash
cat /tmp/crankshaft-debug-*/analysis.txt
```

---

## Command output files

Each file in `commands/` is a transcript of one shell command, formatted as:

```
$ <command>
exit_code: <N>

[stdout]
…

[stderr]
…
```

### Key files and what to look for

| File | Diagnostic |
|------|-----------|
| `crankshaft_core_status.txt` | Is the core service active? Check `Active:` line. |
| `crankshaft_ui_status.txt` | Is the UI service active? Check `WatchdogSec` errors. |
| `crankshaft_display_setup_status.txt` | Did display detection succeed? `RemainAfterExit=yes` means it ran. |
| `crankshaft_core_cat.txt` | Effective merged unit for core (includes PipeWire drop-in). |
| `crankshaft_ui_cat.txt` | Effective merged unit for UI (includes PipeWire drop-in and display env). |
| `journal_core.txt` | Full core service log for current boot. |
| `journal_ui.txt` | Full UI service log for current boot. |
| `journal_display_setup.txt` | Display detection and env-file write log. |
| `journal_boot.txt` | Full boot journal — check for early hardware errors. |
| `dmesg.txt` | Kernel ring buffer — check for USB, DRM, and audio driver errors. |
| `lsusb.txt` | USB device tree — verify Android device is visible. |
| `usb_tree.txt` | USB topology — check device is on correct bus/port. |
| `audio_status.txt` | Running PipeWire / PulseAudio / WirePlumber services. |
| `audio_processes.txt` | Process-level view of audio/Bluetooth daemons. |
| `audio_sockets.txt` | Active Pulse/PipeWire unix sockets and owners. |
| `pactl_info.txt` | Pulse server selection and runtime endpoint details. |
| `pactl_sinks.txt` | Available audio sinks and states. |
| `pactl_sink_inputs.txt` | Active playback streams routed to sinks. |
| `pactl_cards.txt` | Audio cards/profiles available for routing. |
| `wpctl_status.txt` | WirePlumber graph-level status summary. |
| `pw_cli_nodes.txt` | PipeWire node list (sinks, sources, streams). |
| `pw_cli_links.txt` | PipeWire graph links (who is connected to what). |
| `bluetoothctl_show.txt` | Adapter power/discoverability/pairing state. |
| `bluetoothctl_devices.txt` | Known Bluetooth devices. |
| `bluetoothctl_paired.txt` | Paired Bluetooth devices. |
| `rfkill.txt` | Hardware/software radio blocks (WiFi/Bluetooth). |
| `nmcli_general.txt` | NetworkManager state summary. |
| `nmcli_devices.txt` | Device state for wlan/eth interfaces. |
| `nmcli_connections.txt` | Active network connections. |
| `iw_dev.txt` | Wireless interfaces and mode details. |
| `iwconfig.txt` | Legacy wireless link diagnostics. |
| `journal_pipewire.txt` | PipeWire user-unit journal logs. |
| `journal_pipewire_pulse.txt` | PipeWire-Pulse compatibility logs. |
| `journal_wireplumber.txt` | WirePlumber policy manager logs. |
| `dpkg_core.txt` | Installed Crankshaft package versions. |
| `dpkg_aasdk.txt` | Installed AASDK package version. |
| `apt_policy_core.txt` | Candidate versions from apt — useful for diagnosing stale packages. |

---

## Common failure scenarios

### Android Auto not connecting

1. Check `lsusb.txt` — is the phone listed?  If not, the cable or USB hub is
   the problem.
2. Check `dpkg_aasdk.txt` — is `libaasdk` installed and at the expected version?
3. Check `journal_core.txt` for `AASDK`, `USB`, `timeout`, or `handshake` errors.
4. Check `crankshaft_core_status.txt` — is the service running?

### Blank screen / no display

1. Check `crankshaft_display_setup_status.txt` — did the setup service complete?
2. Check `config/run/crankshaft/ui-slim-display.env` (if captured) — was the
   correct `QT_QPA_PLATFORM` written?
3. Check `dmesg.txt` for DRM / KMS errors (`drm`, `kms`, `eglfs`).
4. Check `journal_ui.txt` for Qt platform errors (e.g., `eglfs: could not open`).

### No audio

1. Check `audio_status.txt` — are `pipewire`, `pipewire-pulse`, and
   `wireplumber` listed as running?
2. Check `audio_sockets.txt` and `pactl_info.txt` — does the service resolve
   the expected Pulse/PipeWire socket path?
3. Check `pactl_sinks.txt` and `pactl_sink_inputs.txt` — are sinks present and
   are streams routed to them during playback?
4. Check `pw_cli_nodes.txt` and `pw_cli_links.txt` — confirm graph nodes and
   links exist for Crankshaft playback.
5. Check `journal_pipewire.txt`, `journal_pipewire_pulse.txt`, and
   `journal_wireplumber.txt` for startup, permission, or graph policy failures.
6. Check `crankshaft_core_cat.txt` and `crankshaft_ui_cat.txt` — are
   `PULSE_SERVER`, `PIPEWIRE_RUNTIME_DIR`, and `XDG_RUNTIME_DIR` set?
7. Check `journal_core.txt` for `AudioRouter` / `AudioHAL` errors and
   `journal_ui.txt` for `AudioBridge` errors.
8. If the core and UI disagree about backend availability, follow
   [AUDIO_ROUTING_REMEDIATION.md](AUDIO_ROUTING_REMEDIATION.md).

### Bluetooth audio route not switching

1. Check `bluetoothctl_show.txt` — adapter must be powered and not blocked.
2. Check `rfkill.txt` — ensure Bluetooth is not soft/hard blocked.
3. Check `bluetoothctl_paired.txt` and `bluetoothctl_devices.txt` — verify the
   target device exists and is paired.
4. Check `journal_bluetooth.txt` for pairing/profile negotiation failures.
5. Correlate with `pactl_cards.txt` / `pactl_sinks.txt` to ensure Bluetooth
   audio profile endpoints are exposed to PipeWire/Pulse.

### Wireless / hotspot side-effects on audio routing

1. Check `nmcli_general.txt` and `nmcli_devices.txt` for interface state
   flapping or unmanaged devices.
2. Check `nmcli_connections.txt` and `iw_dev.txt` for active mode changes
   (AP/client) during projection setup.
3. Check `journal_network.txt` for reconnect loops that may race service start.

### Service keeps restarting

1. Check `crankshaft_core_status.txt` or `crankshaft_ui_status.txt` —
   `Restart=` and the exit code of the most recent run.
2. Check `journal_core.txt` / `journal_ui.txt` for the crash reason.
3. Check `systemd_failed.txt` — lists all failed units.

### Settings not persisted across reboots

1. Check `config/var/lib/crankshaft/slim-ui/.local/share/slim-ui-preferences.ini`
   in the archive — are the expected keys present?
2. Check `journal_ui.txt` for `PreferencesFacade` or `PreferencesService` errors.
3. Verify `/var/lib/crankshaft` is writable by the `crankshaft` user:
   `ls -la /var/lib/crankshaft`.

---

## Captured config reference

| Archive path | Source | Purpose |
| --- | --- | --- |
| `config/etc/crankshaft/` | `/etc/crankshaft/` | Core config directory and profiles |
| `config/etc/default/crankshaft-core` | `/etc/default/crankshaft-core` | Core service defaults |
| `config/var/lib/crankshaft/slim-ui/` | `/var/lib/crankshaft/slim-ui/` | Slim UI state folder containing either `slim-ui-preferences.ini` or `slim-ui-preferences.db` |
| `config/run/crankshaft/ui-slim-display.env` | `/run/crankshaft/ui-slim-display.env` | Runtime Qt platform env written by the display setup service |
| `config/etc/pipewire/` | `/etc/pipewire/` | PipeWire daemon/runtime configuration |
| `config/etc/wireplumber/` | `/etc/wireplumber/` | WirePlumber policy/config overrides |
| `config/etc/bluetooth/main.conf` | `/etc/bluetooth/main.conf` | BlueZ adapter policy defaults |
| `config/etc/NetworkManager/NetworkManager.conf` | `/etc/NetworkManager/NetworkManager.conf` | NetworkManager global behavior |
| `config/etc/NetworkManager/system-connections/` | `/etc/NetworkManager/system-connections/` | Saved wired/wireless connection profiles |
| `config/etc/apt/sources.list.d/opencardev.list` | OpenCarDev apt source | Repo URL and suite |
| `config/etc/systemd/system/crankshaft-core.service.d/` | Drop-in directory | PipeWire and local overrides |
| `config/etc/systemd/system/crankshaft-ui-slim.service.d/` | Drop-in directory | PipeWire and local overrides |
| `config/boot/firmware/config.txt` | Raspberry Pi firmware config | GPU memory, overlays, audio |

---

## Captured logs reference

| Archive path | Source | Content |
|---|---|---|
| `logs/var/log/crankshaft/` | `/var/log/crankshaft/` | Core and UI log files |
| `logs/var/log/syslog` | `/var/log/syslog` | System syslog (Debian/Ubuntu) |
| `logs/var/log/messages` | `/var/log/messages` | System messages (RHEL-style) |
| `logs/var/log/kern.log` | `/var/log/kern.log` | Kernel log |
| `logs/var/log/daemon.log` | `/var/log/daemon.log` | Daemon log |
| `logs/var/log/NetworkManager/` | `/var/log/NetworkManager/` | NetworkManager daemon and plugin logs |
| `logs/var/log/wpa_supplicant.log` | `/var/log/wpa_supplicant.log` | WiFi auth/association events |

---

## Filing a bug report

Attach `crankshaft-debug-<timestamp>.tar.gz` to the issue.

Include in the report description:

- Which symptom is occurring (no audio, blank screen, no AA connection, etc.)
- What the phone model and Android version are
- Whether the problem is reproducible or intermittent
- Whether a recent package update preceded the problem

See `analysis.txt` investigation steps for additional checks to perform before
filing.
