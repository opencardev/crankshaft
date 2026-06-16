"""Typed models used by collector modules."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class CommandResult:
    """Captures command execution metadata and combined command output."""

    exit_code: int
    text: str


@dataclass(frozen=True)
class CollectorMetadata:
    """Version/build provenance metadata embedded in support bundles."""

    collector_version: str
    collected_at_utc: str
    build_timestamp_utc: str
    git_commit: str
    git_branch: str
    git_tag: str
    git_dirty: str
