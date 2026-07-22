"""Static configuration for the Crankshaft debug collector.

Keeping constants in a dedicated module makes operational updates safer:
- command additions are reviewable in one place
- filesystem capture policy is explicit
- analysis checks can reuse shared keys
"""

from __future__ import annotations

from typing import Final

COMMAND_SPECS: Final[list[tuple[str, str]]] = [
    ("uname", "uname -a"),
    ("os_release", "cat /etc/os-release"),
    ("kernel_cmdline", "cat /proc/cmdline"),
    ("boot_config", "cat /boot/config.txt"),
    ("vcgencmd_version", "vcgencmd version"),
    ("vcgencmd_get_lcd_info", "vcgencmd get_lcd_info"),
    ("vcgencmd_display_power", "vcgencmd display_power"),
    ("vcgencmd_measure_temp", "vcgencmd measure_temp"),
    ("tvservice_status", "tvservice -s"),
    ("tvservice_cea_modes", "tvservice -m CEA"),
    ("tvservice_dmt_modes", "tvservice -m DMT"),
    ("tvservice_connected", "tvservice -n"),
    (
        "drm_connectors",
        "find /sys/class/drm -maxdepth 2 -type f | sort | while read -r f; do echo '=== '$f' ==='; cat \"$f\" 2>/dev/null; done",
    ),
    (
        "graphics_connectors",
        "find /sys/class/graphics -maxdepth 2 -type f | sort | while read -r f; do echo '=== '$f' ==='; cat \"$f\" 2>/dev/null; done",
    ),
    ("uptime", "uptime"),
    ("disk_usage", "df -h"),
    ("memory", "free -h"),
    ("lsusb", "lsusb"),
    ("usb_tree", "lsusb -t"),
    ("network", "ip addr"),
    ("route", "ip route"),
    ("systemd_failed", "systemctl --failed --no-pager"),
    ("crankshaft_core_status", "systemctl status crankshaft-core --no-pager"),
    ("crankshaft_ui_status", "systemctl status crankshaft-ui-slim --no-pager"),
    (
        "crankshaft_display_setup_status",
        "systemctl status crankshaft-ui-slim-display-setup --no-pager",
    ),
    ("crankshaft_core_cat", "systemctl cat crankshaft-core --no-pager"),
    ("crankshaft_ui_cat", "systemctl cat crankshaft-ui-slim --no-pager"),
    (
        "crankshaft_display_setup_cat",
        "systemctl cat crankshaft-ui-slim-display-setup --no-pager",
    ),
    (
        "aa_decode_loop_config",
        "python3 - <<'PY'\nimport json\nfrom pathlib import Path\npaths=[Path('/etc/crankshaft/crankshaft.json'), Path('/usr/share/crankshaft/config/crankshaft.json')]\nfor p in paths:\n    if p.exists():\n        obj=json.loads(p.read_text())\n        print(json.dumps(obj.get('core',{}).get('android_auto',{}).get('decode',{}), indent=2, sort_keys=True))\n        break\nelse:\n    print('missing crankshaft.json')\nPY",
    ),
    (
        "aa_telemetry_config",
        "python3 - <<'PY'\nimport json\nfrom pathlib import Path\npaths=[Path('/etc/crankshaft/crankshaft.json'), Path('/usr/share/crankshaft/config/crankshaft.json')]\nfor p in paths:\n    if p.exists():\n        obj=json.loads(p.read_text())\n        print(json.dumps(obj.get('core',{}).get('android_auto',{}).get('telemetry',{}), indent=2, sort_keys=True))\n        break\nelse:\n    print('missing crankshaft.json')\nPY",
    ),
    (
        "aa_thermal_config",
        "python3 - <<'PY'\nimport json\nfrom pathlib import Path\npaths=[Path('/etc/crankshaft/crankshaft.json'), Path('/usr/share/crankshaft/config/crankshaft.json')]\nfor p in paths:\n    if p.exists():\n        obj=json.loads(p.read_text())\n        print(json.dumps(obj.get('core',{}).get('android_auto',{}).get('thermal',{}), indent=2, sort_keys=True))\n        break\nelse:\n    print('missing crankshaft.json')\nPY",
    ),
    ("bluetooth_status", "systemctl status bluetooth --no-pager"),
    (
        "audio_status",
        "systemctl --type=service --state=running --no-pager "
        "| egrep -i 'pulse|pipewire|wireplumber'",
    ),
    (
        "audio_processes",
        "ps -ef | egrep -i 'pipewire|wireplumber|pulseaudio|bluez|bluetoothd'",
    ),
    ("audio_sockets", "ss -xlpn | egrep -i 'pipewire|pulse'"),
    ("pactl_info", "pactl info"),
    ("pactl_sinks", "pactl list short sinks"),
    ("pactl_sink_inputs", "pactl list short sink-inputs"),
    ("pactl_cards", "pactl list short cards"),
    ("wpctl_status", "wpctl status"),
    ("pw_cli_nodes", "pw-cli ls Node"),
    ("pw_cli_links", "pw-cli ls Link"),
    ("rfkill", "rfkill list"),
    ("nmcli_general", "nmcli general status"),
    ("nmcli_devices", "nmcli device status"),
    ("nmcli_connections", "nmcli connection show --active"),
    ("iw_dev", "iw dev"),
    ("iwconfig", "iwconfig"),
    ("bluetoothctl_show", "bluetoothctl show"),
    ("bluetoothctl_devices", "bluetoothctl devices"),
    ("bluetoothctl_paired", "bluetoothctl paired-devices"),
    ("apt_policy_core", "apt-cache policy crankshaft-core"),
    ("apt_policy_ui", "apt-cache policy crankshaft-ui-slim"),
    ("apt_policy_aasdk", "apt-cache policy libaasdk"),
    ("dpkg_core", "dpkg -l 'crankshaft*'"),
    ("dpkg_aasdk", "dpkg -l 'libaasdk*'"),
    ("dpkg_qt", "dpkg -l 'libqt6*' 'qml6-module-*'"),
    ("dpkg_gstreamer", "dpkg -l 'gstreamer1.0-*' 'libgstreamer*'"),
    ("journal_boot", "journalctl -b --no-pager"),
    ("journal_core", "journalctl -u crankshaft-core -b --no-pager"),
    ("journal_core_video", "journalctl -u crankshaft-core -b --no-pager | grep -Ei 'video|aa|android auto|aasdk|usb|display|drm|egl|h264|decode|render|gst|gstreamer' || true"),
    ("journal_ui", "journalctl -u crankshaft-ui-slim -b --no-pager"),
    ("journal_ui_video", "journalctl -u crankshaft-ui-slim -b --no-pager | grep -Ei 'video|display|egl|drm|qt|eglfs|render' || true"),
    (
        "journal_display_setup",
        "journalctl -u crankshaft-ui-slim-display-setup -b --no-pager",
    ),
    (
        "journal_pipewire",
        "journalctl -b _SYSTEMD_USER_UNIT=pipewire.service --no-pager",
    ),
    (
        "journal_pipewire_pulse",
        "journalctl -b _SYSTEMD_USER_UNIT=pipewire-pulse.service --no-pager",
    ),
    (
        "journal_wireplumber",
        "journalctl -b _SYSTEMD_USER_UNIT=wireplumber.service --no-pager",
    ),
    ("journal_bluetooth", "journalctl -u bluetooth -b --no-pager"),
    ("journal_network", "journalctl -u NetworkManager -b --no-pager"),
    ("dmesg", "dmesg -T"),
]

