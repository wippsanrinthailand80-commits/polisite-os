#!/usr/bin/env bash
# Create a minimal initramfs (busybox static + /init) for Polisite OS.
# /init prints a banner and powers off — the CI smoke tests grep for it.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/build/output/kernel/boot/initrd}"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMPDIR"/{bin,sbin,etc,proc,sys,dev,tmp}
# Busybox static: prefer host copy, else download
BUSYBOX=""
for p in /bin/busybox /usr/bin/busybox; do
  if [ -x "$p" ]; then BUSYBOX="$p"; break; fi
done
if [ -z "$BUSYBOX" ]; then
  BUSYBOX="$TMPDIR/busybox"
  echo "[initramfs] downloading busybox static"
  wget -qO "$BUSYBOX" https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox
  chmod +x "$BUSYBOX"
fi
cp "$BUSYBOX" "$TMPDIR/bin/busybox"
for a in sh echo mount umount poweroff sleep cat; do
  ln -sf busybox "$TMPDIR/bin/$a" 2>/dev/null || true
done
cat > "$TMPDIR/init" <<'EOS'
#!/bin/sh
mount -t proc none /proc 2>/dev/null || true
mount -t sysfs none /sys 2>/dev/null || true
echo "Polisite OS — initramfs banner"
echo "Polisite OS — boot OK"
# Give serial a moment to flush, then power off. Fallbacks for minimal env.
sleep 1
poweroff -f 2>/dev/null || echo o > /proc/sysrq-trigger 2>/dev/null || while true; do sleep 1; done
EOS
chmod +x "$TMPDIR/init"
# Optional isa-debug-exit helper (writes 0x10 to port 0xf4). Not required for
# the banner test, but useful if the workflow checks the QEMU exit code
# from panic=1 + isa-debug-exit.
mkdir -p "$TMPDIR/usr/local/bin"
cat > "$TMPDIR/usr/local/bin/qemu-exit" <<'EOS'
#!/bin/sh
# Busybox sh cannot do outb; use a tiny C helper compiled on the fly if gcc exists
# Fallback: just poweroff
poweroff -f 2>/dev/null || true
EOS
chmod +x "$TMPDIR/usr/local/bin/qemu-exit" 2>/dev/null || true

mkdir -p "$(dirname "$OUT")"
( cd "$TMPDIR" && find . -print0 | cpio --null -ov --format=newc 2>/dev/null | gzip -9 > "$OUT" )
echo "[initramfs] $OUT ($(du -h "$OUT" | cut -f1), $(stat -c%s "$OUT") bytes)"
