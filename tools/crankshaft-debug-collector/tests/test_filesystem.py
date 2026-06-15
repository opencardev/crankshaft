"""Tests for filesystem copy helpers."""

from __future__ import annotations

import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from crankshaft_debug_collector.filesystem import copy_candidates, safe_copy


class FilesystemCopyTests(unittest.TestCase):
    """Ensure candidate copy behavior is deterministic and safe."""

    def test_safe_copy_file_and_directory(self) -> None:
        """safe_copy should handle both file and directory sources."""
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            src_dir = root / "src"
            src_dir.mkdir()
            (src_dir / "config.ini").write_text("k=v\n", encoding="utf-8")

            dst_file = root / "out" / "config.ini"
            copied = safe_copy(str(src_dir / "config.ini"), dst_file)
            self.assertTrue(copied)
            self.assertEqual(dst_file.read_text(encoding="utf-8"), "k=v\n")

            dst_dir = root / "out" / "config-dir"
            copied_dir = safe_copy(str(src_dir), dst_dir)
            self.assertTrue(copied_dir)
            self.assertTrue((dst_dir / "config.ini").exists())

    def test_copy_candidates_only_returns_existing(self) -> None:
        """copy_candidates should skip missing paths without raising exceptions."""
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            output_root = root / "archive-root"

            mapped_src = root / "present.txt"
            mapped_src.write_text("hello\n", encoding="utf-8")

            posix_present = "/virtual/present.txt"
            posix_missing = "/virtual/missing.txt"

            def fake_safe_copy(source: str, target: Path) -> bool:
                if source == posix_present:
                    target.parent.mkdir(parents=True, exist_ok=True)
                    target.write_text(
                        mapped_src.read_text(encoding="utf-8"),
                        encoding="utf-8",
                    )
                    return True
                return False

            with patch(
                "crankshaft_debug_collector.filesystem.safe_copy",
                side_effect=fake_safe_copy,
            ):
                copied = copy_candidates(
                    [posix_present, posix_missing],
                    output_root,
                )

            self.assertEqual(copied, [posix_present])
            expected_target = output_root / posix_present.lstrip("/")
            self.assertTrue(expected_target.exists())
            self.assertEqual(
                expected_target.read_text(encoding="utf-8"),
                "hello\n",
            )


if __name__ == "__main__":
    unittest.main()
