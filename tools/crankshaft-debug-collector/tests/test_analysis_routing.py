"""Tests for audio/bluetooth/wireless routing heuristics in analysis output."""

from __future__ import annotations

import unittest
from pathlib import Path
from unittest.mock import patch

from crankshaft_debug_collector.analysis import build_analysis
from crankshaft_debug_collector.types import CommandResult


class RoutingHeuristicsTests(unittest.TestCase):
    """Validate first-pass routing heuristics emitted by analysis builder."""

    def test_routing_heuristics_report_ok_states(self) -> None:
        """Healthy command outputs should produce mostly OK routing checks."""
        results = {
            "audio_status": CommandResult(0, "pipewire.service wireplumber"),
            "audio_sockets": CommandResult(0, "pipewire-0 pulse/native"),
            "pactl_info": CommandResult(
                0,
                "Server String: /run/user/1000/pulse/native",
            ),
            "pactl_sinks": CommandResult(0, "0\talsa_output\tmodule\t..."),
            "pactl_sink_inputs": CommandResult(
                0,
                "22\t0\t31\tprotocol-native.c",
            ),
            "pw_cli_links": CommandResult(
                0,
                "id 10, type PipeWire:Interface:Link/3",
            ),
            "journal_core": CommandResult(0, "[AudioRouter] routed stream"),
            "journal_ui": CommandResult(0, "[AudioBridge] sink selected"),
            "journal_pipewire": CommandResult(0, "pipewire: node linked"),
            "journal_wireplumber": CommandResult(
                0,
                "wireplumber: policy link created",
            ),
            "bluetoothctl_show": CommandResult(0, "Controller AA:BB:CC"),
            "rfkill": CommandResult(
                0,
                "0: hci0: Bluetooth\n\tSoft blocked: no\n\tHard blocked: no",
            ),
            "nmcli_devices": CommandResult(
                0,
                "DEVICE TYPE STATE CONNECTION\n"
                "wlan0 wifi connected home",
            ),
            "dpkg_core": CommandResult(0, "ii crankshaft-core 1.0"),
            "dpkg_aasdk": CommandResult(0, "ii libaasdk 1.0"),
        }

        with patch(
            "crankshaft_debug_collector.analysis.check_repo_present",
            return_value=True,
        ), patch(
            "crankshaft_debug_collector.analysis.is_unprivileged_user",
            return_value=False,
        ):
            lines = build_analysis(results=results, work_dir=Path("/tmp/test"))

        output = "\n".join(lines)
        self.assertIn("Audio/Bluetooth/Wireless routing heuristics:", output)
        self.assertIn("Routing timeline (key clues):", output)
        self.assertIn(
            "- OK: audio service processes reported by systemd",
            output,
        )
        self.assertIn("- OK: PipeWire and Pulse sockets are visible", output)
        self.assertIn("- OK: pactl can query the active server", output)
        self.assertIn("- OK: 1 sink(s) reported", output)
        self.assertIn(
            "- OK: AudioRouter activity correlates with active sink inputs",
            output,
        )
        self.assertIn("- journal_core: [AudioRouter] routed stream", output)
        self.assertIn(
            "- pactl_sink_inputs: 22\t0\t31\tprotocol-native.c",
            output,
        )
        self.assertIn(
            "- pw_cli_links: id 10, type PipeWire:Interface:Link/3",
            output,
        )
        self.assertIn("- OK: Bluetooth radio is not blocked by rfkill", output)

    def test_routing_heuristics_flag_failures(self) -> None:
        """Failure-shaped outputs should be surfaced as FAIL/WARN hints."""
        results = {
            "audio_status": CommandResult(0, ""),
            "audio_sockets": CommandResult(0, ""),
            "pactl_info": CommandResult(1, "Connection failure: refused"),
            "pactl_sinks": CommandResult(0, ""),
            "pactl_sink_inputs": CommandResult(0, ""),
            "pw_cli_links": CommandResult(0, ""),
            "journal_core": CommandResult(0, "[AudioRouter] route failed"),
            "journal_ui": CommandResult(0, ""),
            "journal_pipewire": CommandResult(0, ""),
            "journal_wireplumber": CommandResult(0, ""),
            "bluetoothctl_show": CommandResult(0, ""),
            "rfkill": CommandResult(
                0,
                "0: hci0: Bluetooth\n\tSoft blocked: yes\n\tHard blocked: no",
            ),
            "nmcli_devices": CommandResult(0, "wlan0 wifi disconnected --"),
            "dpkg_core": CommandResult(0, "ii crankshaft-core 1.0"),
            "dpkg_aasdk": CommandResult(0, "ii libaasdk 1.0"),
        }

        with patch(
            "crankshaft_debug_collector.analysis.check_repo_present",
            return_value=True,
        ), patch(
            "crankshaft_debug_collector.analysis.is_unprivileged_user",
            return_value=False,
        ):
            lines = build_analysis(results=results, work_dir=Path("/tmp/test"))

        output = "\n".join(lines)
        self.assertIn(
            "- FAIL: no PipeWire/Pulse/WirePlumber services detected",
            output,
        )
        self.assertIn("- FAIL: no PipeWire/Pulse sockets detected", output)
        self.assertIn(
            "- FAIL: pactl cannot reach Pulse/PipeWire endpoint",
            output,
        )
        self.assertIn("- FAIL: no Pulse/PipeWire sinks reported", output)
        self.assertIn(
            "- FAIL: AudioRouter activity found but no active sink inputs",
            output,
        )
        self.assertIn("- FAIL: Bluetooth radio is blocked", output)
        self.assertIn(
            "- WARN: at least one network interface is "
            "unavailable/disconnected",
            output,
        )

    def test_routing_timeline_empty_when_no_inputs(self) -> None:
        """Timeline section should render explicit empty state."""
        results = {
            "dpkg_core": CommandResult(0, "ii crankshaft-core 1.0"),
            "dpkg_aasdk": CommandResult(0, "ii libaasdk 1.0"),
        }

        with patch(
            "crankshaft_debug_collector.analysis.check_repo_present",
            return_value=True,
        ), patch(
            "crankshaft_debug_collector.analysis.is_unprivileged_user",
            return_value=False,
        ):
            lines = build_analysis(results=results, work_dir=Path("/tmp/test"))

        output = "\n".join(lines)
        self.assertIn("Routing timeline (key clues):", output)
        self.assertIn("- No routing-relevant timeline entries found", output)


if __name__ == "__main__":
    unittest.main()
