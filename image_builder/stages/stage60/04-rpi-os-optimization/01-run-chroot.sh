#!/bin/bash -e

echo "Stage60/04: Activating Raspberry Pi OS optimizations"

sysctl --system
systemctl daemon-reload

echo "Stage60/04: Optimizations activated"
