# Architecture: Crankshaft Debug Collector

## Goals

- Keep the collector easy to extend without large risky edits.
- Keep artifact capture policy explicit and reviewable.
- Keep output stable for support workflows.

## Module responsibilities

- `constants.py`
  - Defines command specs and filesystem capture candidates.
  - Defines expected packages and error marker keywords.
- `commands.py`
  - Runs commands and writes command transcript files.
- `filesystem.py`
  - Copies files/directories while preserving source layout.
- `analysis.py`
  - Builds human-readable checks for services, packages, repo config, and logs.
- `collector.py`
  - Orchestrates capture folders, collection calls, analysis, and tar archive.
- `cli.py`
  - CLI parser and execution output.

## Data flow

1. `cli.main()` parses args.
2. `collector.collect()` creates output folders.
3. `commands.collect_commands()` executes diagnostics.
4. `filesystem.copy_candidates()` copies config/service/log artifacts.
5. `analysis.build_analysis()` builds quick triage summary.
6. `collector.collect()` writes analysis and tarball.

## Operational notes

- Missing files are not treated as fatal; they are skipped and reported.
- Command failures are captured in per-command text files for root-cause analysis.
- Archive structure is deterministic: `commands/`, `config/`, `logs/`, `analysis.txt`.

## Extending the collector

- Add new command checks in `constants.COMMAND_SPECS`.
- Add newly relevant config paths to `CONFIG_CANDIDATES`.
- Add service unit/drop-in paths to `SERVICE_CONFIG_CANDIDATES`.
- Add logs to `LOG_CANDIDATES`.
- Keep cross-module logic minimal; prefer adding helper functions near ownership.
