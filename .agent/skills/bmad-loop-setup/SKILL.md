---
name: 'bmad-loop-setup'
description: Sets up BMAD Loop Skills module in a project. Use when the user requests to 'install bmad-loop module', 'configure BMAD Loop Skills', or 'setup BMAD Loop Skills'.
---

# Module Setup

## Overview

Installs, configures, **and upgrades** a BMad module in a project. This module is special: alongside the four automation skills it relies on the **bmad-loop orchestrator tool** (the Python program that drives the loop), installed as the `bmad-loop` package from its public Git repository. So setup does two jobs — (1) register module config + help entries, and (2) install **or upgrade** the orchestrator tool and bootstrap the project so it is ready to run.

The same skill handles both first-time setup and **upgrades**. When it detects an existing bmad-loop install (or you ask it to `upgrade`), it upgrades the orchestrator tool, refreshes the per-project `bmad-loop-*` skill copies, and re-stamps config — the two-step upgrade ritual, run for you. A plain re-run on an already-installed project is treated as an upgrade.

Module identity (name, code, version) comes from `./assets/module.yaml`. Collects user preferences and writes them to three files:

- **`{project-root}/_bmad/config.yaml`** — shared project config: core settings at root (e.g. `output_folder`, `document_output_language`) plus a section per module with metadata and module-specific values. User-only keys (`user_name`, `communication_language`) are **never** written here.
- **`{project-root}/_bmad/config.user.yaml`** — personal settings intended to be gitignored: `user_name`, `communication_language`, and any module variable marked `user_setting: true` in `./assets/module.yaml`. These values live exclusively here.
- **`{project-root}/_bmad/module-help.csv`** — registers module capabilities for the help system.

Both config scripts use an anti-zombie pattern — existing entries for this module are removed before writing fresh ones, so stale values never persist.

`{project-root}` is a **literal token** in config _values_ (the data written into the files above) — never substitute it there. It signals to the consuming LLM that the value is relative to the project root, not the skill root. **This does not apply to the filesystem path _arguments_ passed to the scripts below** (the `--*-path`, `--*-dir`, and `--target` arguments): those are real paths, so you **must** resolve `{project-root}` to the actual project root before running, or the scripts will write to a literal `{project-root}/` directory under the skill folder. The scripts reject an unresolved token with an error.

## On Activation

1. Read `./assets/module.yaml` for module metadata and variable definitions (the `code` field is the module identifier)
2. Check if `{project-root}/_bmad/config.yaml` exists — if a section matching the module's code is already present, inform the user this is an update
3. Check for per-module configuration at `{project-root}/_bmad/bmad-loop/config.yaml` and `{project-root}/_bmad/core/config.yaml`. If either file exists:
   - If `{project-root}/_bmad/config.yaml` does **not** yet have a section for this module: this is a **fresh install**. Inform the user that installer config was detected and values will be consolidated into the new format.
   - If `{project-root}/_bmad/config.yaml` **already** has a section for this module: this is a **legacy migration**. Inform the user that legacy per-module config was found alongside existing config, and legacy values will be used as fallback defaults.
   - In both cases, per-module config files and directories will be cleaned up after setup.

**Decide fresh-install vs upgrade.** This drives whether the tool is upgraded and whether the per-project skills are refreshed (see "Install the Orchestrator Tool" below). Treat it as an **upgrade** when **any** of these hold:

