"""Typed models used by collector modules."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class CommandResult:
    """Captures command execution metadata and combined command output."""

    exit_code: int
    text: str
