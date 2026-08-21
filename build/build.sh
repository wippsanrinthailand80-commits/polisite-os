#!/usr/bin/env bash
# Polisite OS — Linux kernel build wrapper (x86_64).
# Reuses the Deposit kernel (upstream Linux 6.6.58 LTS) so Polisite is a
# *new* distro that compiles its own kernel, not a respin.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/build/config.sh"

# Force x86_64 for this build (per user request).
export POLISITE_ARCH=x86_64

echo "==> Polisite OS — Linux kernel build (x86_64, $POLISITE_KERNEL_VERSION)"
bash "$ROOT/build/build-kernel.sh" "$@"

echo "==> kernel artefact"
ls -lh "$POLISITE_KERNEL_OUT/boot/" || true
file "$POLISITE_KERNEL_OUT/boot/vmlinuz-"* 2>/dev/null | head -1 || true
echo "size:"
du -sh "$POLISITE_KERNEL_OUT/boot/vmlinuz-"* 2>/dev/null | head -1 || true
