# Polisite OS

**A gaming- and AI-first Linux distribution for `x86_64`** — we compile our own **Linux 6.6.58 LTS** kernel from upstream source (like Deposit OS) and assemble a minimal, apt-compatible userspace.

Polisite's kernel is **its own** (upstream `6.6.58` + `build/kernel-fragments/polisite-broad.cfg` tuned for gaming/AI); installer support for **Ubuntu/Mint (`.deb`)**, **Arch (`.pkg.tar.zst`)**, and **Deposition (`.mlpds`/`aqa`)** is **userspace-only** via compatibility shims.

See [`docs/DESIGN.md`](docs/DESIGN.md) and [`docs/ROADMAP.md`](docs/ROADMAP.md).

## Status

**Phase 0 — Linux kernel `x86_64` + minimal initramfs + 200 MB demo ISO ✅**

- `build/build-kernel.sh` → `build/output/kernel/boot/vmlinuz-6.6.58` (`tinyconfig` in CI, `2.4 MB`; full `defconfig` ~10 MB)
- `tools/make_initramfs.sh` → `build/output/kernel/boot/initrd` (busybox static + `/init` that prints `Polisite OS — initramfs banner` / `Polisite OS — boot OK` then `poweroff -f`)
- `tools/make_assets.py` → `build/output/assets/polisite-assets.tar` (~190 MB real content: gradient `splash.rgb` + `DESIGN.md`/`ROADMAP.md`/`README.md`/`LICENSE`)
- `build/build.sh` → `build/output/polisite.iso` (~200 MB, hybrid BIOS+UEFI via **Limine 12.6.0**, `quiet splash` + centered logo, no spinner)

QEMU smokes both verify the banner:
```bash
# kernel+initramfs
qemu-system-x86_64 -m 512 -smp 1 -kernel build/output/kernel/boot/vmlinuz-6.6.58 \
  -initrd build/output/kernel/boot/initrd \
  -append "console=ttyS0 earlyprintk=serial root=/dev/ram0 rdinit=/init panic=1" \
  -serial stdio -display none -nographic

# ISO
qemu-system-x86_64 -m 512 -cdrom build/output/polisite.iso -boot d \
  -serial stdio -display none -nographic
```

## Prerequisites (x86_64)

```bash
sudo apt-get install build-essential bc flex bison libelf-dev libssl-dev \
  wget xz-utils cpio kmod nasm gcc-multilib make lld llvm mtools xorriso qemu-system-x86 ccache
```

## Build & run (x86_64)

```bash
bash build/build.sh                 # kernel + initramfs + 200 MB ISO
ls -lh build/output/kernel/boot/vmlinuz-* build/output/kernel/boot/initrd build/output/polisite.iso
```

For CI speed the workflow builds `POLISITE_KERNEL_TINY=1` (tinyconfig).

## Boot & bundled apps

- **Boot**: `quiet splash` + **Plymouth `polisite-quiet`** theme (centered logo, no spinner) at `build/plymouth/polisite-quiet/`.
- **Bundled apps** (Spirit Shores excluded until finished): **VS Code**, **Chrome**, **Steam** (via `steam-installer` + `aqa` `vscode`/`chrome`/`steam`), **AI demo** at `tools/polisite-ai-demo.py` → `polisite-ai-demo` userspace service, placeholder games `supertux`/`0ad` plus `firefox-esr` fallback.
- **Installers**: own **ALP** + **MSX** editions (variant behaviour TBD) + foreign `.deb`/`.pkg.tar.zst`/`.mlpds` shims (see `docs/DESIGN.md:12`).

## Project layout

```
build/               config.sh, build-kernel.sh, kernel-fragments/, build.sh, limine.conf, plymouth/
docs/                DESIGN.md, ROADMAP.md
tools/               make_assets.py, make_initramfs.sh, polisite-ai-demo.py
```

## Suggested next (high payoff, low effort)

- App store (`polisite-store`) for `apt`+`aqa`+`.mlpds`
- Turbo/performance toggle + system hub tiles
- Thai `ibus-libthai` + Security center (`ufw`/AppArmor/ClamAV) + Updater

## License

MIT — see [LICENSE](LICENSE).
