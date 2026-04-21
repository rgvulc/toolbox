#!/usr/bin/env bash
# Fix audio on Ubuntu 24.04 VMs with VirtIO sound cards.
#
# Root cause: WirePlumber's ACP profile selector picks "input:stereo-fallback"
# (capture only, priority 51) because no output fallback profile is generated
# for VirtIO devices. This leaves PipeWire with no real sink → Dummy Output.
#
# Fix: drop a WirePlumber rule that forces the "pro-audio" profile for any
# device from Red Hat/VirtIO (vendor 0x1af4), giving both Sink and Source.

set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "Run as your regular user, not root/sudo. 'systemctl --user' needs your session bus."
  echo "Nothing was done, exiting."
  exit 1
fi

echo "NOTE: This script targets WirePlumber 0.4 (Ubuntu 24.04). WirePlumber 0.5+"
echo "      (Ubuntu 24.10 and later) uses SPA-JSON configs under"
echo "      ~/.config/wireplumber/wireplumber.conf.d/ and will silently ignore"
echo "      the Lua file this script writes."
echo

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/wireplumber/main.lua.d"
CONFIG_FILE="$CONFIG_DIR/51-virtio-audio-fix.lua"

mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_FILE" <<'EOF'
-- VirtIO sound cards only generate an "input:stereo-fallback" ACP profile
-- (priority 51) but no output fallback profile, so WirePlumber picks capture-only
-- and falls back to Dummy Output for playback. Force pro-audio (which has both
-- Sink + Source) by matching on the Red Hat/VirtIO vendor ID.
alsa_monitor.rules[#alsa_monitor.rules + 1] = {
  matches = {
    {
      { "device.vendor.id", "equals", "0x1af4" },
    },
  },
  apply_properties = {
    ["device.profile"] = "pro-audio",
  },
}
EOF

echo "Wrote $CONFIG_FILE"

# Restart the audio stack for the current user session
systemctl --user restart wireplumber pipewire pipewire-pulse

echo
echo "Done. To verify, run: wpctl status"
echo "The active sink (marked with *) should be a VirtIO sink, not 'Dummy Output'."
