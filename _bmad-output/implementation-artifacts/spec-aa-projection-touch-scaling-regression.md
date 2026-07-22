---
title: 'Restore AA Projection Touch Mapping After Scaling/Resolution Regression'
type: 'bugfix'
created: '2026-07-22T22:54:46+01:00'
status: 'done'
baseline_commit: '5281137'
review_loop_iteration: 0
context:
  - '{project-root}/_bmad-output/project-context.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Touch interaction works in the Qt app shell but does not work reliably in the Android Auto projection surface, across both VNC and physical HDMI/DSI runs. Evidence points to a regression introduced while hardening flicker behavior, where projection touch mapping and resolution/scaling logic now operate in inconsistent coordinate spaces.

**Approach:** Re-align AA projection touch mapping to a single coordinate contract end-to-end (QML surface mapping -> TouchEventForwarder scaling -> core touch ingestion), while preserving anti-flicker protections (no per-frame resolution publish storms). Add focused regression tests and runtime observability to prove tap/gesture accuracy under aspect-fit and transport mode transitions.

## Boundaries & Constraints

**Always:**
- Keep this as a single user-facing goal: accurate AA projection touch input.
- Preserve existing flicker mitigations, especially guards that avoid per-frame `android-auto/display/resolution` publishes.
- Keep coordinate conversions deterministic and bounded at every stage.
- Ensure behavior is consistent in both VNC and physical display modes.
- Keep changes minimal and localized to touch coordinate handling and related tests/logs.

**Ask First:**
- Any schema change to `android-auto/touch` payloads consumed by other clients.
- Any change that reintroduces normalized (0..1) coordinate publishing from UI to core.
- Any broad rendering-path refactor beyond touch mapping and immediate projection geometry calculations.

**Never:**
- Re-enable frame-rate-driven display resolution publication.
- Add transport-specific touch behavior branches that diverge WebRTC vs JPEG touch math.
- Introduce display-mode-specific hacks (VNC-only or HDMI-only touch offsets).
- Expand scope into unrelated AA reconnect/renegotiation policy.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Standard projection tap | AA projection visible; user taps center | Tap maps to AA center-equivalent coordinates and triggers expected AA UI action | If mapping inputs are invalid, clamp to bounds and log at debug/warn level |
| Aspect-fit with letterboxing | Projection rendered with preserve-aspect-fit and non-zero side/top bars | Touch points map using actual frame rect, not container rect, with no systematic offset | If frame rect invalid, safely return bounded default and avoid crash |
| Runtime surface change | WebRTC active state or rendered content rect changes | Display size + mapping basis remain internally consistent after transition | If geometry is transiently unavailable, hold bounded mapping and recover on next valid update |
| Out-of-range touch input | Raw mapped x/y negative or beyond frame extents | Coordinates clamp to valid AA bounds before publish | Emit debug trace for clamped path; continue processing |
| Resolution publish stability | High frame-rate video updates | Core receives resolution updates only when effective resolution actually changes | If repeated same-size updates attempted, suppress publish silently |

</frozen-after-approval>

## Code Map

- `src/crankshaft-ui-slim/src/qml/AAProjectionView.qml` -- Projection-surface geometry, frame-rect mapping, touch forwarding entrypoint.
- `src/crankshaft-ui-slim/src/qml/main.qml` -- Active in-app projection surface and touch mapping logic used in production flow.
- `src/crankshaft-ui-slim/src/TouchEventForwarder.cpp` -- Display-size publication guard and coordinate scaling before touch publish.
- `src/crankshaft-ui-slim/src/TouchEventForwarder.h` -- Touch point serialization contract (`scaledPosition` to payload).
- `src/crankshaft-ui-slim/src/CoreClient.cpp` -- WebSocket `android-auto/touch` payload publishing.
- `src/crankshaft-core/src/services/websocket/WebSocketServer.cpp` -- Touch payload ingestion and final x/y conversion to service calls.
- `src/crankshaft-core/src/services/android_auto/RealAndroidAutoService.cpp` -- Final bounded touch injection into AA input channel.
- `src/crankshaft-ui-slim/src/tests/test_core_mock_integration.cpp` -- Existing integration harness for touch and transport-related regressions.

## Tasks & Acceptance

