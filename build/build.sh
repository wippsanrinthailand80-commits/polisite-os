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

echo "==> [initramfs] minimal busybox + /init"
bash "$ROOT/tools/make_initramfs.sh" "$POLISITE_KERNEL_OUT/boot/initrd"
ls -lh "$POLISITE_KERNEL_OUT/boot/initrd" || true

# --- 200 MB demo ISO with real content (quiet+logo) ---
echo "==> [assets] generating ~190 MB real-content payload"
python3 "$ROOT/tools/make_assets.py" "$ROOT/build/output/assets" 190

LIMINE_VER="${LIMINE_VER:-12.6.0}"
LIMINE_DIR="$ROOT/build/output/limine"
if [ ! -d "$LIMINE_DIR/bin" ]; then
  echo "    fetching Limine v$LIMINE_VER"
  curl -sSL "https://github.com/limine-bootloader/limine/releases/download/v${LIMINE_VER}/limine-${LIMINE_VER}.tar.gz" -o "$ROOT/build/output/limine.tar.gz"
  tar -xzf "$ROOT/build/output/limine.tar.gz" -C "$ROOT/build/output"
  mv "$ROOT/build/output/limine-${LIMINE_VER}" "$LIMINE_DIR"
  ( cd "$LIMINE_DIR" && ./configure --enable-bios --enable-bios-cd --enable-uefi-x86-64 --enable-uefi-cd && make )
fi

echo "==> [iso] building 200 MB demo ISO"
rm -rf "$ROOT/build/output/iso_root"
mkdir -p "$ROOT/build/output/iso_root/boot" "$ROOT/build/output/iso_root/EFI/BOOT" "$ROOT/build/output/iso_root/assets"
cp "$POLISITE_KERNEL_OUT/boot/vmlinuz-"* "$ROOT/build/output/iso_root/boot/vmlinuz-6.6.58"
cp "$POLISITE_KERNEL_OUT/boot/initrd" "$ROOT/build/output/iso_root/boot/initrd"
cp "$ROOT/build/limine.conf" "$ROOT/build/output/iso_root/boot/limine.conf"
cp "$ROOT/build/plymouth/polisite-quiet/logo.png" "$ROOT/build/output/iso_root/assets/" 2>/dev/null || true
cp "$ROOT/build/output/assets/polisite-assets.tar" "$ROOT/build/output/iso_root/assets/"
cp "$LIMINE_DIR/bin/limine-bios-cd.bin" "$ROOT/build/output/iso_root/boot/"
cp "$LIMINE_DIR/bin/limine-uefi-cd.bin" "$ROOT/build/output/iso_root/boot/"
cp "$LIMINE_DIR/bin/limine-bios.sys" "$ROOT/build/output/iso_root/boot/"
cp "$LIMINE_DIR/bin/BOOTX64.EFI" "$ROOT/build/output/iso_root/EFI/BOOT/BOOTX64.EFI"
xorriso -as mkisofs -R -r -J \
  -b boot/limine-bios-cd.bin -no-emul-boot -boot-load-size 4 -boot-info-table -hfsplus \
  -apm-block-size 2048 --efi-boot boot/limine-uefi-cd.bin -efi-boot-part --efi-boot-image --protective-msdos-label \
  -o "$ROOT/build/output/polisite.iso" "$ROOT/build/output/iso_root"
"$LIMINE_DIR/bin/limine" bios-install "$ROOT/build/output/polisite.iso" 2>/dev/null || true
echo "==> ISO done"
ls -lh "$ROOT/build/output/polisite.iso"
du -sh "$ROOT/build/output/polisite.iso"
