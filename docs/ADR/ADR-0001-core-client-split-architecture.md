# ADR-0001: Core/Client Split Architecture

- Status: Accepted
- Date: 2026-07-16
- Deciders: OpenCarDev maintainers
- Technical Story: Multi-UI evolution and long-term backend stability
- Tags: architecture, boundaries, contracts, maintainability

## Context

Crankshaft is evolving from a single UI assumption to a platform where multiple UI clients can consume a shared backend.

Historically, behavior and assumptions were tightly coupled between a specific UI and backend behavior, making changes risky and hard to generalize.

Key constraints:
- Backend reliability must not depend on one UI implementation.
- New UIs should be able to integrate without backend rewrites.
- Compatibility governance is required for long-lived deployments.

## Decision

Adopt and preserve a strict Core/Client split:
- `crankshaft-core` is the backend system-of-record for Android Auto control, transport orchestration, and session state.
- UI applications (including ui-slim) are contract-driven clients that consume backend events and issue commands through explicit APIs/contracts.
- UI-specific behavior must remain in client repos unless explicitly promoted to cross-client contract features.

Out of scope:
- UI rendering decisions.
- Backend embedding UI-specific UX flow assumptions.

## Options Considered

### Option A: Monolithic Core+UI behavior coupling
- Description: Keep backend and one UI deeply coupled.
- Pros: Fast local iteration for one UI.
- Cons: Fragile when adding alternate UIs; high regression risk; poor separation of concerns.
- Why not chosen: Conflicts with multi-client strategy and long-term maintainability.

### Option B: Strict backend-core with contract-based clients (chosen)
- Description: Backend offers stable contract; clients implement UX independently.
- Pros: Extensible, testable boundaries, safer evolution across repos.
- Cons: Requires disciplined contract/version governance.
- Why chosen: Best supports multiple UI frontends and operational resilience.

### Option C: Plugin UIs loaded in-process by backend
- Description: Backend hosts UI plugins directly.
- Pros: Potentially easier distribution model.
- Cons: Increases failure blast radius and deployment complexity; weak isolation.
- Why not chosen: Violates reliability/isolation goals.

## Rationale

A clean split minimizes coupling and preserves backend reliability while allowing UI diversity.

This also enables negotiated contracts (protocol+capabilities) so compatibility is explicit instead of implicit.

## Consequences

### Positive
- New UIs can integrate through stable contracts.
- Core can evolve with explicit compatibility strategy.
- Better fault isolation between backend and UI process concerns.

### Negative
- Requires contract documentation and enforcement discipline.
- Adds upfront design and review overhead.

### Neutral / Follow-on
- Need ADRs and docs for transport and protocol decisions.

## Compatibility and Migration

- Existing clients continue with permissive mode where possible.
- Move toward explicit negotiated contracts with phased enforcement.
- Client-specific assumptions should be removed from core over time.

## Security and Reliability Considerations

- Boundary contracts reduce accidental privilege/behavior coupling.
- Contract violations can be rejected early with explicit errors.
- Observability must include client identity/version/capability metadata for diagnosis.

## Implementation Notes

Impacted repos/modules:
- `src/crankshaft-core`
- `src/crankshaft-ui-slim`
- Future UI repos consuming core contracts

Key interfaces:
- WebSocket message contract
- Client hello/version/capability negotiation

## Validation

- Contract tests against multiple clients.
- Runtime logs confirm negotiated client metadata.
- New UI integration should require no backend behavior forks.

## Open Questions

- Which capabilities become mandatory by profile/use case?
- How strict should compatibility enforcement be by deployment tier?

## References

- ADR-0002 (WebSocket transport)
- ADR-0003 (video transport strategy)
- `docs/ADR/ADR-TEMPLATE.md`
