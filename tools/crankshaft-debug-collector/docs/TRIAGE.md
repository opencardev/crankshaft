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
2. Check `crankshaft_ui_cat.txt` — are the PipeWire environment variables
   (`PULSE_SERVER`, `PIPEWIRE_RUNTIME_DIR`) present in the merged unit?
3. Check `journal_core.txt` for `AudioRouter` or `AudioHAL` errors.
4. Check `journal_ui.txt` for `AudioBridge` errors.

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
