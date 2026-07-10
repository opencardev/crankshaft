# Crankshaft Debug Collector

This uv project packages the Crankshaft support bundle tool as a maintainable,
modular Python application.

## Why this project exists

The collector needs to evolve with Crankshaft services and image stages. Keeping
it as a standalone project makes code review, testing, and installation wiring
simpler than maintaining a large monolithic script in stage files.

## Features

- Captures diagnostic command outputs into a `commands/` folder.
- Captures runtime configuration artifacts into `config/`.
- Captures Crankshaft and system logs into `logs/`.
- Captures Crankshaft systemd unit files and drop-ins.
- Generates `analysis.txt` with quick triage checks and guidance.
- Generates `collector_metadata.json` with collector version/build/git provenance.
- Produces a single compressed archive for support exchange.
- Includes an HDMI/video debug helper script for Raspberry Pi AASDK/Display diagnostics.

## Run locally with uv

```bash
cd tools/crankshaft-debug-collector
uv run crankshaft-debug-collect --output-dir /tmp
```

## Run tests

The project uses Python's built-in `unittest` (no extra dependencies needed).

```bash
cd tools/crankshaft-debug-collector
uv run python -m unittest discover -s tests -p "test_*.py" -v
```

Reusable runner scripts are also provided:

```bash
tools/crankshaft-debug-collector/scripts/run-tests.sh
```

```powershell
tools/crankshaft-debug-collector/scripts/run-tests.ps1
```

CI is wired through [debug-collector-tests.yml](../../.github/workflows/debug-collector-tests.yml)
and automatically runs when files under
`tools/crankshaft-debug-collector/` change.

## Install wrapper into image

Stage60 installs a tiny wrapper script that executes this project directly from
`/usr/share/crankshaft/debug-collector`.

## Project layout

- `src/crankshaft_debug_collector/constants.py`: command and file policies.
- `src/crankshaft_debug_collector/commands.py`: command execution.
- `src/crankshaft_debug_collector/filesystem.py`: copy helpers.
- `src/crankshaft_debug_collector/analysis.py`: analysis/report generation.
- `src/crankshaft_debug_collector/collector.py`: orchestration.
- `src/crankshaft_debug_collector/cli.py`: CLI entrypoint.

See `docs/ARCHITECTURE.md` for flow and maintenance guidance.

## Documentation

| Document | Content |
| --- | --- |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Module responsibilities, data flow, extension guide |
| [docs/SERVICES.md](docs/SERVICES.md) | Captured systemd services: purpose, runtime dirs, useful commands |
| [docs/AUDIO_ROUTING_REMEDIATION.md](docs/AUDIO_ROUTING_REMEDIATION.md) | Step-by-step fix path for audio backend mismatch, Bluetooth blocks, and PipeWire connectivity |
| [docs/SETTINGS.md](docs/SETTINGS.md) | All `slim_ui.*` preference keys, defaults, and validation rules |
| [docs/TRIAGE.md](docs/TRIAGE.md) | How to interpret archive output and diagnose common failures |

Project history: [CHANGELOG.md](CHANGELOG.md)
