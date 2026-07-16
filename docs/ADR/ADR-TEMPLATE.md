# ADR-XXXX: <Short Decision Title>

- Status: Proposed
- Date: YYYY-MM-DD
- Deciders: <team/persona names>
- Technical Story: <ticket/story/incident links>
- Tags: <architecture, api, transport, reliability, etc.>

## Context

Describe the problem space and constraints that make this decision necessary.

Include:
- Current state and pain points.
- Business or operational constraints.
- Non-functional requirements (reliability, performance, security, maintainability).
- Known assumptions and unknowns.

## Decision

State the decision clearly and concretely.

Include:
- What is being adopted.
- Scope and boundaries.
- What is explicitly out of scope.

## Options Considered

### Option A: <name>
- Description:
- Pros:
- Cons:
- Why not chosen:

### Option B: <name>
- Description:
- Pros:
- Cons:
- Why not chosen:

### Option C: <name>
- Description:
- Pros:
- Cons:
- Why not chosen:

## Rationale

Explain why the chosen decision is best for this context.

Include:
- Trade-offs accepted.
- Why rejected options are weaker under current constraints.
- How this aligns with overall architecture direction.

## Consequences

### Positive
- <benefit>

### Negative
- <cost/risk>

### Neutral / Follow-on
- <new work enabled or required>

## Compatibility and Migration

Define compatibility behavior and migration strategy.

Include:
- Backward compatibility expectations.
- Forward compatibility expectations.
- Versioning or capability negotiation implications.
- Rollout strategy (phased, feature flags, enforcement date).

## Security and Reliability Considerations

Document security/reliability impacts.

Include:
- Failure modes introduced/mitigated.
- Observability requirements (logs/metrics/traces).
- Recovery/degradation behavior.

## Implementation Notes

Reference implementation details without overloading this ADR.

Include:
- Repositories and modules impacted.
- Key interfaces/contracts to add or change.
- Configuration keys and defaults.

## Validation

How the decision will be validated.

Include:
- Test strategy (unit/integration/e2e).
- Runtime verification signals.
- Success criteria and rollback triggers.

## Open Questions

- <question>

## References

- <related ADRs>
- <PRs, issues, docs, diagrams>

---

## ADR Lifecycle Guidance

Status transitions:
- Proposed -> Accepted -> Superseded | Deprecated

When to supersede:
- A newer ADR replaces this decision with a materially different approach.

When to deprecate:
- The decision is no longer used and is being phased out without a direct replacement.

Naming convention:
- `ADR-0001-short-kebab-title.md`
- Keep numbering monotonic and never reuse numbers.

Quality checklist:
- Decision is specific and testable.
- At least 2 credible alternatives are evaluated.
- Trade-offs are explicit.
- Compatibility behavior is explicit.
- Operational validation plan is explicit.
