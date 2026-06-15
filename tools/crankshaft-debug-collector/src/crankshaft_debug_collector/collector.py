"""Top-level collection orchestration.

This module coordinates command capture, file capture, analysis generation,
and archive creation. Keeping orchestration isolated simplifies future testing
and lets callers reuse collection internals.
"""

from __future__ import annotations

import datetime
import tarfile
from pathlib import Path

from .analysis import build_analysis
from .commands import collect_commands
from .constants import (
    COMMAND_SPECS,
    CONFIG_CANDIDATES,
    LOG_CANDIDATES,
    SERVICE_CONFIG_CANDIDATES,
)
from .filesystem import copy_candidates


def collect(output_dir: str = "/tmp") -> tuple[Path, Path, list[str]]:
    """Collect diagnostics and return key output paths plus copied sources."""
    timestamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    base_dir = Path(output_dir).expanduser().resolve()
    work_dir = base_dir / f"crankshaft-debug-{timestamp}"
    commands_dir = work_dir / "commands"
    config_dir = work_dir / "config"
    logs_dir = work_dir / "logs"

    commands_dir.mkdir(parents=True, exist_ok=True)
    config_dir.mkdir(parents=True, exist_ok=True)
    logs_dir.mkdir(parents=True, exist_ok=True)

    results = collect_commands(COMMAND_SPECS, commands_dir)

    copied_configs = copy_candidates(CONFIG_CANDIDATES, config_dir)
    copied_service_configs = copy_candidates(
        SERVICE_CONFIG_CANDIDATES,
        config_dir,
    )
    copied_logs = copy_candidates(LOG_CANDIDATES, logs_dir)

    analysis = build_analysis(results, work_dir)
    _append_capture_sections(
        analysis,
        copied_configs,
        copied_service_configs,
        copied_logs,
    )

    (work_dir / "analysis.txt").write_text(
        "\n".join(analysis) + "\n",
        encoding="utf-8",
    )

    archive_path = base_dir / f"crankshaft-debug-{timestamp}.tar.gz"
    with tarfile.open(archive_path, "w:gz") as tar:
        tar.add(work_dir, arcname=work_dir.name)

    copied = copied_configs + copied_service_configs + copied_logs
    return work_dir, archive_path, copied


def _append_capture_sections(
    analysis: list[str],
    copied_configs: list[str],
    copied_service_configs: list[str],
    copied_logs: list[str],
) -> None:
    """Append a deterministic summary of copied artifacts into analysis."""
    analysis.append("")
    analysis.append("Captured configuration artifacts:")
    _append_section(
        analysis,
        "Base config files/folders",
        copied_configs,
    )
    _append_section(
        analysis,
        "Crankshaft service configs",
        copied_service_configs,
    )

    analysis.append("")
    analysis.append("Captured log artifacts:")
    _append_section(
        analysis,
        "System and Crankshaft log files/folders",
        copied_logs,
    )


def _append_section(
    analysis: list[str],
    title: str,
    paths: list[str],
) -> None:
    """Append a titled list section with explicit empty-state output."""
    if paths:
        analysis.append(f"- {title}:")
        for source in paths:
            analysis.append(f"  - {source}")
    else:
        analysis.append(f"- {title}: none found")
