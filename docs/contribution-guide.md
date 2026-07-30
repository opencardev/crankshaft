# Contribution Guide (Consolidated)

This summary is consolidated from existing project contribution docs.

## General Workflow

1. Create focused branches for one logical change.
2. Keep commits scoped and descriptive.
3. Re-run quality and tests before PR.
4. Include risk and verification evidence in PR body.

## core Expectations

- Preserve architecture and naming patterns.
- Prefer targeted changes over broad refactors.
- Maintain stable public behavior unless contract change is explicit.
- Add or update tests when behavior changes.

## Typical Pre-PR Commands

core:

```bash
cd src/crankshaft-core
CODE_QUALITY=ON FORMAT_CHECK=ON BUILD_TESTS=ON ./build.sh --clean
```

ui:

```bash
cd src/crankshaft-ui-slim
CODE_QUALITY=ON FORMAT_CHECK=ON ./build.sh --clean
```

tools:

```bash
cd tools/crankshaft-debug-collector
uv run python -m unittest discover -s tests -p "test_*.py" -v
```

## Report Quality

Issue/PR submissions should include environment, repro steps, expected/actual behavior, and relevant logs.
