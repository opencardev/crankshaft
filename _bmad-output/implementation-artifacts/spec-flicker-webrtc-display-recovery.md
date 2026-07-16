---
title: 'Android Auto Projection Recovery When WebRTC Video Stalls'
type: 'bugfix'
created: '2026-07-11T00:00:00Z'
status: 'in-review'
baseline_commit: '9fdf4908f85913c42927095fd17187dbf9b2850a'
review_loop_iteration: 0
context:
  - '{project-root}/src/crankshaft-core/docs/bugfix-video-flicker-recovery-plan.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** The flicker mitigation work reduced display resolution storms, but Android Auto projection can still appear blank in UI Slim when transport is unstable and WebRTC signaling remains selected. The UI remains in WebRTC mode even when WebRTC media is not producing visible frames, so the JPEG fallback path is not used.

**Approach:** Implement UI-Slim-side WebRTC media-health gating and automatic fallback-to-JPEG rendering when WebRTC is selected but not producing frames. Keep existing core transport recovery and resolution protections untouched, and restore WebRTC rendering automatically once media health returns.

## Boundaries & Constraints

**Always:**
- Preserve single user-facing goal: projection stays visible and recovers smoothly during transient USB or transport instability.
- Keep existing resolution-storm protections intact in UI Slim and avoid any per-frame resolution publish loops.
- Keep display-resolution behavior stable: no repeated display renegotiation when resolution is unchanged.
- Preserve current core behavior for transient receive and intertwined-channel recovery; this spec does not redesign transport policy.
- Add observable UI-Slim logs for WebRTC stalled, fallback engaged, and WebRTC restored transitions.
- Ensure fallback behavior is deterministic and reversible: return to WebRTC rendering once media health is restored.

**Ask First:**
- Any change that permanently switches default transport preference away from WebRTC.
- Any channel-status payload schema change consumed by external clients.
- Any decision to disable WebRTC pipeline initialization entirely on target devices.

**Never:**
- Reintroduce frame-rate-driven display resolution updates.
- Implement HDMI mode switching as a recovery strategy.
- Hide projection entirely when a fallback frame path is available.
- Couple fallback behavior to manual user interaction for normal transient recovery.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| WebRTC healthy | Connected session, transport mode reports webrtc, receiver has recent decoded frames | UI renders WebRTC projection surface; JPEG fallback remains hidden | N/A |
| WebRTC selected but media stalled | Connected session, mode remains webrtc, receiver has no frames for stall timeout | UI automatically shows JPEG projection frame path while keeping session connected | Log stall detection and set local fallback state |
| WebRTC receiver recoverable error | Receiver reports recoverable pipeline/signaling error while connected | UI transitions to fallback rendering without full app reset | Log error category and keep recovery loop active |
| WebRTC becomes healthy again | Previously stalled/error state clears and receiver frame flow resumes | UI restores WebRTC surface and hides fallback | Log recovery transition |
| Build without WebRTC support | UI Slim built without required WebRTC runtime support | UI avoids blank WebRTC lock-in and uses JPEG projection path | Surface clear diagnostic error and health=false state |

</frozen-after-approval>

## Code Map

- src/crankshaft-ui-slim/src/qml/main.qml -- Active projection rendering decision logic, WebRTC/JPEG visibility gates.
- src/crankshaft-ui-slim/src/AndroidAutoWebRtcReceiver.h -- Receiver-facing health properties and signal contracts for QML/session.
- src/crankshaft-ui-slim/src/AndroidAutoWebRtcReceiver.cpp -- Runtime health tracking, stall detection, recoverable error state transitions.
- src/crankshaft-ui-slim/src/AndroidAutoWebRtcSession.cpp -- Session active-state semantics; currently mode-driven and needs media-readiness coupling.
- src/crankshaft-ui-slim/src/AndroidAutoFacade.cpp -- Bridge between CoreClient/session and QML-facing projection state.
- src/crankshaft-ui-slim/src/CoreClient.cpp -- Channel-status ingestion and transport mode propagation.
- src/crankshaft-ui-slim/src/qml/AAProjectionView.qml -- Secondary projection component that must stay aligned with active logic to avoid drift.
- src/crankshaft-core/docs/bugfix-video-flicker-recovery-plan.md -- Source plan and constraints validated during planning.

