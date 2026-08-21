#!/usr/bin/env bash
# Polisite OS build script.
# Orchestrates four toolchains into one kernel image:
#   nasm  -> asm/io.o         (assembly)
#   gcc   -> c/rt.o           (C)
#   zig   -> ai_math.o        (Zig AI math)
#   cargo -> libkernel.a      (Rust core, x86_64-unknown-none)
#   ld.lld -> polisite.elf    (link)
#   limine -> polisite.iso    (hybrid BIOS+UEFI image)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KERNEL="$ROOT/kernel"
OUT="$ROOT/build/output"
mkdir -p "$OUT"

# Pin the bootloader to match `limine = "0.4"` in kernel/Cargo.toml.
LIMINE_VER="${LIMINE_VER:-4.20240421.0}"

echo "==> [asm]  nasm"
nasm -f elf64 "$KERNEL/asm/io.asm" -o "$OUT/io.o"

echo "==> [c]    gcc"
gcc -c -ffreestanding -fno-pic -mno-red-zone -nostdlib -O2 -m64 \
    "$KERNEL/c/rt.c" -o "$OUT/rt.o"

echo "==> [zig]  zig"
( cd "$OUT" && zig build-obj -target x86_64-freestanding -O ReleaseSafe \
    "$KERNEL/zig/ai_math.zig" )

echo "==> [rust] cargo (x86_64-unknown-none)"
cargo build --release --target x86_64-unknown-none \
    --manifest-path "$KERNEL/Cargo.toml"
cp "$KERNEL/target/x86_64-unknown-none/release/libkernel.a" "$OUT/libkernel.a"

echo "==> [link] ld.lld"
ld.lld -n -T "$KERNEL/kernel.ld" -o "$OUT/polisite.elf" \
    "$OUT/io.o" "$OUT/rt.o" "$OUT/ai_math.o" "$OUT/libkernel.a"

echo "==> [iso]  limine"
LIMINE_DIR="$OUT/limine"
if [ ! -d "$LIMINE_DIR/bin" ]; then
    echo "    fetching limine v$LIMINE_VER"
    curl -sSL "https://github.com/limine-bootloader/limine/releases/download/v${LIMINE_VER}/limine-${LIMINE_VER}.tar.gz" -o "$OUT/limine.tar.gz"
    tar -xzf "$OUT/limine.tar.gz" -C "$OUT"
    mv "$OUT/limine-${LIMINE_VER}" "$LIMINE_DIR"
    ( cd "$LIMINE_DIR" && ./configure && make )
fi

rm -rf "$OUT/iso_root"
mkdir -p "$OUT/iso_root/boot" "$OUT/iso_root/EFI/BOOT"
cp "$OUT/polisite.elf"        "$OUT/iso_root/boot/polisite.elf"
cp "$KERNEL/limine.conf"      "$OUT/iso_root/boot/limine.conf"
cp "$LIMINE_DIR/bin/limine-uefi-cd.bin" "$OUT/iso_root/EFI/BOOT/BOOTX64.EFI"
cp "$LIMINE_DIR/bin/limine-cd.bin"      "$OUT/iso_root/boot/limine-cd.bin"

xorriso -as mkisofs \
    -b boot/limine-cd.bin \
        -no-emul-boot -boot-load-size 4 -boot-info-table \
    --efi-boot EFI/BOOT/BOOTX64.EFI \
        -efi-boot-part --efi-boot-image \
    -o "$OUT/polisite.iso" \
    "$OUT/iso_root"

echo "==> done: $OUT/polisite.elf and $OUT/polisite.iso"
