#!/usr/bin/env bash
# Boot Polisite OS in QEMU (serial output to the terminal).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ISO="$ROOT/build/output/polisite.iso"

if [ ! -f "$ISO" ]; then
    echo "ISO not found. Run: bash build/build.sh" >&2
    exit 1
fi

exec qemu-system-x86_64 \
    -m 512 -smp 2 -cpu max -accel tcg \
    -cdrom "$ISO" -boot d \
    -serial stdio \
    -display gtk
