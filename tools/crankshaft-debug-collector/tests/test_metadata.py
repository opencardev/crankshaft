"""Tests for collector metadata generation."""

from __future__ import annotations

import unittest
from unittest.mock import patch

from crankshaft_debug_collector.metadata import build_metadata


class MetadataTests(unittest.TestCase):
    """Validate collector provenance metadata generation."""

    @patch.dict(
        "os.environ",
        {
            "CRANKSHAFT_DEBUG_COLLECTOR_VERSION": "1.2.3",
            "CRANKSHAFT_DEBUG_COLLECTOR_BUILD_TIMESTAMP": (
                "2026-06-16T00:00:00+00:00"
            ),
            "CRANKSHAFT_DEBUG_COLLECTOR_GIT_COMMIT": "abc123",
            "CRANKSHAFT_DEBUG_COLLECTOR_GIT_BRANCH": "main",
            "CRANKSHAFT_DEBUG_COLLECTOR_GIT_TAG": "v1.2.3",
            "CRANKSHAFT_DEBUG_COLLECTOR_GIT_DIRTY": "false",
        },
        clear=True,
    )
    def test_build_metadata_prefers_explicit_env(self) -> None:
        """Environment overrides should provide deterministic metadata."""
        metadata = build_metadata()
        self.assertEqual(metadata.collector_version, "1.2.3")
        self.assertEqual(
            metadata.build_timestamp_utc,
            "2026-06-16T00:00:00+00:00",
        )
        self.assertEqual(metadata.git_commit, "abc123")
        self.assertEqual(metadata.git_branch, "main")
        self.assertEqual(metadata.git_tag, "v1.2.3")
        self.assertEqual(metadata.git_dirty, "false")

    @patch.dict("os.environ", {}, clear=True)
    @patch("crankshaft_debug_collector.metadata._run_git")
    @patch("crankshaft_debug_collector.metadata.version")
    def test_build_metadata_falls_back_to_git_and_package_version(
        self,
        mock_version,
        mock_run_git,
    ) -> None:
        """When env is not provided, package/git probes should be used."""
        mock_version.return_value = "0.1.0"

        def git_side_effect(command: list[str]) -> str:
            if command[:3] == ["git", "rev-parse", "HEAD"]:
                return "deadbeef"
            if command[:4] == ["git", "rev-parse", "--abbrev-ref", "HEAD"]:
                return "develop"
            if command[:3] == ["git", "describe", "--tags"]:
                return "v0.1.0"
            if command[:3] == ["git", "status", "--porcelain"]:
                return " M file.txt"
            return ""

        mock_run_git.side_effect = git_side_effect

        metadata = build_metadata()
        self.assertEqual(metadata.collector_version, "0.1.0")
        self.assertEqual(metadata.git_commit, "deadbeef")
        self.assertEqual(metadata.git_branch, "develop")
        self.assertEqual(metadata.git_tag, "v0.1.0")
        self.assertEqual(metadata.git_dirty, "true")


if __name__ == "__main__":
    unittest.main()