## Tasks & Acceptance

**Execution:**
- [x] src/crankshaft-ui-slim/src/AndroidAutoWebRtcReceiver.h -- Add explicit properties/signals for media-health state (healthy, stalled, lastFrameTimestampMs, recoverableError) -- Allows QML and session to decide rendering from media reality, not mode alone.
- [x] src/crankshaft-ui-slim/src/AndroidAutoWebRtcReceiver.cpp -- Implement health state transitions from pipeline events and frame activity timeout; classify recoverable runtime errors -- Prevents silent blank projection when WebRTC is selected but non-functional.
- [x] src/crankshaft-ui-slim/src/AndroidAutoWebRtcSession.cpp -- Rework active-state derivation to require both mode intent and receiver readiness/health -- Stops false active state that locks UI into blank WebRTC surface.
- [x] src/crankshaft-ui-slim/src/qml/main.qml -- Update projection visibility gates to use receiver/session health and automatically reveal JPEG fallback when WebRTC is stalled or errored -- Ensures continuous display during transport instability.
- [x] src/crankshaft-ui-slim/src/qml/AAProjectionView.qml -- Align logic with main projection behavior or explicitly mark inactive to prevent future divergence -- Reduces maintenance risk and repeated regressions.
- [x] src/crankshaft-ui-slim/src/CoreClient.cpp -- Preserve stable mode/status propagation during transient ready-flag changes and expose required session inputs to facade -- Ensures fallback behavior does not regress existing connection handling.
- [x] src/crankshaft-ui-slim/src/AndroidAutoFacade.cpp -- Surface WebRTC health and fallback eligibility in QML-facing API -- Enables clear declarative rendering decisions.
- [x] src/crankshaft-ui-slim/src/tests/test_core_mock_integration.cpp -- Add tests for mode=webrtc with stalled/no-media conditions and fallback restoration -- Verifies integration behavior for the reported defect.
- [x] src/crankshaft-ui-slim/src/tests/test_android_auto_facade.cpp -- Add tests for facade state transitions on WebRTC health degrade/recover -- Prevents regressions in UI-facing state mapping.

**Acceptance Criteria:**
- Given Android Auto is connected and WebRTC media is healthy, when projection runs normally, then UI Slim displays WebRTC video and does not show fallback content.
- Given Android Auto is connected and WebRTC mode remains selected, when WebRTC media stalls beyond the configured timeout, then UI Slim automatically switches visible rendering to JPEG fallback without disconnecting the session.
- Given WebRTC media has stalled and fallback is active, when WebRTC frame flow recovers, then UI Slim restores WebRTC rendering automatically and logs the recovery transition.
- Given UI Slim is built without required WebRTC runtime support, when projection becomes active, then UI Slim does not remain blank in WebRTC mode and instead renders available fallback frames with a diagnostic health reason.
- Given display resolution remains unchanged at 1920x1080 during transport instability, when recovery and fallback transitions occur, then no resolution storm or unnecessary display renegotiation is triggered.

## Spec Change Log

## Design Notes

The defect is primarily render-path gating in UI Slim. Current mode-based gating assumes signaling mode implies usable media, which is false during partial failures. The design therefore introduces a two-dimensional state model in UI state derivation:

1. Intent channel (what mode the system prefers).
2. Media-health channel (whether WebRTC is currently delivering visible media).

Rendering should follow intent only when health is good; otherwise it should follow safe fallback while preserving session continuity. This keeps user-facing projection available and avoids high-cost reconnect loops.

## Verification

**Commands:**
- cmake --build build --target crankshaft-ui-slim --config Release -- expected: ui-slim compiles and links with new health-state interfaces.
- ctest --output-on-failure -R core_mock_integration -- expected: updated UI integration tests pass.
- ctest --output-on-failure -R android_auto_facade -- expected: facade transition tests pass.

**Manual checks (if no CLI):**
- On Raspberry Pi 3, reproduce transient USB disconnect/reconnect while Android Auto is active and confirm projection stays visible via fallback then returns to WebRTC when healthy.
- Inspect logs for ordered transitions: stall detected, fallback active, recovery detected, WebRTC restored, without repeated display resolution publishes.
