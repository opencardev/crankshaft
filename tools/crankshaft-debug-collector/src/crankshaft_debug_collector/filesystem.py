"""Filesystem helpers for safe, repeatable artifact collection."""

from __future__ import annotations

import shutil
from pathlib import Path


def safe_copy(src: str, dst: Path) -> bool:
    """Copy a file or directory if it exists.

    Returns False when the source does not exist. This keeps collection logic
    simple: callers provide candidate lists and do not need try/except around
    missing paths.
    """
    src_path = Path(src)
    if not src_path.exists():
        return False

    dst.parent.mkdir(parents=True, exist_ok=True)
    if src_path.is_dir():
        if dst.exists():
            shutil.rmtree(dst)
        shutil.copytree(src_path, dst)
    else:
        shutil.copy2(src_path, dst)

    return True


def copy_candidates(candidates: list[str], output_root: Path) -> list[str]:
    """Copy existing candidates into output_root preserving absolute layout."""
    copied: list[str] = []
    for source in candidates:
        target = output_root / source.lstrip("/")
        if safe_copy(source, target):
            copied.append(source)
    return copied
