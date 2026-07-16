# ADR-0003: Dual Video Transport Strategy (WebRTC + WebSocket JPEG)

- Status: Accepted
- Date: 2026-07-16
- Deciders: OpenCarDev maintainers
- Technical Story: Projection reliability and compatibility across clients/devices
- Tags: video, transport, webrtc, fallback, reliability

## Context

Video projection reliability varies by environment and client capability.

Observed constraints:
- WebRTC provides better latency and quality when negotiation/path is healthy.
- Some environments require fallback behavior when WebRTC negotiation fails or stalls.
- Clients and deployments may differ in supported media stacks.

## Decision

Adopt a dual-transport video strategy:
- Primary transport: WebRTC.
- Fallback transport: WebSocket JPEG.
- Core reports active/requested mode and status so clients can make deterministic UI decisions.

Out of scope:
- Removing either transport in current phase.

## Options Considered

### Option A: WebRTC only
- Description: Single modern transport path.
- Pros: Efficient media transport, lower latency under ideal conditions.
- Cons: Negotiation fragility can cause hard failures without fallback.
- Why not chosen: Insufficient resilience for heterogeneous deployments.

### Option B: WebSocket JPEG only
- Description: Simple frame streaming over WS.
- Pros: Simpler signaling model.
- Cons: Higher bandwidth/CPU, worse latency/quality trade-offs.
- Why not chosen: Performance and quality ceiling too low as sole transport.

### Option C: WebRTC primary + WS JPEG fallback (chosen)
- Description: Prefer WebRTC, retain fallback for resilience.
- Pros: Best reliability envelope across diverse environments.
- Cons: More state handling and mode observability required.
- Why chosen: Balances performance and operational resilience.

## Rationale

A layered transport strategy prevents single-path failure from becoming total projection loss, while preserving high-quality path when available.

## Consequences

### Positive
- Higher probability of successful projection under mixed conditions.
- Better recovery options during negotiation issues.

### Negative
- Increased state complexity across core and clients.
- Requires careful diagnostics/logging to avoid mode confusion.

### Neutral / Follow-on
- Contract must clearly expose requested vs active transport mode.

## Compatibility and Migration

- Existing clients can continue with existing mode handling.
- Capability negotiation should indicate supported video transports.
- Future clients may opt out of unsupported transports via capability declarations.

## Security and Reliability Considerations

- Mode transitions must be logged with explicit reason fields.
- Recovery logic must avoid renegotiation storms and disconnect loops.
- Health/status signals should include projection readiness and transport state.

## Implementation Notes

Core areas:
- Android Auto service transport selection and status publication.
- WebSocket status publishing for transport mode fields.

Client areas:
- Render path selection based on active transport and readiness signals.

## Validation

- Tests for startup with WebRTC success path.
- Tests for controlled fallback to WS JPEG.
- Regression tests for reconnect/renegotiation churn avoidance.

## Open Questions

- Should transport preference be profile-configurable per client kind?
- Should fallback thresholds differ by hardware class?

## References

- ADR-0001
- ADR-0002
- `docs/ADR/ADR-TEMPLATE.md`
