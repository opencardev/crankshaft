#!/usr/bin/env python3
"""Coding-CLI hook relay for bmad-loop. Stdlib only.

Each CLI's hook config registers this script under its native event names
(Claude/Codex: SessionStart/Stop/..., Gemini: AfterAgent for Stop, Copilot:
agentStop for Stop) but always passes the CANONICAL event name as argv[1] — the
orchestrator only ever sees canonical events. Payload keys vary too: snake_case
(claude/codex), conversation_id (cursor), or camelCase (copilot's sessionId/
transcriptPath); the field extraction below tries each. Reads the hook payload
from stdin and writes one event file
into the orchestrator's run directory. No-ops (exit 0) unless the session was
spawned by bmad-loop (detected via env vars set on the tmux window), so
normal interactive sessions are unaffected.
"""

import json
import os
import sys
import time


def main() -> int:
    run_dir = os.environ.get("BMAD_LOOP_RUN_DIR")
    task_id = os.environ.get("BMAD_LOOP_TASK_ID")
    if not run_dir or not task_id:
        return 0
    event_name = sys.argv[1] if len(sys.argv) > 1 else "Unknown"
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        payload = {}
    if not isinstance(payload, dict):
        payload = {}

    ts = time.time_ns()
    event = {
        "ts": ts,
        "event": event_name,
        "task_id": task_id,
        # Payload keys vary by CLI: snake_case (claude/codex), conversation_id
        # (cursor), or camelCase (copilot's sessionId/transcriptPath). Try each.
        "session_id": (
            payload.get("session_id") or payload.get("conversation_id") or payload.get("sessionId")
        ),
        "transcript_path": payload.get("transcript_path") or payload.get("transcriptPath"),
        "cwd": payload.get("cwd"),
    }
    events_dir = os.path.join(run_dir, "events")
    os.makedirs(events_dir, exist_ok=True)
    final = os.path.join(events_dir, f"{ts}-{task_id}-{event_name}.json")
    tmp = final + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(event, f)
    os.replace(tmp, final)
    return 0


if __name__ == "__main__":
    sys.exit(main())
