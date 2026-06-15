"""Command execution helpers for diagnostics collection."""

from __future__ import annotations

import subprocess
from pathlib import Path

from .types import CommandResult


def run_command(
    command: str,
    output_path: Path,
    timeout: int = 30,
) -> CommandResult:
    """Run a shell command and persist structured output.

    The output file format is intentionally human-readable for support triage.
    """
    try:
        completed = subprocess.run(
            command,
            shell=True,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )
        body: list[str] = [
            f"$ {command}",
            f"exit_code: {completed.returncode}",
        ]
        if completed.stdout:
            body.append("\n[stdout]")
            body.append(completed.stdout.rstrip())
        if completed.stderr:
            body.append("\n[stderr]")
            body.append(completed.stderr.rstrip())

        output_path.write_text("\n".join(body) + "\n", encoding="utf-8")
        return CommandResult(
            exit_code=completed.returncode,
            text=completed.stdout + completed.stderr,
        )
    except OSError as exc:  # pragma: no cover - defensive fallback
        output_path.write_text(
            f"$ {command}\nerror: {exc}\n",
            encoding="utf-8",
        )
        return CommandResult(exit_code=255, text=str(exc))


def collect_commands(
    command_specs: list[tuple[str, str]],
    commands_dir: Path,
) -> dict[str, CommandResult]:
    """Execute diagnostics command specs and return keyed results."""
    results: dict[str, CommandResult] = {}
    for name, cmd in command_specs:
        results[name] = run_command(cmd, commands_dir / f"{name}.txt")
    return results
