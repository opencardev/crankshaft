# Audio Routing Remediation Guide

## What this guide covers

Use this guide when the debug archive shows a split-brain audio state:

- `crankshaft-core` reports `No audio backend available`
- `crankshaft-ui-slim` reports `Detected PulseAudio backend` or initializes successfully
- `pactl_sink_inputs.txt` and `pw_cli_links.txt` fail with connection errors
- Bluetooth audio is unavailable because the radio is blocked

The goal is to restore a single, healthy audio path that both core and UI can reach.

## 1. Confirm the failure pattern

In `analysis.txt`, look for these combinations:

- Core says audio is unavailable, but UI says audio is initialized.
- `pactl_info.txt` reports `Connection refused` or similar.
- `pw_cli_links.txt` reports `Host is down` or `failed to connect`.
- `rfkill.txt` reports Bluetooth soft or hard block.
- `journal_pipewire.txt` or `journal_wireplumber.txt` shows RTKit or session startup errors.

If those are present, fix the runtime environment first before chasing codec or routing logic.

## 2. Fix the core service runtime environment

`crankshaft-core` must run with explicit runtime paths instead of inheriting a login shell environment.

Recommended service environment:

- `HOME=/var/lib/crankshaft`
- `XDG_CONFIG_HOME=/var/lib/crankshaft/.config`
- `XDG_DATA_HOME=/var/lib/crankshaft/.local/share`
- `XDG_STATE_HOME=/var/lib/crankshaft/.local/state`
- `XDG_CACHE_HOME=/var/cache/crankshaft`
- `XDG_RUNTIME_DIR=/run/user/%U`
- `PIPEWIRE_RUNTIME_DIR=/run/user/%U`
- `PULSE_SERVER=unix:/run/user/%U/pulse/native`

Also ensure these paths are writable by the `crankshaft` user.

If you are building the image, verify that the package post-install step creates:

- `/var/lib/crankshaft/.config`
- `/var/lib/crankshaft/.local/share`
- `/var/lib/crankshaft/.local/state`
- `/var/cache/crankshaft`

## 3. Make the PipeWire user session reachable

The core service only works if the user-session audio stack is alive and reachable.

Check and enable:

```bash
systemctl --user status pipewire pipewire-pulse wireplumber
systemctl --user enable pipewire.service pipewire.socket pipewire-pulse.service pipewire-pulse.socket wireplumber.service
```

If the machine boots without a login session, enable linger so the `crankshaft` user manager survives boot:

```bash
sudo loginctl enable-linger crankshaft
```

Then restart the user manager or reboot:

```bash
sudo systemctl restart user@$(id -u crankshaft).service
```

## 4. Repair Bluetooth audio access

If Bluetooth audio is needed, unblock the radio first:

```bash
sudo rfkill unblock bluetooth
rfkill list
```

Then confirm the adapter is powered and visible:

```bash
bluetoothctl show
bluetoothctl devices
bluetoothctl paired-devices
```

If the adapter is still blocked, Bluetooth audio routing will fail even if PipeWire is healthy.

## 5. Verify the backend is actually reachable

After the environment is fixed, validate the endpoints from the `crankshaft` account:

```bash
pactl info
pactl list short sinks
pactl list short sink-inputs
wpctl status
pw-cli ls Link
```

Expected outcome:

- `pactl info` should reach the active server
- sinks should be listed
- sink inputs should appear when audio is playing
- PipeWire links should be visible

## 6. Confirm the core and UI agree

The final check is consistency between core and UI:

- `journal_core.txt` should show `AudioRouter` initialized with a backend
- `journal_ui.txt` should show `AudioBridge` using the same backend family
- `pactl_sink_inputs.txt` should show active streams during playback
- `pw_cli_links.txt` should show connected graph links

If the UI works but the core does not, the core service environment is still wrong.

## 7. Recommended image/build changes

For the image builder, keep these items in place:

- Stage60 enables `pipewire.service`, `pipewire.socket`, `pipewire-pulse.service`, `pipewire-pulse.socket`, and `wireplumber.service`
- Stage60 enables `user@<uid>.service` for `crankshaft`
- Stage60 enables linger for `crankshaft`
- The core and UI systemd drop-ins define the runtime environment variables above

## 8. Success criteria

You have fixed the issue when all of the following are true:

- `crankshaft-core` no longer logs `No audio backend available`
- `pactl info` succeeds from the `crankshaft` context
- `pactl_sink_inputs.txt` shows active streams during playback
- `pw_cli_links.txt` shows links in the PipeWire graph
- Bluetooth audio can be enabled without `rfkill` blocks

## 9. Quick checklist

1. Unblock Bluetooth with `rfkill unblock bluetooth` if needed.
2. Verify `crankshaft-core.service` has the runtime environment variables.
3. Confirm PipeWire, Pulse, and WirePlumber user services are enabled.
4. Enable linger for the `crankshaft` user.
5. Re-run the collector and compare `journal_core.txt`, `pactl_info.txt`, and `pw_cli_links.txt`.

## 10. Related collector artifacts

Look at these files in the archive for confirmation:

- `commands/journal_core.txt`
- `commands/journal_ui.txt`
- `commands/audio_status.txt`
- `commands/audio_sockets.txt`
- `commands/pactl_info.txt`
- `commands/pactl_sink_inputs.txt`
- `commands/pw_cli_links.txt`
- `commands/rfkill.txt`
- `commands/bluetoothctl_show.txt`
- `commands/nmcli_devices.txt`