CONFIG_CANDIDATES: Final[list[str]] = [
    "/etc/crankshaft",
    "/etc/default/crankshaft-core",
    "/var/lib/crankshaft/slim-ui",
    "/run/crankshaft/ui-slim-display.env",
    "/etc/pipewire",
    "/etc/wireplumber",
    "/etc/bluetooth/main.conf",
    "/etc/NetworkManager/NetworkManager.conf",
    "/etc/NetworkManager/system-connections",
    "/etc/apt/sources.list",
    "/etc/apt/sources.list.d/opencardev.list",
    "/boot/firmware/config.txt",
    "/boot/config.txt",
]

SERVICE_CONFIG_CANDIDATES: Final[list[str]] = [
    "/etc/systemd/system/crankshaft-core.service",
    "/etc/systemd/system/crankshaft-core.service.d",
    "/etc/systemd/system/crankshaft-ui-slim.service",
    "/etc/systemd/system/crankshaft-ui-slim.service.d",
    "/etc/systemd/system/crankshaft-ui-slim-display-setup.service",
    "/etc/systemd/system/crankshaft-ui-slim-display-setup.service.d",
    "/lib/systemd/system/crankshaft-core.service",
    "/lib/systemd/system/crankshaft-ui-slim.service",
    "/lib/systemd/system/crankshaft-ui-slim-display-setup.service",
    "/usr/lib/systemd/system/crankshaft-core.service",
    "/usr/lib/systemd/system/crankshaft-ui-slim.service",
    "/usr/lib/systemd/system/crankshaft-ui-slim-display-setup.service",
]

# Common logs needed for first-pass support triage.
LOG_CANDIDATES: Final[list[str]] = [
    "/var/log/crankshaft",
    "/var/log/syslog",
    "/var/log/syslog.1",
    "/var/log/messages",
    "/var/log/messages.1",
    "/var/log/kern.log",
    "/var/log/kern.log.1",
    "/var/log/daemon.log",
    "/var/log/daemon.log.1",
    "/var/log/NetworkManager",
    "/var/log/wpa_supplicant.log",
]

EXPECTED_PACKAGES: Final[list[str]] = [
    "crankshaft-core",
    "crankshaft-ui-slim",
    "libaasdk",
    "pipewire",
    "pipewire-pulse",
    "wireplumber",
    "pulseaudio-utils",
    "bluez",
]

ERROR_MARKERS: Final[list[str]] = [
    "aasdk",
    "android auto",
    "pipewire",
    "wireplumber",
    "pulseaudio",
    "bluez",
    "a2dp",
    "hfp",
    "audiorouter",
    "usb",
    "timeout",
    "failed",
    "error",
]
