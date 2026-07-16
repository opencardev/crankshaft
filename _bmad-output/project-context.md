---
project_name: crankshaft
user_name: matth
date: 2026-07-16
sections_completed: ['technology_stack', 'language_rules', 'framework_rules', 'testing_rules', 'quality_rules', 'workflow_rules', 'anti_patterns']
status: complete
rule_count: 46
optimized_for_llm: true
---

# Project Context for AI Agents

_This file contains critical rules and patterns that AI agents must follow when implementing code in this project. Focus on unobvious details that agents might otherwise miss._

---

## Technology Stack & Versions

- Monorepo with distinct codebases:
  - src/crankshaft-core: backend, C++20
  - src/crankshaft-ui-slim: one client, C++20 + Qt/QML
- Build system: CMake >= 3.16
- Core runtime: Qt6, GStreamer, AASDK, libusb, OpenSSL, Protobuf
- UI runtime: Qt6 + optional GStreamer WebRTC receiver path
- Primary control transport: WebSocket contract (capability and protocol negotiated)
- Video transport strategy: WebRTC primary, WebSocket JPEG fallback

## Critical Implementation Rules

### Language-Specific Rules

- Treat crankshaft-core as multi-client backend; never branch backend behavior by client name.
- Gate behavior using negotiated protocol/capabilities, not UI identity.
- In async callbacks/timers/signals, re-check current state or generation before side effects.
- Enforce parse -> validate -> policy/contract check -> execute ordering for external messages.
- Keep recovery deterministic: config-driven thresholds, cooldowns, and retry bounds.
- Reflect new runtime dependencies in CMake detection, packaging lists, and runtime install paths.
- Keep UI-side logic backend-state-aware; avoid local timer assumptions for readiness or transport mode.

### Framework-Specific Rules

- Keep QML presentation-focused; place non-trivial control logic in C++ client layers.
- Avoid backend-triggering side effects in reactive bindings that can fire repeatedly.
- Preserve service boundaries in core services; use eventbus/explicit interfaces over ad hoc coupling.
- Define schema, capability requirement, idempotency, and rejection semantics for new routes/topics.
- Maintain explicit single ownership of critical state transitions.
- Treat AA startup/handshake/recovery as explicit state-machine flows with bounded, observable guards.

### Testing Rules

- Keep tests aligned to repo boundaries; do not blur backend and client responsibilities.
- Prefer deterministic tests; avoid sleep-based pass conditions except where timing is the test subject.
- For bugfixes, add failing-first tests when practical; otherwise document why and add strongest regression test.
- Every contract change must include positive-path, negative-path, and capability-gated coverage.
- Client hello coverage must include protocol mismatch, missing capability, permissive mode, and strict mode.
- Assert state-machine invariants: forbidden transitions rejected, side effects once, ownership not split.
- Cover churn guards: cooldown suppression, warm-up suppression, threshold-based escalation.
- Require observability assertions for reason/status outputs in suppression/escalation paths.

### Code Quality & Style Rules

- Prefer clarity over cleverness in reliability-sensitive control paths.
- Keep diffs single-intent; avoid mixing reliability logic with unrelated cleanup.
- Use typed enums/constants in control paths; avoid magic values.
- Split parse/policy/execute into focused helpers when handlers grow complex.
- Treat all external input as untrusted; validate structure, bounds, and semantics before action.
- Reject invalid transitions explicitly; avoid silent auto-repair behavior.
- Keep retry-enabled handlers idempotent or explicitly replay-guarded.

### Development Workflow Rules

- Use feature branches per repo; do not push directly to protected branches.
- Keep cross-repo contract changes independently releasable with additive compatibility defaults.
- For contract changes, include diff summary, compatibility behavior, rollout order, and compatibility matrix updates.
- For deprecations, include owner, target removal release, telemetry signal, and removal criteria.
- For reconnect/renegotiation/transport/state-machine changes, include failure narrative, kill switch, rollback, and async impact note.
- Roll out risky transport/handshake behavior in two phases: permissive observe mode then strict enforcement with evidence.
- Validate via build/test checks, contract behavior checks, and runtime evidence on target environment.
- Record architecture-significant behavior changes via ADR updates and link incident closures to prevention artifacts.

### Critical Don't-Miss Rules

- Never collapse the core/client split by embedding UI-specific branching in crankshaft-core.
- Never ship transport/session-control changes without bounded guards and machine-parseable reason codes.
- Never allow unbounded reconnect or renegotiation loops.
- Never tighten protocol/capability requirements without minimum supported version and migration window.
- Never ship breaking contract changes silently; use additive evolution and owned deprecation plans.
- Never enable strict contract enforcement by default before permissive telemetry evidence.
- Never apply side effects before complete parse, validation, and policy checks.
- Never permit multi-writer mutation of critical session/transport state without explicit arbitration.
- Never merge reliability-sensitive changes without negative-path tests, state assertions, observability assertions, and tested rollback.
- Never introduce undocumented runtime toggles; every toggle needs safe default rationale and operator playbook guidance.

---

## Usage Guidelines

**For AI Agents:**

- Read this file before implementing any code.
- Follow all rules exactly as documented.
- When in doubt, choose the more restrictive path.
- Update this file when a new recurring pattern or failure mode is confirmed.

**For Humans:**

- Keep this file lean and focused on non-obvious agent guidance.
- Update when stack, contracts, or rollout patterns change.
- Review quarterly and remove rules that became obvious or obsolete.
- Ensure ADR links stay current with architecture-significant decisions.

Last Updated: 2026-07-16
