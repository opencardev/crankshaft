"""Tests for report section rendering helpers in collector module."""

from __future__ import annotations

import unittest

from crankshaft_debug_collector.collector import _append_capture_sections


class CollectorSectionTests(unittest.TestCase):
    """Verify analysis section formatting for captured artifacts."""

    def test_append_capture_sections_with_and_without_paths(self) -> None:
        """Helper should render populated and empty sections predictably."""
        analysis = ["header"]
        _append_capture_sections(
            analysis=analysis,
            copied_configs=["/etc/crankshaft"],
            copied_service_configs=[],
            copied_logs=["/var/log/syslog"],
        )

        output = "\n".join(analysis)
        self.assertIn("Captured configuration artifacts:", output)
        self.assertIn("- Base config files/folders:", output)
        self.assertIn("  - /etc/crankshaft", output)
        self.assertIn("- Crankshaft service configs: none found", output)
        self.assertIn("Captured log artifacts:", output)
        self.assertIn("  - /var/log/syslog", output)


if __name__ == "__main__":
    unittest.main()
