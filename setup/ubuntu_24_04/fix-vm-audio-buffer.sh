#!/usr/bin/env bash
# Reduce PipeWire audio jitter inside a VM by forcing a larger buffer quantum.
set -euo pipefail

# Buffer size in samples. Larger = smoother under load, more input-to-sound lag.
# At 48 kHz: 1024 ~= 21 ms, 2048 ~= 43 ms, 4096 ~= 85 ms.
QUANTUM=2048

CONF_DIR="$HOME/.config/pipewire/pipewire.conf.d"
CONF_FILE="$CONF_DIR/10-vm-latency.conf"

mkdir -p "$CONF_DIR"

cat > "$CONF_FILE" <<EOF
context.properties = {
    default.clock.quantum      = $QUANTUM
    default.clock.min-quantum  = $QUANTUM
}
EOF
echo "wrote $CONF_FILE (quantum = $QUANTUM)"

# Apply immediately without waiting for a restart.
pw-metadata -n settings 0 clock.force-quantum "$QUANTUM" >/dev/null
echo "forced clock.force-quantum = $QUANTUM (runtime)"

# Restart the user services so the config file takes effect permanently.
systemctl --user restart pipewire pipewire-pulse wireplumber
echo "restarted pipewire, pipewire-pulse, wireplumber"

echo "done. verify with: pw-metadata -n settings | grep quantum"
