---
title: 'Add Settings Toggle For Touch Debug Overlay'
type: 'feature'
created: '2026-07-24T00:00:00Z'
baseline_commit: '6d66be51c0abd75bed082296ac0024b5af3cc050'
status: 'done'
review_loop_iteration: 0
context:
  - '{project-root}/_bmad-output/project-context.md'
  - '{project-root}/_bmad-output/implementation-artifacts/spec-aa-projection-touch-debug-overlay.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** The touch debug overlay already exists but can only be enabled through startup debug flags/context, which makes runtime diagnostics inconvenient for users and testers using the Settings panel.

**Approach:** Add a default-off, persisted UI toggle in Settings that enables or disables the existing overlay at runtime, and wire both projection rendering paths to the same preference while preserving current touch mapping/forwarding behavior.

## Boundaries & Constraints

**Always:**
- Keep overlay disabled by default on fresh installs and after factory reset.
- Persist user choice using the existing slim UI preferences mechanism.
- Keep overlay rendering behavior consistent between `AAProjectionView.qml` and inline projection in `main.qml`.
- Preserve current touch forwarding, coordinate mapping, event timing, and transport selection behavior.
- Preserve explicit debug startup override behavior; if debug CLI/context requests overlay, it remains enabled regardless of saved preference.
- Keep setting changes reactive at runtime without app restart.

**Ask First:**
- Any requirement to expose this setting through core/backend APIs or websocket contracts.
- Any requirement to scope visibility by build type (debug-only UI visibility).
- Any requirement to synchronize this setting across different client apps.

**Never:**
- Do not introduce backend protocol/schema changes.
- Do not move touch mapping/forwarding logic out of its current codepaths.
- Do not block pointer/touch input with overlay controls or overlay layers.
- Do not alter existing WebRTC/JPEG fallback or fullscreen-delay behaviors.
- Do not enable overlay by default.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Default startup | No stored value and no debug CLI arg | Toggle shows Off and overlay is hidden | Preference layer falls back to default `false` |
| Runtime enable via settings | User turns toggle On in Settings | Overlay becomes visible immediately on active projection surface(s) | If projection geometry is invalid, existing overlay invalid-geometry indicator remains the only diagnostic output |
| Runtime disable via settings | User turns toggle Off while overlay is visible | Overlay hides immediately without affecting active touch forwarding | N/A |
| Debug override active | App launched with `--debug-touch-overlay` or equivalent context flag and stored preference Off | Overlay remains visible; toggle may still display stored Off state but effective state is On | Log effective-source reasoning for troubleshooting if lightweight logging point is available |
| Factory reset | User performs settings factory reset | Persisted overlay preference returns to default Off | Reset path emits change signal so UI and projection bindings update |

</frozen-after-approval>

## Code Map

- `src/crankshaft-ui-slim/src/PreferencesFacade.h` -- Add new Q_PROPERTY and signals for persisted debug overlay preference.
- `src/crankshaft-ui-slim/src/PreferencesFacade.cpp` -- Add key/default/load/save/reset/corruption handling for overlay preference and emit notifications.
- `src/crankshaft-ui-slim/src/qml/settings/DisplaySettingsTab.qml` -- Add settings control card/toggle bound to `PreferencesFacade` overlay preference.
- `src/crankshaft-ui-slim/src/qml/main.qml` -- Update effective overlay enablement expression to include persisted preference for inline projection path.
- `src/crankshaft-ui-slim/src/qml/AAProjectionView.qml` -- Update effective overlay enablement expression to include persisted preference for reusable projection component path.

## Tasks & Acceptance

**Execution:**
- [x] `src/crankshaft-ui-slim/src/PreferencesFacade.h` -- Add `debugTouchOverlayEnabled` property (read/write + notify) and matching signal declarations -- Exposes persisted state to QML and keeps behavior aligned with existing facade patterns.
- [x] `src/crankshaft-ui-slim/src/PreferencesFacade.cpp` -- Implement default `false` setting key, getter/setter, persistence load/save, reset-default behavior, and corruption fallback semantics -- Ensures deterministic persistence lifecycle.
- [x] `src/crankshaft-ui-slim/src/qml/settings/DisplaySettingsTab.qml` -- Add a Display tab control (switch-style toggle or equivalent project-consistent control) bound to `preferencesFacade.debugTouchOverlayEnabled` -- Provides user-facing runtime control.
- [x] `src/crankshaft-ui-slim/src/qml/main.qml` and `src/crankshaft-ui-slim/src/qml/AAProjectionView.qml` -- Refactor effective overlay-on computation to: `debugOverride || persistedPreference` -- Makes settings control effective without breaking explicit debug override.
- [x] `src/crankshaft-ui-slim` build/test flow -- Run build and available tests to confirm no regressions and no property binding/runtime errors -- Verifies safe integration.

