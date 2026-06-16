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
    if os.name != "posix":
        return False
    try:
        return bool(os.getuid() != 0)  # type: ignore[attr-defined]
    except (AttributeError, OSError):
        return False


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
    _append_routing_heuristics(analysis, results)

    analysis.append("")
    _append_routing_timeline(analysis, results)

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


def _append_routing_heuristics(
    analysis: list[str],
    results: dict[str, CommandResult],
) -> None:
    """Append first-pass heuristics for audio/Bluetooth/wireless routing."""
    analysis.append("Audio/Bluetooth/Wireless routing heuristics:")

    audio_status = results.get(
        "audio_status",
        CommandResult(255, ""),
    ).text.lower()
    if _contains_any(audio_status, ["pipewire", "wireplumber", "pulse"]):
        analysis.append("- OK: audio service processes reported by systemd")
    else:
        analysis.append(
            "- FAIL: no PipeWire/Pulse/WirePlumber services detected "
            "(commands/audio_status.txt)"
        )

    sockets = results.get("audio_sockets", CommandResult(255, "")).text.lower()
    has_pipewire_socket = "pipewire" in sockets
    has_pulse_socket = "pulse" in sockets
    if has_pipewire_socket and has_pulse_socket:
        analysis.append("- OK: PipeWire and Pulse sockets are visible")
    elif has_pipewire_socket or has_pulse_socket:
        analysis.append(
            "- WARN: partial audio socket visibility; check "
            "commands/audio_sockets.txt"
        )
    else:
        analysis.append(
            "- FAIL: no PipeWire/Pulse sockets detected "
            "(commands/audio_sockets.txt)"
        )

    pactl_info = results.get("pactl_info", CommandResult(255, "")).text.lower()
    if _contains_any(
        pactl_info,
        [
            "connection failure",
            "connection refused",
            "no such file",
            "not found",
        ],
    ):
        analysis.append(
            "- FAIL: pactl cannot reach Pulse/PipeWire endpoint "
            "(commands/pactl_info.txt)"
        )
    elif "server string" in pactl_info:
        analysis.append("- OK: pactl can query the active server")
    else:
        analysis.append(
            "- WARN: pactl info inconclusive; review commands/pactl_info.txt"
        )

    sink_lines = _nonempty_lines(
        results.get("pactl_sinks", CommandResult(255, "")).text
    )
    if not sink_lines:
        analysis.append("- FAIL: no Pulse/PipeWire sinks reported")
    else:
        analysis.append(f"- OK: {len(sink_lines)} sink(s) reported")

    link_lines = _nonempty_lines(
        results.get("pw_cli_links", CommandResult(255, "")).text
    )
    if not link_lines:
        analysis.append(
            "- WARN: PipeWire graph has no visible links "
            "(commands/pw_cli_links.txt)"
        )
    else:
        analysis.append(
            f"- OK: {len(link_lines)} PipeWire link line(s) reported"
        )

    sink_input_lines = _nonempty_lines(
        results.get("pactl_sink_inputs", CommandResult(255, "")).text
    )
    core_log = results.get("journal_core", CommandResult(255, "")).text.lower()
    has_audio_router_log = "audiorouter" in core_log

    if has_audio_router_log and not sink_input_lines:
        analysis.append(
            "- FAIL: AudioRouter activity found but no active sink inputs "
            "(commands/pactl_sink_inputs.txt)"
        )
    elif has_audio_router_log and sink_input_lines:
        analysis.append(
            "- OK: AudioRouter activity correlates with active sink inputs"
        )
    else:
        analysis.append(
            "- WARN: no AudioRouter activity found in core journal "
            "(commands/journal_core.txt)"
        )

    if has_audio_router_log and sink_input_lines and not link_lines:
        analysis.append(
            "- WARN: sink inputs exist but PipeWire links are absent; "
            "check graph policy/runtime user"
        )

    rfkill = results.get("rfkill", CommandResult(255, "")).text.lower()
    if "bluetooth" not in rfkill:
        analysis.append("- WARN: rfkill output does not list Bluetooth radios")
    elif _contains_any(rfkill, ["soft blocked: yes", "hard blocked: yes"]):
        analysis.append(
            "- FAIL: Bluetooth radio is blocked (commands/rfkill.txt)"
        )
    else:
        analysis.append("- OK: Bluetooth radio is not blocked by rfkill")

    nmcli_devices = results.get(
        "nmcli_devices",
        CommandResult(255, ""),
    ).text.lower()
    if _contains_any(nmcli_devices, ["unavailable", "disconnected"]):
        analysis.append(
            "- WARN: at least one network interface is "
            "unavailable/disconnected "
            "(commands/nmcli_devices.txt)"
        )
    elif nmcli_devices.strip():
        analysis.append("- OK: nmcli device state captured")
    else:
        analysis.append("- WARN: nmcli device output missing")


