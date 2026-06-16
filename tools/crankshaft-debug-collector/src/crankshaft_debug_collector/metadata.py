"""Collector metadata helpers.

This module captures provenance information so support bundles can be traced
back to a specific collector build and source revision.
"""

from __future__ import annotations

import datetime
import os
import subprocess
from importlib.metadata import PackageNotFoundError, version

from .types import CollectorMetadata


def _run_git(command: list[str]) -> str:
    """Run a git command and return trimmed stdout or empty string."""
    try:
        completed = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=2,
            check=False,
        )
    except OSError:
        return ""

    if completed.returncode != 0:
        return ""
    return completed.stdout.strip()


def _read_build_timestamp() -> str:
    """Resolve build timestamp from known environment variables."""
    explicit = os.getenv(
        "CRANKSHAFT_DEBUG_COLLECTOR_BUILD_TIMESTAMP",
        "",
    ).strip()
    if explicit:
        return explicit

    source_date_epoch = os.getenv("SOURCE_DATE_EPOCH", "").strip()
    if source_date_epoch:
        try:
            epoch = int(source_date_epoch)
            return datetime.datetime.fromtimestamp(
                epoch,
                tz=datetime.UTC,
            ).isoformat()
        except ValueError:
            pass

    return "unknown"


def _read_version() -> str:
    """Resolve collector package version, preferring explicit override."""
    explicit = os.getenv("CRANKSHAFT_DEBUG_COLLECTOR_VERSION", "").strip()
    if explicit:
        return explicit

    try:
        return version("crankshaft-debug-collector")
    except PackageNotFoundError:
        return "0.0.0+unknown"


def build_metadata() -> CollectorMetadata:
    """Build deterministic metadata describing collector build provenance."""
    collected_at = datetime.datetime.now(tz=datetime.UTC).isoformat()

    git_commit = os.getenv("CRANKSHAFT_DEBUG_COLLECTOR_GIT_COMMIT", "").strip()
    git_branch = os.getenv("CRANKSHAFT_DEBUG_COLLECTOR_GIT_BRANCH", "").strip()
    git_tag = os.getenv("CRANKSHAFT_DEBUG_COLLECTOR_GIT_TAG", "").strip()

    if not git_commit:
        git_commit = _run_git(["git", "rev-parse", "HEAD"])
    if not git_branch:
        git_branch = _run_git(["git", "rev-parse", "--abbrev-ref", "HEAD"])
    if not git_tag:
        git_tag = _run_git(["git", "describe", "--tags", "--exact-match"])

    dirty_flag = os.getenv(
        "CRANKSHAFT_DEBUG_COLLECTOR_GIT_DIRTY",
        "",
    ).strip().lower()
    if dirty_flag in {"true", "false"}:
        git_dirty = dirty_flag
    else:
        status = _run_git(["git", "status", "--porcelain"])
        if status == "":
            git_dirty = "unknown"
        else:
            git_dirty = "true"

    return CollectorMetadata(
        collector_version=_read_version(),
        collected_at_utc=collected_at,
        build_timestamp_utc=_read_build_timestamp(),
        git_commit=git_commit or "unknown",
        git_branch=git_branch or "unknown",
        git_tag=git_tag or "unknown",
        git_dirty=git_dirty,
    )
