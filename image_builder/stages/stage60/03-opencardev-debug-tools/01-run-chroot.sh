#!/bin/bash -e

# Install uv and use it to install the Crankshaft debug collector package.
#
# Why uv instead of plain pip?
# - uv respects pyproject.toml entry points, so the [project.scripts] key in
#   crankshaft-debug-collector/pyproject.toml creates /usr/local/bin/crankshaft-debug-collect
#   exactly as intended, without a hand-rolled sys.path wrapper.
# - uv is significantly faster than pip for repeated image builds.
# - uv is the project's declared toolchain, keeping dev and image environments consistent.

echo "Stage60/03: Installing uv"

# The official uv installer script honours UV_INSTALL_DIR to set the target
# directory. Placing the binary in /usr/local/bin makes it available on PATH
# for all users including root and any future image scripts.
export UV_INSTALL_DIR=/usr/local/bin
curl -LsSf https://astral.sh/uv/install.sh | sh

echo "Stage60/03: uv installed at $(command -v uv)"

echo "Stage60/03: Installing crankshaft-debug-collector package"

# Install the staged project into the system Python environment.
# --system allows installation outside a virtual environment which is appropriate
# for an embedded system image where the entire OS is the "environment".
# The [project.scripts] entry point from pyproject.toml will be written to
# the system Python bin directory (typically /usr/local/bin).
uv pip install /usr/share/crankshaft/debug-collector

echo "Stage60/03: Debug collector installed"
echo "  - entry point: $(command -v crankshaft-debug-collect)"