# Development Guide - tools

## Prerequisites

- Python 3.11+
- uv

## Setup and Run

```bash
cd tools/crankshaft-debug-collector
uv run crankshaft-debug-collect --output-dir /tmp
```

## Tests

```bash
cd tools/crankshaft-debug-collector
uv run python -m unittest discover -s tests -p "test_*.py" -v
```

## Packaging

The project is packaged through pyproject.toml using hatchling.
