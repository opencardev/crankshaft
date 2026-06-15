#!/usr/bin/env bash
set -euo pipefail

# Run the project test suite from any working directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

export PYTHONPATH="${PROJECT_ROOT}/src"
python -m unittest discover -s "${PROJECT_ROOT}/tests" -p "test_*.py" -v
