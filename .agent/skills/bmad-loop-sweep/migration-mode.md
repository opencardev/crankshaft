# Migration Mode

Projects started before the DW entry format carry a freeform
`deferred-work.md` — "## Deferred from: ..." sections with bullets,
strikethrough done-markers, `### D-1.2-003: title — RESOLVED` headings,
topic sections suffixed "(... — DONE)". The orchestrator cannot sweep those:
`status:` lines don't exist to flip, and open items are invisible to its
parser. Your job is a one-time rewrite of every legacy item into a canonical
`### DW-<n>:` entry, after which the normal triage flow takes over.

This is the ONE workflow mode that edits a file: exactly the ledger at
`{implementation_artifacts}/deferred-work.md`. Never any other file, never
code, never specs, never sprint-status. Never commit — the orchestrator
commits the migrated ledger after validating it.

## Inputs

- `--migrate <manifest-path>`: a JSON array — the orchestrator's parse of the
  legacy items. Each element:

  ```json
  {
    "key": "<stable identity — echo it back in your mapping>",
    "id": "<native id like W2 / D-CAP-001, or empty>",
    "title": "<cleaned one-line title>",
    "section": "<enclosing heading text>",
    "done": true,
    "severity": "high"
  }
  ```

  The manifest is authoritative for WHAT to convert and each item's
  open/done state. Do not re-interpret done-ness from the prose; the
  orchestrator validates your output against the manifest's `done` flags.

- `--feedback <path>` (retry only): the deterministic validation errors your
  previous attempt failed on, including any items that still parse as legacy.
  Read it FIRST and fix exactly those defects.

## The rewrite

1. Read the manifest and the full ledger.
2. Keep every existing `### DW-<n>:` entry **byte-identical** — the
   orchestrator fails the migration if a pre-existing entry's status changes
   or an entry disappears.
3. Replace all legacy content with canonical entries per
   `./deferred-work-format.md`. Number new entries continuing
   from the highest existing `DW-<n>` (start at DW-1 when none exist), in
   the items' original file order. Per item:
   - `### DW-<n>: <title>` — the manifest title, refined from the original
     bullet when it improves clarity.
   - `origin: migrated from legacy ledger ("<section>"), <today>` — keep the
     original review/date context from the section text.
   - `location:` — extract a file/component from the original text, else `n/a`.
   - `severity:` — the manifest severity; omit the line when null.
   - `reason:` — the substance of the original bullet, condensed but lossless
     enough that a future dev session can act on it. Long forensic detail may
     follow as body lines under the fields.
   - `status: open`, or for done items `status: done <date>` using the
     original completion date when recoverable (else today), plus a
     `resolution:` line carrying the original resolution text when one
     exists (e.g. the text after `→` or a `**Resolution:**` field).
4. Two manifest items describing the same underlying issue (e.g. a duplicate
   `W1` re-raised in a later review) may merge into ONE DW entry — map both
   keys to the same `dw_id`. Merge only when their `done` flags match.
5. The finished file must contain only the `# Deferred Work` title line and
   canonical `### DW-<n>:` entries. Any leftover freeform section, bullet
   list, or strikethrough item fails the orchestrator's zero-legacy check
   and burns a retry.

## Result

Write the result file per automation-mode.md with the migration schema:

```json
{
  "workflow": "deferred-sweep-migrate",
  "mapping": [{ "key": "<manifest key>", "dw_id": "DW-12" }],
  "escalations": []
}
```

Every manifest key appears exactly once; every `dw_id` must exist in the
rewritten ledger with the manifest's open/done state. State in one line how
many items you converted (and how many merged), then end your turn.
