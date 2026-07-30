# Architecture - image (image_builder)

## Executive Summary

image contains infrastructure code to build Raspberry Pi images with Crankshaft pre-installed and pre-configured.

## Technology Stack

- Shell scripts
- GitHub Actions workflows
- pi-gen integration (custom stage60 overlay)

## Architecture Pattern

Pipeline overlay pattern: upstream pi-gen + repository-maintained custom stage and config template.

## Key Components

- pi-gen-stages/config-template: build-time variableized config
- stages/stage60/*: ordered customization phases (repo setup, tweaks, packages, debug tools, optimizations, service enablement)
- scripts/build-docker*.sh: local/CI helper wrappers
- scripts/validate-image.sh: post-build validation helper
- scripts/generate-build-metadata.sh: traceability metadata output

## CI/Release Integration

- .github/workflows/build-pi-gen-lite.yml builds armhf and arm64 images
- .github/workflows/ci.yml orchestrates version metadata + image workflow + summaries
