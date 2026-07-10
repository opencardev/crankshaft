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

In **stories mode** (folder+id dispatch) the context also carries a `stories`
block — the manifest intent for this story, so you can see WHAT it is meant to do
without hunting for it:

```json
{
  "stories": {
    "spec_folder": "_bmad-output/epic-1",
    "story": {
      "id": "6-4-cli-list-command",
      "title": "CLI list command",
      "description": "…",
      "spec_checkpoint": false,
      "done_checkpoint": false,
      "invoke_dev_with": "…free-text planner→dev note, or ''…"
    },
    "sentinel": {
      "kind": "unresolved",
      "path": ".../stories/6-4-cli-list-command-unresolved.md",
      "blocking_condition": "…the reason planning halted…"
    }
  }
}
```

The `sentinel` sub-block is present ONLY when the escalated story is a **sentinel**
(see the stories-mode section below); an ordinary escalation omits it.

Your **output marker** is the file at `resolution_path`. Writing it is the LAST
action of a successful resolution. Schema:

```json
{
  "story_key": "<key>",
  "decision": "<one or two sentences: the rule you and the human chose>",
  "spec_file": "<the spec you edited>",
  "spec_updated": true,
  "restore_patch": "<optional: path to a saved intent-gap patch to re-apply>"
}
```

`restore_patch` is **optional** and used only for the intent-gap patch-restore
case below — omit it entirely for an ordinary resolution.

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

## Special case: a review-stage `intent gap` with a saved patch

When the escalation came from the **review step** halting on an `intent gap`, the
dev session first **saved its attempted change as a patch file** (in the
implementation-artifacts folder) before reverting the tree — the escalation
`detail` and the spec's `## Review Triage Log` reference the patch path. That
patch is concrete evidence: it shows exactly which reading of the intent the run
implemented.

**First check `restore_supported` in the context file.** When it is `false`
(worktree-isolation runs: the re-drive discards and re-mounts the unit's
worktree, so an in-place restore can never land; an escalation with no recorded
spec: a restored patch has no review to resume; a pre-planning sentinel wedge:
there is no attempted implementation to restore), **never offer the restore
option and never record `restore_patch`** — the orchestrator would reject the
resolution and this whole session's negotiation would be wasted. The patch is
still available as evidence.

Use the patch two ways:

- **As evidence.** Read the patch (and the diff it represents) to see what the
  guessed reading produced — often clearer input for writing the clarification
  than the questions alone.
- **When the attempted reading was actually correct.** Sometimes the run's guess
  is the right one and only the _intent_ was silent. Present this as an explicit
  option to the human: _"the implementation read it as X, which is in fact what we
  want — amend the intent to say X, and resume **review** on the already-written
  change instead of re-implementing it."_ If the human chooses this:
  1. Still **amend the intent** in the spec so it unambiguously says X (step 4
     above is unchanged — the frozen intent must match the restored code).
  2. Add **`"restore_patch": "<the saved patch path>"`** to `resolution.json`
     (copy the path verbatim from the escalation detail / triage log).

  The orchestrator then re-arms the spec to `in-review`, re-applies the patch onto
  the baseline, and re-dispatches — the session resumes at the review step on the
  restored diff. **Do NOT `git apply` the patch yourself and do NOT set the spec
  status** — the orchestrator does both deterministically at re-arm.

  **The restore must not overlap resolution commits.** Re-arm advances the
  re-drive's baseline to the branch's post-resolve HEAD, but the saved patch was
  diffed from the ORIGINAL baseline — so if this session left commits that touch
  the patch's own files, the restore's `git apply` fails and the story
  re-escalates (loudly, by design: the orchestrator never silently merges the
  resolution with the stale attempt). If the resolution work already includes or
  supersedes the attempted change, **omit `restore_patch`** — the commits survive
  re-arm as the re-drive's starting point, so a from-scratch re-drive builds
  directly on them.

If the attempted reading was wrong (the common case), omit `restore_patch`
entirely: the orchestrator re-drives from scratch against the corrected intent.

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

## Stories mode: sentinels and the preserved copy

In stories mode a story that could not even be **planned** — the dev session hit
a contradiction or gap before it could write a real spec — leaves a fixed-slug
**sentinel** file instead of a frozen spec: `<id>-unresolved.md` (the intent was
too ambiguous to plan) or `<id>-ambiguous.md` (more than one story spec matched
the id). The context's `stories.sentinel` block names it and carries the
`blocking_condition` the session recorded.

A sentinel is **not a spec you edit** — there is no plan or `<frozen-after-approval>`
block inside it. So for a sentinel:

- **Do not try to amend a frozen spec** (step 4's "edit the frozen spec" does not
  apply — there isn't one). Instead resolve the _upstream_ ambiguity so a fresh
  planning pass can succeed: usually that means clarifying `SPEC.md` (the epic
  spec) or this story's entry in `stories.yaml` — the `title` / `description` /
  `invoke_dev_with` the planner reads — with the human.
- On **re-arm** the orchestrator does NOT flip the sentinel to `ready-for-dev`
  (there is no plan to route to). It **preserves a copy** of the sentinel under
  `{run}/sentinels/<id>-<kind>.md` as a breadcrumb, **deletes** the sentinel, and
  the next dispatch re-plans the story from scratch (leg 1 again for a
  `spec_checkpoint` story). You do not touch the sentinel file yourself.
- Write the resolution marker as usual once the human has decided how to
  disambiguate; set `spec_file` to whatever you edited (e.g. `SPEC.md`), or omit
  it if the fix was entirely in `stories.yaml`.

### Not a sentinel: more than one file matches the id

Distinct from the single-file `<id>-ambiguous.md` sentinel above: when **more
than one** file in `stories/` matches `<id>-*.md` (say `3-login.md` AND
`3-signup.md`), the id itself is ambiguous _on disk_ and the orchestrator wedges
the story without picking either file. You can recognize this state by the
escalation reason (`ambiguous story file match: <names>`) and by what the
context does NOT have: no `stories.sentinel` block and no single spec path.

The auto-clear above does **not** apply — there is no sentinel to preserve and
delete, and re-arming alone just re-wedges on the same duplicates. The
resolution IS the cleanup: with the human, decide which file is the story's real
spec and remove or rename the other (merge content first if both carry real
work; renaming must move it out of the `<id>-*` pattern or to another id).
Exactly one match re-dispatches that spec; zero matches re-plans from scratch.
Then write the resolution marker as usual — re-arm + resume takes it from there.

## If you cannot resolve it

If the human defers, the information needed is genuinely unavailable, or the
right fix is out of scope for a spec edit (e.g. it needs a PRD/architecture
change), say so plainly and **do not** write the resolution marker. Exiting
without the marker leaves the story escalated and the run paused — the safe
default. The orchestrator will not re-arm a story with no recorded resolution.
