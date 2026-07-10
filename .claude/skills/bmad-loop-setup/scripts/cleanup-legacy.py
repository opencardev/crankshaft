#!/usr/bin/env python3
# /// script
# requires-python = ">=3.9"
# dependencies = []
# ///
"""Remove redundant legacy skill-payload directories from _bmad/ after config migration.

Older BMAD installers could stage a module's skill payload *and* its config into
_bmad/<module>/ (and _bmad/core/), duplicating skills that also live in the CLI's
installed-skills tree (e.g. .claude/skills/ or .agents/skills/). This script
removes only those *redundant skill-payload* trees.

A directory is removed ONLY when it is a verified-redundant skill payload:
  * it contains >=1 SKILL.md, AND
  * it carries no live config/manifest files anywhere in its tree (config.yaml,
    module-help.csv, installer manifests, or a _config/ dir) — marker-named files
    inside a staged skill payload (under a SKILL.md-bearing dir) don't count, AND
  * when --skills-dir is given, every skill in it is verified installed there.

Everything else is left untouched. On a modern BMAD v6 install the per-module and
core directories hold only live config (no staged SKILL.md), and _bmad/_config/ is
the live installer manifest — so this script is a safe no-op there and never deletes
shared BMAD state. 'core' and '_config' are never removed: both are protected by
name regardless of contents. Every other removal decision is driven entirely by
directory contents, so no version check is needed.

Exit codes: 0=success (including nothing to remove), 1=validation error, 2=runtime error
"""

import argparse
import json
import shutil
import sys
from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser(
        description="Remove legacy module directories from _bmad/ after config migration."
    )
    parser.add_argument(
        "--bmad-dir",
        required=True,
        help="Path to the _bmad/ directory",
    )
    parser.add_argument(
        "--module-code",
        required=True,
        help="Module code being cleaned up (e.g. 'bmb')",
    )
    parser.add_argument(
        "--also-remove",
        action="append",
        default=[],
        help="Additional directory names under _bmad/ to remove (repeatable)",
    )
    parser.add_argument(
        "--skills-dir",
        help="Path to the CLI's installed-skills tree (.claude/skills/ for claude, "
        ".agents/skills/ for codex/gemini/copilot/antigravity) — enables safety "
        "verification that skills are installed before removing legacy copies",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Print detailed progress to stderr",
    )
    return parser.parse_args()


def find_skill_dirs(base_path: str) -> list:
    """Find directories that contain a SKILL.md file.

    Walks the directory tree and returns the leaf directory name for each
    directory containing a SKILL.md. These are considered skill directories.

    Returns:
        List of skill directory names (e.g. ['bmad-agent-builder', 'bmad-builder-setup'])
    """
    skills = []
    root = Path(base_path)
    if not root.exists():
        return skills
    for skill_md in root.rglob("SKILL.md"):
        skills.append(skill_md.parent.name)
    return sorted(set(skills))


# Markers that mean a directory holds LIVE BMAD config or installer-manifest
# state — never a disposable skill payload. Their presence protects the directory.
_CONFIG_MARKERS = ("config.yaml", "config.user.yaml", "module-help.csv", "manifest.yaml")


def _inside_skill_payload(item: Path, root: Path) -> bool:
    """True if item sits inside a staged skill-payload subtree of root.

    A dir at or above item — strictly below root — containing a SKILL.md marks a
    staged skill payload; marker-named files under it (e.g. a skill's own
    assets/module-help.csv) are payload data, not live state. root itself is
    excluded so markers at the candidate's top level always stay protective.
    """
    d = item.parent
    while d != root:
        if (d / "SKILL.md").exists():
            return True
        d = d.parent
    return False


def _is_config_marker(item: Path) -> bool:
    return (
        item.name in _CONFIG_MARKERS
        or item.name.endswith("-manifest.csv")
        or item.name == "bmad-help.csv"
    )


def is_config_bearing(path: Path) -> bool:
    """True if the directory holds live BMAD config or installer-manifest state.

    Such a directory (e.g. _bmad/core/, _bmad/<module>/, _bmad/_config/) is never a
    redundant skill payload and must not be removed. 'core' and '_config' are
    protected by name regardless of contents. Otherwise the whole tree is scanned
    for per-module/core config.yaml + module-help.csv, installer manifests
    (*-manifest.csv, manifest.yaml, bmad-help.csv), and nested _config/ dirs —
    skipping markers that belong to a staged skill payload (see
    _inside_skill_payload), which are disposable copies rather than live state.
    """
    if path.name in ("_config", "core"):
        return True
    for item in path.rglob("*"):
        if item.is_dir() and item.name == "_config":
            if not _inside_skill_payload(item, path):
                return True
        elif item.is_file() and _is_config_marker(item):
            if not _inside_skill_payload(item, path):
                return True
    return False


