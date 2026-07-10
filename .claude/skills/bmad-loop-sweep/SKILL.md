---
name: bmad-loop-sweep
description: 'Triage the deferred-work ledger for the bmad-loop orchestrator: verify every open entry against the actual codebase and return a machine-readable partition (bundles, already-resolved, blocked, skip, human decisions). Also migrates legacy pre-DW-format ledgers when invoked with --migrate. Automation-only — invoked by bmad-loop sweep runs, not by humans.'
---

# Deferred-Work Sweep Triage

**Goal:** Classify every open entry in `{implementation_artifacts}/deferred-work.md`
into a machine-readable triage plan the orchestrator can validate and execute.

This workflow is **read-only and automation-native**: it runs only inside a
`bmad-loop` sweep session. You never edit the ledger, never edit code, never
ask questions. Your sole output is the result file. (The one exception is
migration mode, which edits exactly one file — the ledger.)

## On Activation

### Step 0: Automation Check & Mode Dispatch

Run: `echo "${BMAD_LOOP_MODE:-}"`

If the output is not `1`, state that this skill only runs inside a bmad-loop
sweep and end your turn. Otherwise read `./automation-mode.md` fully — its
rules and result schema govern this entire run.

If the invocation carries `--migrate <manifest-path>`, this is a **migration
session**, not triage: read `./migration-mode.md` and follow it instead of
Steps 1–4 below.

### Step 1: Locate the ledger

Read `{project-root}/_bmad/bmm/config.yaml` to resolve `implementation_artifacts`,
then read `{implementation_artifacts}/deferred-work.md` in full. Open entries
are `### DW-<n>:` blocks whose `status:` line is `open`. If the ledger is
missing or unreadable, escalate `CRITICAL` (`type: missing-ledger`) per
automation-mode.md and end your turn.

If the invocation carries `--feedback <path>`, read that file FIRST — it lists
the deterministic validation errors your previous attempt's result.json failed
on. Fix exactly those defects in this attempt's output.

### Step 2: Verify every open entry against the code

Ledger statuses are known-unreliable: entries are often resolved by later work
but never marked done. For EACH open entry:

1. Read its `location:` (file/component) in the current tree.
2. Check whether the described issue still exists — read the code, grep for
   the symptom, check `git log` for commits that touched the area since the
   entry's `origin:` date.
3. Record concrete evidence either way. "Probably fixed" is not evidence;
   a file:line or commit hash is.

Use sub-agents for parallel verification when available; never ask permission.

### Step 3: Partition

Classify each open entry into exactly ONE category:

- **already_resolved** — the issue no longer exists in the code. Requires
  concrete `evidence` (file:line that now handles it, or the commit that fixed
  it). The orchestrator closes the ledger entry deterministically.
- **bundles** — buildable now: every file the fix needs already exists and no
  future story has to land first. Group entries that share a touchpoint (same
  file, same subsystem, same validator pattern) into cohesive single-goal
  bundles sized for one dev session; an entry that stands alone is a
  one-entry bundle. `name` is kebab-case (e.g. `unicode-string-hardening`),
  `intent` is 2–6 sentences describing the one cohesive goal.
- **blocked** — the fix is only meaningful (or meaningfully easier) after a
  named future story/epic lands. Name the blocker verbatim.
- **skip** — superseded, moot, or tied to a scenario the project explicitly
  excludes. Give the reason.
- **decisions** — a human must choose. ALWAYS a decision, never a bundle:
  renegotiating anything inside a spec's `<frozen-after-approval>` block,
  reversing a deliberate human-approved scope decision, API-shape changes that
  ripple to unbuilt consumers, and entries deferred with reason
  "auto-mode: needs human decision". Each decision gets 2–4 concrete options
  (each with an `effect`: `build` + an implementation intent, `close` +
  optional resolution, or `keep-open`) and your `recommendation`. The only
  exception: a frozen-block renegotiation that is clearly net-positive,
  non-destructive, and behavior-tightening may be bundled — when in doubt,
  make it a decision.

Every open entry appears in exactly one category. The orchestrator validates
this deterministically; a missed or double-counted entry fails the whole
result and burns a retry.

### Step 4: Write the result and end your turn

Write the result.json per `./automation-mode.md` and state in one line how
many entries went to each category. End your turn. Do not edit any file other
than the result file.
