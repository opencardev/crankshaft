#!/bin/sh
# Helper script to gather HDMI/display and Android Auto video diagnostics on Raspberry Pi.

set -eu

OUTPUT_DIR="${1:-/tmp/crankshaft-hdmi-debug}"
mkdir -p "$OUTPUT_DIR"

run() {
  echo "=== $1 ==="
  shift
  echo "$@"
  echo
  "$@" > "$OUTPUT_DIR/$1.txt" 2>&1 || true
}

run uname -a uname -a
run uptime uptime
run vcgencmd_version vcgencmd version
run vcgencmd_get_lcd_info vcgencmd get_lcd_info
run vcgencmd_display_power vcgencmd display_power
run vcgencmd_measure_temp vcgencmd measure_temp
run tvservice_status tvservice -s
run tvservice_cea_modes tvservice -m CEA
run tvservice_dmt_modes tvservice -m DMT
run tvservice_connected tvservice -n
run boot_config cat /boot/config.txt

run drm_connectors sh -c 'find /sys/class/drm -maxdepth 2 -type f | sort | while IFS= read -r f; do echo "=== $f ==="; cat "$f" 2>/dev/null; done'
run graphics_connectors sh -c 'find /sys/class/graphics -maxdepth 2 -type f | sort | while IFS= read -r f; do echo "=== $f ==="; cat "$f" 2>/dev/null; done'

run syslog sh -c "journalctl -b --no-pager | grep -Ei 'hdmi|drm|vc4|vcsm|gpu|display|egl|raspberry|vcgencmd|qpa|eglfs|gstreamer|gst|video|aa|android auto|aasdk' || true"
run core_video sh -c "journalctl -u crankshaft-core -b --no-pager | grep -Ei 'video|aa|android auto|aasdk|usb|display|drm|egl|h264|decode|render|gst|gstreamer' || true"
run ui_video sh -c "journalctl -u crankshaft-ui-slim -b --no-pager | grep -Ei 'video|display|egl|drm|qt|eglfs|render' || true"
run ui_display_setup journalctl -u crankshaft-ui-slim-display-setup -b --no-pager

run list_services sh -c "systemctl --type=service --state=running --no-pager | egrep -i 'crankshaft|pipewire|wireplumber|pulseaudio|bluetooth|display|gdm|lightdm|sddm|vnc|x11' || true"
run lsusb lsusb
run usb_tree lsusb -t
run ps_audio sh -c "ps -ef | egrep -i 'pipewire|wireplumber|pulseaudio|bluez|bluetoothd|gst|gstreamer|qt|crankshaft|aasdk|android auto' || true"

echo "Collecting core debug logs"
journalctl -u crankshaft-core -b --no-pager > "$OUTPUT_DIR/journal_core_full.txt" 2>&1 || true

if command -v vcgencmd >/dev/null 2>&1; then
  echo "vcgencmd available"
else
  echo "vcgencmd missing"
fi

echo "HDMI debug collection complete: $OUTPUT_DIR"
