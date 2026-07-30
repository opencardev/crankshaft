# Development Guide - image

## Prerequisites

- Docker and/or GitHub Actions runner context
- pi-gen host dependencies (handled in workflow for CI)

## Local Helper Scripts

```bash
./image_builder/scripts/build-docker.sh
./image_builder/scripts/build-docker-debug.sh
./image_builder/scripts/validate-image.sh
```

## CI Build Path

- Use .github/workflows/build-pi-gen-lite.yml
- Matrix targets: armhf and arm64
- Custom stage source: image_builder/stages/stage60
