"""Tests for analysis output behavior."""

from __future__ import annotations

import unittest
from pathlib import Path
from unittest.mock import patch

from crankshaft_debug_collector.analysis import build_analysis
from crankshaft_debug_collector.types import CommandResult


class BuildAnalysisTests(unittest.TestCase):
    """Validate service/package/report logic in analysis builder."""

    def test_build_analysis_reports_expected_service_states(self) -> None:
        """Service statuses should map to OK/FAIL/WARN markers consistently."""
        results = {
            "crankshaft_core_status": CommandResult(
                exit_code=0,
                text="Active: active (running)",
            ),
            "crankshaft_ui_status": CommandResult(
                exit_code=3,
                text="Loaded: loaded\nActive: inactive (dead)",
            ),
            "crankshaft_display_setup_status": CommandResult(
                exit_code=4,
                text="Loaded: not-found (Reason: No such file)",
            ),
            "bluetooth_status": CommandResult(
                exit_code=0,
                text="Active: active (exited)",
            ),
            "dpkg_core": CommandResult(
                exit_code=0,
                text=(
                    "ii  crankshaft-core 1.0\n"
                    "ii  crankshaft-ui-slim 1.0\n"
                ),
            ),
            "dpkg_aasdk": CommandResult(
                exit_code=0,
                text="ii  libaasdk 1.0\n",
            ),
            "journal_core": CommandResult(exit_code=0, text="usb timeout error"),
            "journal_boot": CommandResult(exit_code=0, text="android auto failed"),
            "dmesg": CommandResult(exit_code=0, text="aasdk error"),
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
        self.assertIn("- OK: crankshaft-core is active", output)
        self.assertIn(
            "- WARN: crankshaft-ui-slim inactive.",
            output,
        )
        self.assertIn(
            "- FAIL: crankshaft-ui-slim-display-setup service file not found",
            output,
        )
        self.assertIn("- OK: bluetooth is active", output)
        self.assertIn("- OK: crankshaft-core installed", output)
        self.assertIn("- OK: crankshaft-ui-slim installed", output)
        self.assertIn("- OK: libaasdk installed", output)
        self.assertIn("- OK: OpenCarDev apt repo configured", output)
        self.assertIn("- usb: 1 matches", output)
        self.assertIn("- android auto: 1 matches", output)


if __name__ == "__main__":
    unittest.main()
