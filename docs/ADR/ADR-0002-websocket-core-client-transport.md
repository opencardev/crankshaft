# ADR-0002: WebSocket as Core-Client Contract Transport

- Status: Accepted
- Date: 2026-07-16
- Deciders: OpenCarDev maintainers
- Technical Story: Contract unification across multiple UI clients
- Tags: websocket, transport, api, contracts

## Context

Core and clients need a transport that supports:
- Bi-directional command/event communication.
- Real-time status updates.
- Compatibility with local and remote UI processes.

The platform already uses WebSocket for status and control messaging.

## Decision

Use WebSocket as the primary Core/Client contract transport.

Protocol model:
- Message envelope types: subscribe, unsubscribe, publish, service_command, admin_api, client_hello.
- Topic-based pub/sub for state/events.
- Explicit client hello for version/protocol/capability negotiation.

Out of scope:
- Replacing WS with gRPC or REST for real-time control in this phase.

## Options Considered

### Option A: WebSocket pub/sub + command envelopes (chosen)
- Description: Keep and formalize existing WS model.
- Pros: Low migration cost, event-friendly, already operational.
- Cons: Requires schema discipline and contract tests.
- Why chosen: Best fit for current architecture and real-time needs.

### Option B: REST-only control plane
- Description: HTTP endpoints only; polling for status.
- Pros: Simple request/response semantics.
- Cons: Poor real-time ergonomics; noisy polling; weaker event model.
- Why not chosen: Inferior for event-driven media/control workloads.

### Option C: gRPC streaming
- Description: Replace WS with typed RPC/streaming.
- Pros: Strong typing and generated clients.
- Cons: High migration cost; ecosystem complexity for current deployment model.
- Why not chosen: Not justified for current maturity and constraints.

## Rationale

Formalizing the existing WS transport captures prior investment while enabling protocol governance and multi-client compatibility.

## Consequences

### Positive
- Stable cross-repo contract surface.
- Supports multiple clients with negotiated capabilities.
- Works for both local and remote client processes.

### Negative
- Contract drift risk if schemas are undocumented.
- Requires robust validation and observability.

### Neutral / Follow-on
- Need published protocol docs and test fixtures.

## Compatibility and Migration

- Introduce `client_hello` in permissive mode first.
- Add configurable enforcement switches in core.
- Roll out strict enforcement after client adoption.

## Security and Reliability Considerations

- Validate message shape/type before handling.
- Restrict sensitive admin routes (localhost-only for admin API).
- Include negotiated client metadata in logs/status for supportability.

## Implementation Notes

Core ownership:
- `src/crankshaft-core/src/services/websocket/WebSocketServer.*`

Client ownership:
- `src/crankshaft-ui-slim/src/CoreClient.*`
- Future clients implement same hello/capability model.

## Validation

- Unit/integration tests for invalid message rejection and contract acceptance.
- Runtime verification through status/admin contract introspection.

## Open Questions

- Should topic authorization vary by capability profile?
- Should contracts be versioned by namespace or envelope version only?

## References

- ADR-0001
- ADR-0003
- `docs/ADR/ADR-TEMPLATE.md`
