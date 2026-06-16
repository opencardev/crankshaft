"""Tests for report section rendering helpers in collector module."""

from __future__ import annotations

import unittest
from pathlib import Path

from crankshaft_debug_collector.collector import (
    _append_capture_sections,
    _append_metadata_section,
)
from crankshaft_debug_collector.types import CollectorMetadata


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

    def test_append_metadata_section_renders_provenance(self) -> None:
        """Metadata section should contain all expected provenance fields."""
        analysis: list[str] = []
        metadata = CollectorMetadata(
            collector_version="0.1.0",
            collected_at_utc="2026-06-16T12:00:00+00:00",
            build_timestamp_utc="2026-06-15T23:00:00+00:00",
            git_commit="deadbeef",
            git_branch="develop",
            git_tag="v0.1.0",
            git_dirty="false",
        )

        _append_metadata_section(
            analysis=analysis,
            metadata=metadata,
            metadata_path=Path(
                "/tmp/crankshaft-debug/collector_metadata.json"
            ),
        )

        output = "\n".join(analysis)
        self.assertIn("Collector metadata:", output)
        self.assertIn("- metadata file: collector_metadata.json", output)
        self.assertIn("- collector version: 0.1.0", output)
        self.assertIn("- git commit: deadbeef", output)
        self.assertIn("- git branch: develop", output)


if __name__ == "__main__":
    unittest.main()
