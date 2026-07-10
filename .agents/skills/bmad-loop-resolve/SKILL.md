---
name: bmad-loop-resolve
description: 'Interactive escalation-resolution workflow for the bmad-loop orchestrator. A bmad-loop run paused on a CRITICAL escalation (a contradiction or gap a dev/review session could not safely resolve alone); you and the human disambiguate the frozen spec so the story can be re-driven. Invoked as /bmad-loop-resolve <story-key>. Unlike the automated dev/review sessions this session is interactive — a human is present and you SHOULD ask.'
---

# bmad-loop Escalation Resolution

A `bmad-loop` run drove a story through dev → review, a session raised a
**CRITICAL escalation** (work could not proceed safely — usually a contradiction
or an unanswered question in the _frozen spec_), and the orchestrator paused the
whole run for a human. The session that escalated is gone; you are a fresh
interactive session whose job is to **resolve the ambiguity with the human and
update the frozen spec**, so the orchestrator can re-arm the story and re-drive
it against a corrected spec.

This is **interactive**: a human IS present. Ask questions, present options,
recommend — but the human makes the call. (`$BMAD_LOOP_MODE` is intentionally
unset for this session; the never-ask automation rules do NOT apply.)

## Identity & I/O contract

These environment variables are set:

- `$BMAD_LOOP_RUN_DIR` — the paused run's directory.
- `$BMAD_LOOP_STORY_KEY` — the escalated story key (also your invocation argument).
- `$BMAD_LOOP_RESOLVE_CONTEXT` — path to a `context.json` written for you.

**Read `$BMAD_LOOP_RESOLVE_CONTEXT` FIRST.** Its schema:

```json
{
  "story_key": "6-4-cli-list-command",
  "run_id": "20260613-111429-6a14",
  "spec_file": "/abs/path/to/_bmad-output/implementation-artifacts/spec-<story>.md",
  "baseline_commit": "<sha>",
  "paused_reason": "CRITICAL escalation from review session: ...",
  "escalations": [
    {
      "type": "<kind>",
      "severity": "CRITICAL",
      "detail": "<what's ambiguous/contradictory>"
    }
  ],
  "resolution_path": "/abs/path/to/<run>/resolve/<story>/resolution.json"
}
```

Your **output marker** is the file at `resolution_path`. Writing it is the LAST
action of a successful resolution. Schema:

```json
{
  "story_key": "<key>",
  "decision": "<one or two sentences: the rule you and the human chose>",
  "spec_file": "<the spec you edited>",
  "spec_updated": true
}
```

## What you MUST do

1. **Read the context**, then read the **frozen spec** at `spec_file` in full —
   especially its `<frozen-after-approval>` block (the intent the dev/review
   sessions treat as authoritative). The escalation is almost always that this
   block is silent on, or contradicts, a case the implementation hit.
2. **Present the escalation plainly** to the human: what is ambiguous or
   contradictory, why it blocks safe implementation, and **2–4 concrete
   resolution options** with a clear recommendation and its trade-offs. Keep it
   tight — quote the relevant spec lines.
3. **Get the human's decision.** Ask follow-ups if the choice is unclear. Do not
   invent requirements; if the human is unsure, help them reason, don't guess.
4. **Update the frozen spec** to encode the decision unambiguously: amend the
   `<frozen-after-approval>` block and any affected acceptance criteria / test
   matrix rows so a fresh dev session has exactly one correct reading. Make the
   smallest change that removes the ambiguity. You MAY use the `bmad-spec` or
   `bmad-correct-course` skills if a larger spec change is warranted.
5. **Write the resolution marker** at `resolution_path` (schema above), then tell
   the human the resolution is recorded and they can exit this session — the
   orchestrator will offer to **re-arm the story and resume the run** (a clean
   rebuild against the corrected spec).

## What you MUST NOT do

- **Do NOT** write the orchestrator's `result.json` — that is a dev/review
  artifact; this is not one of those sessions.
- **Do NOT** change `sprint-status.yaml`, and **do NOT** set the spec's `status:`
  field — the orchestrator deterministically re-arms the spec status on resume.
  Edit spec **content** only.
- **Do NOT** implement the story, write feature code, run tests, or commit. Your
  job ends at a corrected spec + the resolution marker.
- **Do NOT** widen scope. Resolve exactly the escalated ambiguity; if you notice
  unrelated problems, note them to the human but leave them alone.

## If you cannot resolve it

If the human defers, the information needed is genuinely unavailable, or the
right fix is out of scope for a spec edit (e.g. it needs a PRD/architecture
change), say so plainly and **do not** write the resolution marker. Exiting
without the marker leaves the story escalated and the run paused — the safe
default. The orchestrator will not re-arm a story with no recorded resolution.