def _append_routing_timeline(
    analysis: list[str],
    results: dict[str, CommandResult],
) -> None:
    """Append compact, ordered routing-related clues for fast triage."""
    analysis.append("Routing timeline (key clues):")

    timeline = _build_timeline_entries(results)
    if not timeline:
        analysis.append("- No routing-relevant timeline entries found")
        return

    for entry in timeline[:20]:
        analysis.append(f"- {entry}")


def _build_timeline_entries(
    results: dict[str, CommandResult],
) -> list[str]:
    """Build ordered timeline entries across logs and command snapshots."""
    timeline: list[str] = []

    timeline.extend(
        _extract_prefixed_matches(
            label="journal_core",
            text=results.get("journal_core", CommandResult(255, "")).text,
            markers=[
                "audiorouter",
                "audiohal",
                "pipewire",
                "pulse",
                "wireplumber",
                "route",
                "sink",
            ],
            limit=8,
        )
    )
    timeline.extend(
        _extract_prefixed_matches(
            label="journal_ui",
            text=results.get("journal_ui", CommandResult(255, "")).text,
            markers=["audiobridge", "pipewire", "pulse", "route", "sink"],
            limit=5,
        )
    )
    timeline.extend(
        _extract_prefixed_matches(
            label="journal_pipewire",
            text=results.get("journal_pipewire", CommandResult(255, "")).text,
            markers=["error", "failed", "warn", "link", "node"],
            limit=4,
        )
    )
    timeline.extend(
        _extract_prefixed_matches(
            label="journal_wireplumber",
            text=results.get(
                "journal_wireplumber",
                CommandResult(255, ""),
            ).text,
            markers=["error", "failed", "warn", "policy", "link"],
            limit=3,
        )
    )

    sink_inputs = _nonempty_lines(
        results.get("pactl_sink_inputs", CommandResult(255, "")).text
    )
    if sink_inputs:
        timeline.append(f"pactl_sink_inputs: {sink_inputs[0]}")

    pw_links = _nonempty_lines(
        results.get("pw_cli_links", CommandResult(255, "")).text
    )
    if pw_links:
        timeline.append(f"pw_cli_links: {pw_links[0]}")

    bt_show = _nonempty_lines(
        results.get("bluetoothctl_show", CommandResult(255, "")).text
    )
    if bt_show:
        timeline.append(f"bluetoothctl_show: {bt_show[0]}")

    return timeline


def _extract_prefixed_matches(
    label: str,
    text: str,
    markers: list[str],
    limit: int,
) -> list[str]:
    """Return prefixed log lines containing any marker, capped by limit."""
    entries: list[str] = []
    for line in text.splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        if _contains_any(stripped.lower(), markers):
            entries.append(f"{label}: {stripped}")
            if len(entries) >= limit:
                break
    return entries


def _contains_any(text: str, markers: list[str]) -> bool:
    """Return True if any marker is present in text."""
    return any(marker in text for marker in markers)


def _nonempty_lines(text: str) -> list[str]:
    """Return stripped non-empty lines from command output."""
    return [line.strip() for line in text.splitlines() if line.strip()]
