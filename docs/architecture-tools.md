# Architecture - tools (tools/crankshaft-debug-collector)

## Executive Summary

tools is a standalone Python CLI package that captures diagnostics from deployed Crankshaft systems and bundles them into support archives.

## Technology Stack

- Python 3.11+
- pyproject with hatchling build backend
- uv runtime/command runner
- stdlib-based implementation (no runtime third-party deps)

## Architecture Pattern

Pipeline-style command collector with modular responsibilities.

## Component Overview

- cli.py: argument parsing and user-facing output
- collector.py: orchestration of capture workflow
- commands.py: command execution wrappers
- filesystem.py: artifact copy helpers
- analysis.py: quick triage summary generation
- constants.py: command and policy definitions

## Test Strategy

- unittest suite under tests/
- CI workflow dedicated to tool subtree changes

## Deployment

- Installed into image via wrapper script path under /usr/share/crankshaft/debug-collector
