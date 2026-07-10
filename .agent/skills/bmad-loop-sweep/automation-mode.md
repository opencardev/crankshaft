# Automation Mode

You are running unattended inside a `bmad-loop` sweep session. No human is
watching; a deterministic program spawned you, will validate your result.json
field-by-field, and will kill this session after your final turn.

## Identity & I/O contract

- `$BMAD_LOOP_RUN_DIR` and `$BMAD_LOOP_TASK_ID` are set in your environment.
- Your **result file** is `$BMAD_LOOP_RUN_DIR/tasks/$BMAD_LOOP_TASK_ID/result.json`.
  Writing it is the LAST action of the run. Schema:

  ```json
  {
    "workflow": "deferred-sweep-triage",
    "open_ids": ["DW-1", "DW-3", "..."],
    "already_resolved": [{ "id": "DW-1", "evidence": "<file:line or commit that resolved it>" }],
    "bundles": [
      {
        "name": "<kebab-case-name>",
        "dw_ids": ["DW-3"],
        "intent": "<2-6 sentences: the one cohesive goal>"
      }
    ],
    "blocked": [{ "id": "DW-4", "blocker": "<named story/epic that must land first>" }],
    "skip": [{ "id": "DW-9", "reason": "<why this is moot/superseded>" }],
    "decisions": [
      {
        "id": "DW-7",
        "question": "<the choice the human must make>",
        "context": "<2-4 sentences of code-grounded context>",
        "options": [
          {
            "key": "1",
            "label": "<short label>",
            "effect": "build",
            "intent": "<what a dev session would implement>"
          },
          {
            "key": "2",
            "label": "<short label>",
            "effect": "close",
            "resolution": "<optional: why closing is fine>"
          },
          { "key": "3", "label": "<short label>", "effect": "keep-open" }
        ],
        "recommendation": "1"
      }
    ],
    "escalations": []
  }
  ```

- Validation rules the orchestrator enforces (a violation fails the whole
  result and burns a retry):
  - `open_ids` must list exactly the ledger's `status: open` entries — the
    orchestrator parses the ledger itself and compares.
  - Every open id appears in exactly ONE of already_resolved / bundles /
    blocked / skip / decisions. No misses, no duplicates, no invented ids.
  - Bundle names: `^[a-z0-9][a-z0-9-]{1,39}$`, unique, non-empty `dw_ids`,
    non-empty `intent`.
  - Every `already_resolved` entry needs non-empty `evidence`; every
    `blocked` a `blocker`; every `skip` a `reason`.
  - Decisions: >= 2 options with unique keys, `effect` one of
    `build|close|keep-open`, `intent` required when effect is `build`,
    `recommendation` must be one of the option keys.

- **Migration sessions** (`--migrate`, see `./migration-mode.md`) use this
  result schema instead:

  ```json
  {
    "workflow": "deferred-sweep-migrate",
    "mapping": [{ "key": "<manifest key>", "dw_id": "DW-12" }],
    "escalations": []
  }
  ```

  Validation rules: the rewritten ledger parses with ZERO legacy items;
  pre-existing `### DW-<n>:` entries keep their ids and status; new entries
  continue numbering past the highest existing number with `status: open` or
  `status: done <date>`; `mapping` covers every manifest key exactly once and
  each `dw_id` exists with the manifest's open/done state (two keys may share
  a `dw_id` when merging duplicates of equal done-ness).

- Your **escalation file** is `$BMAD_LOOP_RUN_DIR/tasks/$BMAD_LOOP_TASK_ID/escalation.json`.
  Use it only for blockers no rule resolves (e.g. the ledger is missing or
  unreadable: `type: missing-ledger`, severity `CRITICAL`), then include the
  same entries in result.json `escalations` and end your turn. Schema:

  ```json
  {
    "escalations": [
      {
        "type": "<short-kebab-kind>",
        "severity": "CRITICAL|PREFERENCE",
        "detail": "<one or two sentences>"
      }
    ]
  }
  ```

## Behavior rules

1. **Never HALT for input. Never ask the user anything.** No greeting, no
   menus, no "what next" offers.
2. **Read-only — except migration mode.** In triage you never edit the
   ledger, code, specs, or sprint-status; the orchestrator performs all
   ledger edits deterministically and runs the bundles you propose through
   separate dev/review sessions. A `--migrate` session edits exactly one
   file: the ledger (still never code/specs/sprint-status, never commits).
3. **Verify before classifying.** Never trust an entry's own status or wording;
   check the code. An entry that says "open" but is fixed goes to
   already_resolved with evidence.
4. **Conservative on human territory.** Frozen-block renegotiations, scope
   reversals, and API-shape changes are decisions, not bundles (see SKILL.md
   Step 3). When in doubt between bundle and decision, choose decision.
5. **Never commit, never push, never open an editor.**
