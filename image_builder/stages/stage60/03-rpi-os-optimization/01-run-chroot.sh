#!/bin/bash -e

echo "Stage60/03: Activating Raspberry Pi OS optimizations"

sysctl --system
systemctl daemon-reload

echo "Stage60/03: Optimizations activated"
