"""Analysis generation for the Crankshaft support bundle."""

from __future__ import annotations

import datetime
import os
import re
from pathlib import Path

from .constants import ERROR_MARKERS, EXPECTED_PACKAGES
from .types import CommandResult


def check_repo_present() -> bool:
    """Verify OpenCarDev apt source is configured."""
    repo_file = Path("/etc/apt/sources.list.d/opencardev.list")
    if not repo_file.exists():
        return False
    try:
        content = repo_file.read_text(encoding="utf-8", errors="replace")
    except OSError:  # pragma: no cover - defensive fallback
        return False
    return "apt.opencardev.org" in content


def is_unprivileged_user() -> bool:
    """Return True when running as non-root on POSIX systems."""
    geteuid = getattr(os, "geteuid", None)
    if not callable(geteuid):
        return False
    return bool((geteuid)() != 0)


def parse_pkg_installed(pkg_status_output: str) -> set[str]:
    """Extract installed package names from dpkg -l output."""
    pattern = re.compile(r"^ii\s+(\S+)", re.MULTILINE)
    return set(pattern.findall(pkg_status_output))


def build_analysis(
    results: dict[str, CommandResult],
    work_dir: Path,
) -> list[str]:
    """Build human-readable analysis text included in the archive."""
    analysis: list[str] = []
    analysis.append("Crankshaft Debug Analysis")
    analysis.append("========================")
    analysis.append(f"Generated at: {datetime.datetime.now().isoformat()}")
    analysis.append(f"Output folder: {work_dir}")
    analysis.append("")

    if is_unprivileged_user():
        analysis.append(
            "WARNING: script was not run as root; some logs may be incomplete."
        )

    services = {
        "crankshaft-core": "crankshaft_core_status",
        "crankshaft-ui-slim": "crankshaft_ui_status",
        "crankshaft-ui-slim-display-setup": "crankshaft_display_setup_status",
        "bluetooth": "bluetooth_status",
    }
    analysis.append("Service checks:")
    for service_name, key in services.items():
        text = results.get(key, CommandResult(255, "")).text
        if (
            "Active: active (running)" in text
            or "Active: active (exited)" in text
        ):
            analysis.append(f"- OK: {service_name} is active")
        elif (
            "could not be found" in text.lower()
            or "loaded: not-found" in text.lower()
        ):
            analysis.append(f"- FAIL: {service_name} service file not found")
        else:
            analysis.append(
                f"- WARN: {service_name} inactive."
                f" Review commands/{key}.txt"
            )

    analysis.append("")
    analysis.append("Package checks:")
    installed_pkgs = parse_pkg_installed(
        results.get("dpkg_core", CommandResult(255, "")).text
        + "\n"
        + results.get("dpkg_aasdk", CommandResult(255, "")).text
    )
    for pkg in EXPECTED_PACKAGES:
        if pkg in installed_pkgs:
            analysis.append(f"- OK: {pkg} installed")
        else:
            analysis.append(f"- FAIL: {pkg} missing")

    if check_repo_present():
        analysis.append("- OK: OpenCarDev apt repo configured")
    else:
        analysis.append("- FAIL: OpenCarDev apt repo missing or malformed")

    analysis.append("")
    journal_blob = "\n".join(
        [
            results.get("journal_core", CommandResult(255, "")).text,
            results.get("journal_boot", CommandResult(255, "")).text,
            results.get("dmesg", CommandResult(255, "")).text,
        ]
    ).lower()

    analysis.append("Relevant log markers:")
    for marker in ERROR_MARKERS:
        count = journal_blob.count(marker)
        analysis.append(f"- {marker}: {count} matches")

    analysis.append("")
    analysis.append("Suggested investigation steps:")
    analysis.append(
        "1. Compare commands/dpkg_*.txt between dev build and pi-gen image"
    )
    analysis.append(
        "2. Compare commands/journal_core.txt and commands/dmesg.txt"
        " for USB/AASDK"
    )
    analysis.append(
        "3. Verify apt repo and candidate versions in"
        " commands/apt_policy_*.txt"
    )
    analysis.append(
        "4. Ensure phone is connected and visible in"
        " commands/lsusb.txt during test"
    )

    return analysis