def classify_dirs(
    bmad_dir: str, dirs_to_check: list, skills_dir: str, verbose: bool = False
) -> tuple:
    """Partition requested directories into removable payloads vs protected.

    A directory is removable ONLY if it is a verified-redundant skill payload: it
    contains >=1 SKILL.md, carries no live config/manifest files, and — when
    skills_dir is given — every skill in it is verified installed there.

    Returns (removable, protected, not_found, verified_skills) where `protected` is a
    list of {"dir": name, "reason": ...}. Raises SystemExit(1) if a payload dir's
    skills are missing from skills_dir (the original safety contract).
    """
    removable: list = []
    protected: list = []
    not_found: list = []
    verified: list = []
    missing: list = []

    for dirname in dirs_to_check:
        target = Path(bmad_dir) / dirname
        if not target.exists() or not target.is_dir():
            not_found.append(dirname)
            if verbose:
                print(f"Not found (skipping): {target}", file=sys.stderr)
            continue

        if target.name in ("_config", "core"):
            protected.append({"dir": dirname, "reason": "live BMAD dir (protected by name)"})
            if verbose:
                print(f"Protected by name, not removing: {target}", file=sys.stderr)
            continue

        if is_config_bearing(target):
            protected.append({"dir": dirname, "reason": "holds live config/manifest"})
            if verbose:
                print(f"Protected (live config/manifest), not removing: {target}", file=sys.stderr)
            continue

        skill_names = find_skill_dirs(str(target))
        if not skill_names:
            protected.append({"dir": dirname, "reason": "no skill payload"})
            if verbose:
                print(f"No skill payload, not removing: {target}", file=sys.stderr)
            continue

        if skills_dir:
            dir_missing = [s for s in skill_names if not (Path(skills_dir) / s).is_dir()]
            if dir_missing:
                missing.extend(dir_missing)
                if verbose:
                    for s in dir_missing:
                        print(f"MISSING: {s} not found under {skills_dir}", file=sys.stderr)
                continue
            verified.extend(skill_names)

        removable.append(dirname)

    if missing:
        error_result = {
            "status": "error",
            "error": "Skills not found at installed location",
            "missing_skills": sorted(set(missing)),
            "skills_dir": str(Path(skills_dir).resolve()) if skills_dir else None,
        }
        print(json.dumps(error_result, indent=2))
        sys.exit(1)

    return removable, protected, not_found, sorted(set(verified))


def count_files(path: Path) -> int:
    """Count all files recursively in a directory."""
    count = 0
    for item in path.rglob("*"):
        if item.is_file():
            count += 1
    return count


def cleanup_directories(bmad_dir: str, dirs_to_remove: list, verbose: bool = False) -> tuple:
    """Remove specified directories under bmad_dir.

    Returns:
        (removed, not_found, total_files_removed) tuple
    """
    removed = []
    not_found = []
    total_files = 0

    for dirname in dirs_to_remove:
        target = Path(bmad_dir) / dirname
        if not target.exists():
            not_found.append(dirname)
            if verbose:
                print(f"Not found (skipping): {target}", file=sys.stderr)
            continue

        if not target.is_dir():
            if verbose:
                print(f"Not a directory (skipping): {target}", file=sys.stderr)
            not_found.append(dirname)
            continue

        file_count = count_files(target)
        if verbose:
            print(
                f"Removing {target} ({file_count} files)",
                file=sys.stderr,
            )

        try:
            shutil.rmtree(target)
        except OSError as e:
            error_result = {
                "status": "error",
                "error": f"Failed to remove {target}: {e}",
                "directories_removed": removed,
                "directories_failed": dirname,
            }
            print(json.dumps(error_result, indent=2))
            sys.exit(2)

        removed.append(dirname)
        total_files += file_count

    return removed, not_found, total_files


def reject_unresolved_paths(named_paths: list[tuple[str, str]]) -> None:
    """Exit with a clear error if any path argument still contains the literal
    ``{project-root}`` token. That token is meaningful only inside config
    values; filesystem path arguments must be resolved by the caller. Failing
    loudly here prevents silently operating on a junk ``{project-root}/`` directory.
    """
    for name, value in named_paths:
        if value and "{project-root}" in value:
            print(
                json.dumps(
                    {
                        "status": "error",
                        "error": (
                            f"Unresolved '{{project-root}}' token in {name} path: {value!r}. "
                            "Resolve '{project-root}' to the actual project root before running "
                            "this script — it is a filesystem path, not a config value."
                        ),
                    },
                    indent=2,
                )
            )
            sys.exit(1)


def main():
    args = parse_args()

    reject_unresolved_paths([("--bmad-dir", args.bmad_dir), ("--skills-dir", args.skills_dir)])

    bmad_dir = args.bmad_dir
    module_code = args.module_code

    # Candidate directories. 'core' is NEVER hardcoded here — it holds live core
    # config on BMAD v6, not a disposable payload. Only the module's own dir plus
    # any explicit --also-remove targets are considered, and each is still gated by
    # classify_dirs (verified-redundant skill payload, never config-bearing).
    dirs_to_check = [module_code] + args.also_remove
    # Deduplicate while preserving order
    seen = set()
    unique_dirs = []
    for d in dirs_to_check:
        if d not in seen:
            seen.add(d)
            unique_dirs.append(d)
    dirs_to_check = unique_dirs

    if args.verbose:
        print(f"Candidate directories: {dirs_to_check}", file=sys.stderr)

    # Classify: only verified-redundant skill payloads are removable; live
    # config/manifest dirs (core/, <module>/ config, _config/) are protected.
    removable, protected, not_found, verified_skills = classify_dirs(
        bmad_dir, dirs_to_check, args.skills_dir, args.verbose
    )

    # Remove only the verified-redundant payload directories. A removable dir can
    # vanish between classify_dirs() and here (TOCTOU) or a nested --also-remove
    # target can be removed with its parent earlier in this loop; surface those in
    # directories_not_found rather than silently dropping them.
    removed, removal_not_found, total_files = cleanup_directories(bmad_dir, removable, args.verbose)
    not_found = not_found + removal_not_found

    # Build result
    result = {
        "status": "success",
        "bmad_dir": str(Path(bmad_dir).resolve()),
        "directories_removed": removed,
        "directories_protected": protected,
        "directories_not_found": not_found,
        "files_removed_count": total_files,
    }

    if args.skills_dir:
        result["safety_checks"] = {
            "skills_verified": True,
            "skills_dir": str(Path(args.skills_dir).resolve()),
            "verified_skills": verified_skills,
        }
    else:
        result["safety_checks"] = None

    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
