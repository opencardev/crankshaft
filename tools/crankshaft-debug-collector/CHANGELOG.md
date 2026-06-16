# Changelog

All notable changes to this project are documented in this file.

## [Unreleased]

### Diagnostics

- Added a compact routing timeline section to `analysis.txt` that extracts key
  `AudioRouter`, `AudioBridge`, PipeWire, WirePlumber, sink-input, link, and
  Bluetooth adapter clues into a fast scan list.
- Added timeline-specific test coverage in `tests/test_analysis_routing.py`.

## [0.2.0] - 2026-06-16

### Added

- Added collector provenance metadata capture and persistence via `collector_metadata.json`.
- Added CLI output section that prints collector metadata for quick traceability.
- Added metadata fields:
  - `collector_version`
  - `collected_at_utc`
  - `build_timestamp_utc`
  - `git_commit`
  - `git_branch`
  - `git_tag`
  - `git_dirty`
- Added tests for metadata generation and metadata section rendering.
- Added expanded audio/Bluetooth/wireless command capture set for routing triage:
  - `pactl_*`, `wpctl_status`, `pw_cli_*`
  - `bluetoothctl_*`, `rfkill`
  - `nmcli_*`, `iw_*`
  - user-unit logs for PipeWire, PipeWire-Pulse, and WirePlumber
- Added routing heuristics in `analysis.txt` to flag likely root causes:
  - missing audio services/sockets/sinks
  - Bluetooth radio blocked by rfkill
  - network interface instability hints
  - AudioRouter log activity correlated against sink-input and graph evidence
- Added routing heuristic tests in `tests/test_analysis_routing.py`.

### Changed

- `analysis.txt` now includes a dedicated **Collector metadata** section so support bundles are self-identifying.
- Updated triage documentation for expanded routing artifacts and workflows.