**Acceptance Criteria:**
- Given a clean profile with no stored overlay preference, when UI starts without debug override, then debug overlay is hidden and Settings shows toggle Off.
- Given Settings toggle is switched On during projection, when user interacts with projection, then existing overlay visuals appear immediately and touch forwarding behavior remains unchanged.
- Given Settings toggle is switched Off during projection, when interactions continue, then overlay visuals disappear immediately and touch forwarding remains unchanged.
- Given app starts with explicit debug overlay override, when stored preference is Off, then overlay remains visible due to override and no crash/binding warning occurs.
- Given user triggers factory reset, when reset completes, then overlay preference returns to Off and subsequent launch starts with overlay hidden unless override is present.
- Given either projection rendering path is used (`main.qml` inline or `AAProjectionView.qml` component), when effective overlay state is On, then both paths render equivalent diagnostics semantics.

## Spec Change Log

## Design Notes

- Effective state should remain a pure derived expression in QML:
  - `debugOverrideFromArgsOrContext`
  - `persistedOverlayPreference`
  - `effectiveOverlayEnabled = debugOverrideFromArgsOrContext || persistedOverlayPreference`
- Keep persisted preference naming explicit and scoped with existing key conventions (e.g., `slim_ui.debug.touchOverlayEnabled`) to avoid cross-feature collisions.
- Follow existing settings UX rhythm in Display tab using `SettingsCard` and controls already used for rotation/theme/brightness.

## Verification

**Commands:**
- `cd src/crankshaft-ui-slim && QT_QPA_PLATFORM=offscreen ./build.sh` -- expected: build succeeds and existing tests complete without new failures.
- `cd src/crankshaft-ui-slim/build-release && QT_QPA_PLATFORM=offscreen ctest --output-on-failure` -- expected: no regression failures attributable to new preference/property wiring.

**Manual checks (if no CLI):**
- Open Settings > Display and toggle debug overlay On/Off while projection is visible; verify immediate visual response.
- Restart app after enabling toggle; verify overlay remains enabled by preference.
- Run with debug override active and toggle Off; verify overlay stays visible due to override.
- Trigger factory reset; verify toggle returns Off and overlay is hidden on next run without override.

## Suggested Review Order

**Preference Contract**

- Start at the persisted settings API exposed to QML.
  [`PreferencesFacade.h:53`](../../src/crankshaft-ui-slim/src/PreferencesFacade.h#L53)

- Confirm signal wiring and mutable state backing the property.
  [`PreferencesFacade.h:122`](../../src/crankshaft-ui-slim/src/PreferencesFacade.h#L122)

**Persistence Lifecycle**

- Verify key/default declarations and naming scope.
  [`PreferencesFacade.cpp:31`](../../src/crankshaft-ui-slim/src/PreferencesFacade.cpp#L31)

- Check setter idempotency and save-on-change behavior.
  [`PreferencesFacade.cpp:117`](../../src/crankshaft-ui-slim/src/PreferencesFacade.cpp#L117)

- Confirm load/save/reset paths include the new preference.
  [`PreferencesFacade.cpp:222`](../../src/crankshaft-ui-slim/src/PreferencesFacade.cpp#L222)

**Projection Behavior Binding**

- Review effective overlay state composition in inline projection path.
  [`main.qml:408`](../../src/crankshaft-ui-slim/src/qml/main.qml#L408)

- Confirm stale diagnostic state clears when overlay is disabled.
  [`main.qml:597`](../../src/crankshaft-ui-slim/src/qml/main.qml#L597)

- Verify identical effective-state wiring in reusable projection component.
  [`AAProjectionView.qml:49`](../../src/crankshaft-ui-slim/src/qml/AAProjectionView.qml#L49)

- Confirm stale diagnostic state clears in component path too.
  [`AAProjectionView.qml:160`](../../src/crankshaft-ui-slim/src/qml/AAProjectionView.qml#L160)

**Settings UX**

- Check new Display-tab control and binding to facade property.
  [`DisplaySettingsTab.qml:114`](../../src/crankshaft-ui-slim/src/qml/settings/DisplaySettingsTab.qml#L114)

- Ensure no-op toggles are prevented when facade is unavailable.
  [`DisplaySettingsTab.qml:131`](../../src/crankshaft-ui-slim/src/qml/settings/DisplaySettingsTab.qml#L131)