- The user asked for one in their arguments — `upgrade`, `update`, `upgrade tool and skills`, or similar.
- `{project-root}/_bmad/config.yaml` already has a `bmad-loop` section (step 2 above).
- The orchestrator tool is already installed under uv: run `uv tool list` and look for a `bmad-loop` entry. (A bare `bmad-loop --version` is **not** sufficient on its own — it can be satisfied by a source checkout or unrelated virtualenv; see step 1 of "Install the Orchestrator Tool".)
- **A pre-rename install is present** — the project (or the machine) is on the old `bmad-auto`. Two tells: `{project-root}/_bmad/config.yaml` has a legacy `bauto` section, or `uv tool list` shows a `bmad-auto` entry (the tool's former name). Treat this as an **upgrade from bmad-auto (renamed to bmad-loop)** and follow "Migrating from bmad-auto (renamed)" below in addition to the normal upgrade path.

Otherwise it is a **fresh install**. State the decision to the user before proceeding — e.g. "Detected an existing bmad-loop install — running an upgrade: tool + skills + config" or "No existing install detected — running a fresh setup". When the signals conflict (e.g. config has a `bmad-loop` section but the tool isn't uv-managed), prefer the upgrade path for whatever **is** present and call out what's missing.

If the user provides arguments (e.g. `accept all defaults`, `--headless`, `upgrade`, or inline values like `user name is BMad, I speak Swahili`), map any provided values to config keys, use defaults for the rest, and skip interactive prompting. Still display the full confirmation summary at the end.

## Migrating from bmad-auto (renamed)

Only when you detected a **pre-rename install** ("Decide fresh-install vs upgrade" above). The project was set up under the tool's former name, `bmad-auto`. The rename was a clean break — module code `bauto` → `bmad-loop`, tool package `bmad-auto` → `bmad-loop`, state dir `.automator/` → `.bmad-loop/` — with no compatibility shims, so a few steps below need explicit handling. Do these as part of the normal upgrade:

1. **Carry old config defaults over.** `merge-config.py --legacy-dir` reads `_bmad/bmad-loop/` (the new code), so it won't find the old `bauto` config on its own. Before collecting values, read the legacy `bauto:` section from `{project-root}/_bmad/config.yaml` (and, if present, the old installer file `{project-root}/_bmad/bauto/config.yaml`) and fold any keys that still match the current `module.yaml` schema into your defaults. Priority: existing `bmad-loop` values > legacy `bauto` section > legacy `_bmad/bauto/config.yaml` > `module.yaml` defaults.
2. **Reinstall the tool under its new name** — uv can't rename a package in place, so this is an uninstall + install, not an upgrade. See the renamed-tool note in "Install the Orchestrator Tool" step 2.
3. **Run `bmad-loop init`** as usual. It handles the on-disk migration for you: strips the old `.automator/` Stop hook from each CLI's settings, removes the `bmad-auto-*` skill dirs, and carries `.automator/policy.toml` over to `.bmad-loop/policy.toml` — leaving the rest of `.automator/` (runs, archives, profiles, plugins) in place for you to delete once satisfied.
4. **Post-merge cleanup** — the anti-zombie merges key on the **new** names, so old rows and sections survive and need explicit removal:
   - Delete the leftover `bauto:` section from `{project-root}/_bmad/config.yaml`, plus any `bauto`-marked keys in `{project-root}/_bmad/config.user.yaml`.
   - Delete rows from `{project-root}/_bmad/module-help.csv` whose module column (column 1) reads `BMAD Automator Skills` — `merge-help-csv.py`'s anti-zombie filter keys on the new `BMAD Loop Skills`, so it leaves the old-named rows behind.
   - The legacy installer dir `_bmad/bauto/` is removed by the cleanup step's `--also-remove bauto` (see "Cleanup Legacy Directories").

Then continue with the normal flow below.

## Collect Configuration

Ask the user for values. Show defaults in brackets. Present all values together so the user can respond once with only the values they want to change (e.g. "change language to Swahili, rest are fine"). Never tell the user to "press enter" or "leave blank" — in a chat interface they must type something to respond.

**Default priority** (highest wins): existing new config values > legacy config values > `./assets/module.yaml` defaults. When legacy configs exist, read them and use matching values as defaults instead of `module.yaml` defaults. Only keys that match the current schema are carried forward — changed or removed keys are ignored. On a **rename-upgrade from bmad-auto**, the old `bauto` section (in `_bmad/config.yaml`) and any `_bmad/bauto/config.yaml` installer file slot in below existing `bmad-loop` values and above `module.yaml` defaults — you read them yourself (see "Migrating from bmad-auto (renamed)"), since merge-config's `--legacy-dir` only looks under the new code.

**Core config** (only if no core keys exist yet): `user_name` (default: BMad), `communication_language` and `document_output_language` (default: English — ask as a single language question, both keys get the same answer), `output_folder` (default: `{project-root}/_bmad-output`). Of these, `user_name` and `communication_language` are written exclusively to `config.user.yaml`. The rest go to `config.yaml` at root and are shared across all modules.

**Module config**: Read each variable in `./assets/module.yaml` that has a `prompt` field. Ask using that prompt with its default value (or legacy value if available).

## Write Files

Write a temp JSON file with the collected answers structured as `{"core": {...}, "module": {...}}` (omit `core` if it already exists). Values inside this JSON keep the literal `{project-root}` token. Then run both scripts — they can run in parallel since they write to different files.

In the commands below, replace `{project-root}` in every path argument with the actual project root (e.g. `/home/me/myapp`) before running — these are filesystem paths, not config values.

```bash
python3 ./scripts/merge-config.py --config-path "{project-root}/_bmad/config.yaml" --user-config-path "{project-root}/_bmad/config.user.yaml" --module-yaml ./assets/module.yaml --answers {temp-file} --legacy-dir "{project-root}/_bmad"
python3 ./scripts/merge-help-csv.py --target "{project-root}/_bmad/module-help.csv" --source ./assets/module-help.csv --legacy-dir "{project-root}/_bmad" --module-code bmad-loop
```

Both scripts output JSON to stdout with results. If either exits non-zero, surface the error and stop. The scripts automatically read legacy config values as fallback defaults, then delete the legacy files after a successful merge. Check `legacy_configs_deleted` and `legacy_csvs_deleted` in the output to confirm cleanup.

Run `./scripts/merge-config.py --help` or `./scripts/merge-help-csv.py --help` for full usage.

## Create Output Directories

After writing config, create any output directories that were configured. For filesystem operations only (such as creating directories), resolve the `{project-root}` token to the actual project root and create each path-type value from `config.yaml` that does not yet exist — this includes `output_folder` and any module variable whose value starts with `{project-root}/`. The paths stored in the config files must continue to use the literal `{project-root}` token; only the directories on disk should use the resolved paths. Use `mkdir -p` or equivalent to create the full path.

## Install the Orchestrator Tool

This module ships the **bmad-loop orchestrator** — the Python program that actually drives the loop — as the `bmad-loop` Python package, installed from its public Git repository. The skills do nothing on their own: the orchestrator is what spawns fresh coding CLI sessions through the selected adapter(s) to invoke `bmad-dev-auto` (the upstream dev primitive) for the dev pass — then re-invokes it on the `done` spec for the follow-up review pass — and `bmad-loop-sweep`, watches their hook signals, and verifies their artifacts. Installing the tool is therefore part of setup, not an optional extra.

> **Why is the tool installed from Git?** The BMAD installer copies only the skill directories into a project — it does **not** carry sibling files, so the tool can't ride along in the skill folder; it's installed from Git instead. The canonical source is <https://github.com/bmad-code-org/bmad-loop>. (The reverse holds, though: the tool's wheel **bundles** the skills, so `bmad-loop init` lays them down into a project's skill trees on its own — see step 3.)

Unless the user explicitly asked to skip it (e.g. `skills only` / `--no-tool`), install **or upgrade** and bootstrap now. Which branch you take in step 2 follows the fresh-install-vs-upgrade decision from "On Activation". In the commands below, resolve `{project-root}` to the real project path before running.

1. **Check what's already on PATH:** run `bmad-loop --version`. A version printing here does **not** mean this project is set up — it only means _some_ `bmad-loop` is importable in the current environment. Before trusting it, run `uv tool list` and look for `bmad-loop`: if it's absent (the on-PATH copy comes from a source checkout or an unrelated virtualenv), warn the user that the active environment is shadowing a clean install and that the project would be relying on that checkout. Unless the user explicitly declines, install/upgrade from the canonical source below so the project doesn't depend on an incidental dev environment. Only skip the install if the user confirms the on-PATH copy is the one they want this project to use.

2. **Install or upgrade from the Git repository** (the `[tui]` extra pulls in the Textual dashboard so `bmad-loop tui` works). `uv tool install` puts `bmad-loop` in uv's own managed environment, so there's no PEP 668 externally-managed conflict and no need for `--user`, an activated virtualenv, or `--break-system-packages`.

   - **Renamed from bmad-auto** (`uv tool list` shows `bmad-auto`, not `bmad-loop`): uv can't rename a package in place, so `uv tool upgrade` won't move you across the rename. Record `bmad-auto --version` first (for the delta), then uninstall the old tool and install the new one fresh:

     ```bash
     uv tool uninstall bmad-auto
     uv tool install "bmad-loop[tui] @ git+https://github.com/bmad-code-org/bmad-loop.git"
     ```

     After this the machine is on `bmad-loop`; later runs follow the plain upgrade path below.

   - **Fresh install** (no uv-managed `bmad-loop`):

     ```bash
     uv tool install "bmad-loop[tui] @ git+https://github.com/bmad-code-org/bmad-loop.git"
     ```

     Pin a release tag for reproducibility by appending `@v<X.Y.Z>` to the Git URL.

   - **Upgrade** (uv already manages `bmad-loop`, per the "On Activation" decision):

     1. Record the current version first so you can report the delta: `bmad-loop --version`.
     2. Default — follow `main` (or the currently pinned tag):

        ```bash
        uv tool upgrade bmad-loop --reinstall
        ```

        The `--reinstall` is **required** for a Git source: a plain `uv tool upgrade` reuses the cached commit and won't pull new code. Then **offer to pin a release tag** for reproducibility — if the user wants a specific version, move to it with:

        ```bash
        uv tool install --force "bmad-loop[tui] @ git+https://github.com/bmad-code-org/bmad-loop.git@v<X.Y.Z>"
        ```

     3. Re-run `bmad-loop --version` and note the before → after for the confirmation step.

3. **Bootstrap the project** — install the coding-CLI hooks, the bundled `bmad-loop-*` skills, the `.bmad-loop/policy.toml` template, and the gitignore entry (idempotent).

   First decide **which coding CLI(s)** the orchestrator should drive. The three supported adapters are `claude` (default), `codex`, and `gemini`. Hooks are registered per CLI, so the choice matters — register every CLI you intend to use for dev/review/triage. Ask the user (unless they already specified it in their setup args, e.g. `cli: claude, codex`, or accepted defaults — then default to `claude` only):

   > "Which coding CLI(s) should the orchestrator drive — `claude`, `codex`, and/or `gemini`? You can pick more than one. [claude]"

   Build the command with one `--cli <name>` per selected CLI (the flag is repeatable). **On an upgrade, append `--force-skills`** so the per-project skill copies are actually refreshed — without it `init` skips every existing skill dir and the project keeps stale skills against the upgraded tool. On a fresh install, omit it.

   ```bash
   # fresh install, claude only (default)
   bmad-loop init --project "{project-root}" --cli claude

   # fresh install, multiple, e.g. claude + codex + gemini
   bmad-loop init --project "{project-root}" --cli claude --cli codex --cli gemini

   # upgrade — refresh the bundled skills in place
   bmad-loop init --project "{project-root}" --cli claude --force-skills
   ```

   Names must be exactly `claude`, `codex`, or `gemini` — `init` errors on an unknown profile and lists the valid ones. `init` prints any one-time first-run notes per CLI (e.g. start `claude` once in the project and accept the workspace-trust + hooks-approval dialogs before `bmad-loop run` — spawned sessions can't answer first-run dialogs). Relay those notes to the user.

   **Skills are installed automatically:** `init` lays the bundled `bmad-loop-*` skills into the right tree for each selected CLI — `.claude/skills/` for `claude`, `.agents/skills/` for `codex`/`gemini`. On a fresh install, existing skill dirs are left untouched; on an upgrade, `--force-skills` overwrites them with the bundled copies from the upgraded tool (use `--no-skills` to skip the step and manage skills yourself).

   > **Note:** `--force-skills` also overwrites `bmad-loop-setup` itself (it ships in the same bundle). That's expected and safe — the freshly laid-down setup skill takes effect on the **next** invocation, and your `_bmad/custom/*.toml` overrides (keyed by skill directory name) are untouched.

4. **Preflight** — verify config, sprint-status, git, tmux, and the coding CLI:

   ```bash
   bmad-loop validate --project "{project-root}"
   ```

   `validate` exits non-zero when the project isn't fully ready (e.g. no `sprint-status.yaml` yet, or `bmad-sprint-planning` hasn't run). On a fresh project that is **expected** — report its findings to the user as a readiness checklist, not as an install failure.

5. **Point the user at per-role adapter config.** `--cli` in step 3 only registers _hooks_ for each CLI. Which CLI actually **runs** each stage is governed by `{project-root}/.bmad-loop/policy.toml`, written from a template by `init`. The `[adapter] name` (default `claude`) applies to every stage; optional `[adapter.dev]`, `[adapter.review]`, and `[adapter.triage]` tables override individual stages (each takes its own `name` and `extra_args`). So a mixed setup — e.g. `claude` for dev, `codex` for review — needs both the hooks registered (step 3) **and** the role pointed at that CLI in `policy.toml`:

   ```toml
   [adapter]
   name = "claude"        # default for all stages

   [adapter.review]
   name = "codex"         # review runs on codex instead
   ```

   Tell the user where the file is and that any CLI named in `policy.toml` must also have been registered with `--cli` in step 3 (re-run `bmad-loop init --cli <name>` to add one later). Leave `policy.toml` untouched if they only use a single CLI — the default is correct.

## Cleanup Legacy Directories

After both merge scripts complete successfully, remove the installer's package directories. Skills and agents in these directories are already installed at `.claude/skills/` — the `_bmad/` directory should only contain config files.

As with the merge scripts, replace `{project-root}` in the `--bmad-dir` and `--skills-dir` path arguments with the actual project root before running.

```bash
python3 ./scripts/cleanup-legacy.py --bmad-dir "{project-root}/_bmad" --module-code bmad-loop --also-remove _config --skills-dir "{project-root}/.claude/skills"
```

The script verifies that every skill in the legacy directories exists at `.claude/skills/` before removing anything. Directories without skills (like `_config/`) are removed directly. If the script exits non-zero, surface the error and stop. Missing directories (already cleaned by a prior run) are not errors — the script is idempotent.

**On a rename-upgrade from bmad-auto**, also remove the old `_bmad/bauto/` installer directory. When it was populated by the BMAD-method installer it holds the pre-rename `bmad-auto-*` skill copies, which no longer exist at `.claude/skills/` — so run this cleanup **without** `--skills-dir` to skip the installed-skill verification (their removal is exactly the point). It is a no-op when `_bmad/bauto/` isn't present:

```bash
python3 ./scripts/cleanup-legacy.py --bmad-dir "{project-root}/_bmad" --module-code bauto
```

(`--module-code bauto` also targets `core`, already handled above — a missing directory is a no-op.)

Check `directories_removed` and `files_removed_count` in the JSON output for the confirmation step. Run `./scripts/cleanup-legacy.py --help` for full usage.

## Confirm

Use the script JSON output to display what was written — config values set (written to `config.yaml` at root for core, module section for module values; the `bmad-loop` section's `version` is re-stamped from `./assets/module.yaml` on every run via the anti-zombie merge), user settings written to `config.user.yaml` (`user_keys` in result), help entries added, fresh install vs upgrade.

Report the **tool** result according to the branch taken:

- **Fresh install:** the installed `bmad-loop --version`, that `bmad-loop init` registered hooks, installed the `bmad-loop-*` skills, and wrote policy/gitignore for the selected coding CLI(s) (name each one — e.g. "hooks + skills installed for claude, codex").
- **Upgrade:** the before → after `bmad-loop --version` (e.g. "upgraded 0.3.1 → 0.3.2", or "already current at 0.3.2"), that the `bmad-loop-*` skills were **refreshed** (not skipped) with `--force-skills` in each CLI tree, and the re-stamped config version.

Also report the `bmad-loop validate` preflight result (pass, or the readiness checklist of what's still missing). If legacy files were deleted, mention the migration. If legacy directories were removed, report the count and list (e.g. "Cleaned up 106 installer package files from bmb/, core/, \_config/ — skills are installed at .claude/skills/"). Then display the `module_greeting` from `./assets/module.yaml` to the user.

## Outcome

Once the user's `user_name` and `communication_language` are known (from collected input, arguments, or existing config), use them consistently for the remainder of the session: address the user by their configured name and communicate in their configured `communication_language`.
