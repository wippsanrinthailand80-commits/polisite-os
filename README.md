# Polisite OS

**A gaming- and AI-first Linux distribution for `x86_64`** — built like **Deposit OS**: we compile our own **Linux 6.6.58 LTS** kernel from upstream source and assemble a minimal, apt-compatible userspace.

This repo reuses Deposit's kernel (same upstream version + broad hardware fragment) so Polisite is a *new* distro that owns its kernel, not a respin.

See [`docs/DESIGN.md`](docs/DESIGN.md) and [`docs/ROADMAP.md`](docs/ROADMAP.md).

## Status

Phase 0 (Linux kernel, x86_64). The from-scratch Rust kernel has been archived; Polisite now builds on Linux for broad driver/gaming/AI hardware support first, with the original from-scratch work kept as a reference.

## Prerequisites

```bash
sudo apt-get install build-essential bc flex bison libelf-dev libssl-dev \
  wget xz-utils cpio kmod qemu-system-x86
```

No Rust/Zig/nasm/lld required for this target.

## Build & run (x86_64)

```bash
bash build/build.sh                 # -> build/output/kernel/boot/vmlinuz-6.6.58
# quick boot test (no ISO yet):
qemu-system-x86_64 -m 512 -smp 1 -accel tcg \
  -kernel build/output/kernel/boot/vmlinuz-6.6.58 \
  -append "console=ttyS0 earlyprintk=serial" \
  -serial stdio -display none -nographic
```

For CI speed the workflow builds with `POLISITE_KERNEL_TINY=1` (tinyconfig); a full `defconfig + polisite-broad.cfg` build is the default locally.

## Project layout

```
build/               config.sh, build-kernel.sh, kernel-fragments/, build.sh
docs/                DESIGN.md, ROADMAP.md
```

## Packaging & installers

- Own kernel: Linux 6.6.58 LTS (see `build/kernel-fragments/polisite-broad.cfg`).
- Userspace (planned): Ubuntu Noble debootstrap, `apt`/`dpkg` + Deposit `.mlpds`/`aqa` compat, plus Polisite **ALP** and **MSX** installer variants (see DESIGN.md §12).
- Foreign app-install support (planned): `.deb` (Ubuntu/Mint), `.pkg.tar.zst` (Arch), `.mlpds` (Deposition).

## License

MIT — see [LICENSE](LICENSE).
