# Deployment Guide

## Deployment Artifacts

- Raspberry Pi images generated through pi-gen workflow
- Package outputs from core/ui/aasdk build flows (.deb/.tgz)

## CI/CD Pipeline

Primary workflows:

- .github/workflows/ci.yml
  - version metadata
  - invokes build-pi-gen-lite workflow
  - publishes build summaries
- .github/workflows/build-pi-gen-lite.yml
  - armhf + arm64 matrix builds
  - pi-gen checkout and stage60 overlay injection
  - image artifact upload and optional release drafting

## Image Build Customization

- image_builder/pi-gen-stages/config-template controls release/suite values
- image_builder/stages/stage60 handles repo setup, package install, tuning, debug tools, and service enablement

## Typical Build Flow

1. Resolve version metadata from git
2. Prepare pi-gen with custom stage60
3. Install host build dependencies and binfmt emulation
4. Build armhf/arm64 images
5. Upload artifacts and optional release assets

## Operational Validation

Use image_builder/scripts/validate-image.sh and uploaded CI diagnostics artifacts for validation and triage.
