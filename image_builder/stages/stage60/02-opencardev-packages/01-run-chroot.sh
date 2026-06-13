#!/bin/bash -e

echo "Stage60/02: Validating OpenCarDev runtime package availability"

export DEBIAN_FRONTEND=noninteractive

apt-get update

for pkg in \
    libaasdk \
    crankshaft-core \
    crankshaft-ui-slim \
    pipewire \
    pipewire-alsa \
    pipewire-bin \
    pipewire-pulse \
    wireplumber \
    pulseaudio-utils \
    libspa-0.2-bluetooth; do
    if ! apt-cache policy "${pkg}" | grep -q "Candidate:"; then
        echo "Package metadata not found for ${pkg}" >&2
        exit 1
    fi
done

echo "Stage60/02: Packages will be installed via 02-packages manifest"

echo "Stage60/02: OpenCarDev package source validation completed"
