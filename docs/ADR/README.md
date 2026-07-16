# Architecture Decision Records (ADR)

This directory contains Architecture Decision Records for the Crankshaft project.

## Purpose

ADRs document important architecture decisions with context, alternatives, trade-offs, and consequences.

Use ADRs when a decision:
- Changes system boundaries or contracts.
- Affects multiple repositories or teams.
- Introduces long-term operational or compatibility impacts.
- Is difficult or expensive to reverse.

## How To Create a New ADR

1. Copy `ADR-TEMPLATE.md`.
2. Create a new file with the next number:
   - `ADR-0001-short-kebab-title.md`
3. Fill all required sections.
4. Link related PRs/issues/diagrams.
5. Open PR with ADR in the same change set as implementation (or before implementation for major decisions).

## ADR Index

- ADR-0001: Core/Client Split Architecture
- ADR-0002: WebSocket as Core-Client Contract Transport
- ADR-0003: Dual Video Transport Strategy (WebRTC + WebSocket JPEG)

## Status Model

- `Proposed`: Draft under discussion.
- `Accepted`: Approved and authoritative.
- `Superseded`: Replaced by a newer ADR.
- `Deprecated`: Decision retired without a direct replacement.

When superseding an ADR:
- Keep the original file.
- Update its status to `Superseded`.
- Add reference to the replacing ADR.

## Repository Scope

Crankshaft currently spans multiple repositories (for example core and UI variants).

ADRs in this folder should:
- Capture cross-repository architectural intent.
- Define stable contracts at system boundaries.
- Avoid implementation details specific to one UI unless explicitly scoped.

## Review Checklist

Before marking an ADR `Accepted`, verify:
- Problem context is clear and evidence-based.
- At least two alternatives are evaluated.
- Compatibility and migration behavior are explicit.
- Operational validation and rollback criteria are defined.
- Cross-repo impact is identified.
