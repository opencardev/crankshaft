# crankshaft Documentation Index

Type: monorepo with 5 parts
Primary Language: C++
Architecture: backend + desktop UI + infra pipeline + cli + protocol library
Last Updated: 2026-07-21

## Project Overview

Crankshaft transforms Raspberry Pi into an Android Auto headunit platform with a C++ backend, Qt/QML UI, infra image builds, and support tooling.

## Project Structure

### core

- Type: backend
- Location: src/crankshaft-core
- Key docs: architecture-core.md, development-guide-core.md, api-contracts-core.md, data-models-core.md

### ui

- Type: desktop
- Location: src/crankshaft-ui-slim
- Key docs: architecture-ui.md, development-guide-ui.md, component-inventory-ui.md

### tools

- Type: cli
- Location: tools/crankshaft-debug-collector
- Key docs: architecture-tools.md, development-guide-tools.md

### image

- Type: infra
- Location: image_builder
- Key docs: architecture-image.md, development-guide-image.md

### aasdk

- Type: library
- Location: src/aasdk
- Key docs: architecture-aasdk.md, development-guide-aasdk.md

## Core Generated Documentation

- [Project Overview](./project-overview.md)
- [Source Tree Analysis](./source-tree-analysis.md)
- [Integration Architecture](./integration-architecture.md)
- [Deployment Guide](./deployment-guide.md)
- [Contribution Guide](./contribution-guide.md)
- [Project Parts Metadata](./project-parts.json)

## Part-Specific Documentation

- [Architecture - core](./architecture-core.md)
- [Development Guide - core](./development-guide-core.md)
- [API Contracts - core](./api-contracts-core.md)
- [Data Models - core](./data-models-core.md)
- [Component Inventory - core](./component-inventory-core.md)

- [Architecture - ui](./architecture-ui.md)
- [Development Guide - ui](./development-guide-ui.md)
- [Component Inventory - ui](./component-inventory-ui.md)

- [Architecture - tools](./architecture-tools.md)
- [Development Guide - tools](./development-guide-tools.md)

- [Architecture - image](./architecture-image.md)
- [Development Guide - image](./development-guide-image.md)

- [Architecture - aasdk](./architecture-aasdk.md)
- [Development Guide - aasdk](./development-guide-aasdk.md)

## Existing Documentation Inventory

- [Root README](../README.md)
- [Core docs README](../src/crankshaft-core/docs/README.md)
- [Core contributing](../src/crankshaft-core/docs/CONTRIBUTING.md)
- [UI docs README](../src/crankshaft-ui-slim/docs/README.md)
- [UI contributing](../src/crankshaft-ui-slim/docs/CONTRIBUTING.md)
- [Debug collector architecture](../tools/crankshaft-debug-collector/docs/ARCHITECTURE.md)
- [AASDK docs README](../src/aasdk/docs/README.md)
- [ADR Index](./ADR/README.md)

## Getting Started

1. Read project-overview.md for architecture context.
2. Use architecture-*.md and development-guide-*.md for part-specific work.
3. For UI/backend contract changes, review api-contracts-core.md and integration-architecture.md first.
4. For brownfield planning, use this index as the primary retrieval entrypoint.