**Execution:**
- [x] `src/crankshaft-ui-slim/src/qml/AAProjectionView.qml` -- Unify fallback geometry basis between `updateTouchForwarderDisplaySize()` and `mapToProjectionCoordinates()` so both use the same rendered-surface reference under aspect-fit -- Prevents coordinate-space drift.
- [x] `src/crankshaft-ui-slim/src/qml/main.qml` -- Verify and align projection touch mapping math with AAProjectionView behavior, including frame rect offsets and clamping -- Prevents divergence between duplicated projection paths.
- [x] `src/crankshaft-ui-slim/src/TouchEventForwarder.cpp` -- Preserve deduplicated resolution publish guard while ensuring published display size matches mapping coordinate space used for touch scaling -- Keeps anti-flicker behavior while restoring correct touch.
- [x] `src/crankshaft-ui-slim/src/CoreClient.cpp` -- Confirm outbound touch payload remains absolute pixel coordinates and action mapping remains stable (`press/move/release/cancel`) -- Avoids contract drift into ambiguous normalized values.
- [x] `src/crankshaft-core/src/services/websocket/WebSocketServer.cpp` -- Validate ingestion remains robust to absolute coordinates and does not misclassify normal absolute values as normalized fallback -- Ensures end-to-end consistency.
- [x] `src/crankshaft-ui-slim/src/tests/test_core_mock_integration.cpp` -- Add/adjust regression coverage for touch mapping consistency under aspect-fit and display-size transitions -- Prevents reintroduction of offset/dead-touch behavior.
- [x] `src/crankshaft-ui-slim/src/tests` (existing suites) -- Run offscreen integration and full UI tests after patch -- Confirms no regressions in session/transport behavior.

**Acceptance Criteria:**
- Given AA projection is visible with preserve-aspect-fit rendering, when a user taps a point on the displayed frame, then the received AA touch point corresponds to the same relative location on the phone UI with no systematic offset.
- Given projection frame geometry changes (content rect/painted size transition), when touch events continue during and after the transition, then touch mapping remains bounded and accurate without becoming unresponsive.
- Given steady video frame updates, when projection resolution does not effectively change, then repeated duplicate `android-auto/display/resolution` publishes do not occur.
- Given the same AA session is tested on VNC and physical HDMI/DSI modes, when tapping key UI targets in projection, then touch behavior is equivalent and functional across modes.
- Given touch coordinates are near or beyond surface boundaries, when forwarded through UI and core pipelines, then coordinates are clamped safely and do not crash or drop the session.

## Spec Change Log

## Design Notes

- The critical invariant is coordinate-space coherence: the rectangle used to map raw pointer input must be the same rectangle basis used to derive display-size scaling sent to touch forwarder/core.
- The fix should prefer consolidating duplicated projection mapping logic (or keeping strict parity checks) rather than introducing mode-specific compensation factors.
- Preserve current anti-flicker strategy by continuing to publish display resolution only on meaningful size changes.

## Verification

**Commands:**
- `cd src/crankshaft-ui-slim && QT_QPA_PLATFORM=offscreen ./build.sh` -- expected: build succeeds; all ui-slim tests pass.
- `cd src/crankshaft-ui-slim/build-release && QT_QPA_PLATFORM=offscreen ctest --output-on-failure -R test_core_mock_integration` -- expected: integration tests pass, including touch-forwarding assertions.
- `cd src/crankshaft-ui-slim/build-release && QT_QPA_PLATFORM=offscreen ctest --output-on-failure` -- expected: full suite passes with 0 failures.

**Manual checks (runtime):**
- In active AA projection, tap center/corners and verify matching in-phone UI hit targets.
- Verify no visible projection flicker increase after touch interaction bursts.
- Confirm ui/core logs show bounded touch coordinates and no touch-path warnings during normal interaction.

## Suggested Review Order

- Start where coordinate-space alignment is enforced in projection sizing.
  [`AAProjectionView.qml:70`](../../src/crankshaft-ui-slim/src/qml/AAProjectionView.qml#L70)

- Confirm mapped width/height are forwarded as the touch scaling basis.
  [`AAProjectionView.qml:74`](../../src/crankshaft-ui-slim/src/qml/AAProjectionView.qml#L74)

- Validate full mapping path context around the frame-rect calculations.
  [`AAProjectionView.qml:63`](../../src/crankshaft-ui-slim/src/qml/AAProjectionView.qml#L63)
