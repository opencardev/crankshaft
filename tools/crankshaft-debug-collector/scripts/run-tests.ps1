#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Run the project test suite from any working directory.
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Resolve-Path (Join-Path $scriptDir '..')

$env:PYTHONPATH = Join-Path $projectRoot 'src'
python -m unittest discover -s (Join-Path $projectRoot 'tests') -p "test_*.py" -v
