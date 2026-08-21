# Polisite OS — Kernel Design

> A gaming- and AI-first **Linux distribution** for `x86_64`.
> Built by compiling its own Linux kernel from upstream source (like Deposit OS).

This document is the source of truth for **architecture and intent**. The
original from-scratch Rust/C/Zig/asm kernel has been archived; Polisite now
builds on **Linux 6.6.58 LTS** for broad driver, GPU, and AI-accelerator
support, while keeping the gaming/AI-first product goals.

---

## 1. Why Linux (and not a from-scratch kernel)

`deposit-os` in this family is a Linux distribution (custom kernel config +
userspace). Polisite *was* a from-scratch hobby kernel, but to prioritise
**real gaming and AI hardware** (GPUs, NPUs, controllers, audio, networking)
it now reuses the same approach: **own kernel compiled from kernel.org**,
not a respin. This gives direct control over config/patches without
reimplementing drivers, filesystems, and scheduling from zero.

The from-scratch work is kept as a reference in git history.

## 2. Product positioning

- **Gaming-first**: low-latency input, a lean compositor path, and a scheduler
  that favours the active game's render/input threads; broad GPU driver
  coverage via the upstream kernel.
- **AI-first**: first-class on-device inference (NPU/GPU offload, a small
  tensor runtime in userspace, and an "AI scheduler" policy).
- **Still a real OS**: preemptive multitasking, drivers, filesystems, a shell,
  and a package story — powerful enough for desktop/handheld.

## 3. Kernel choice

| Choice | Value |
|--------|-------|
| Base   | Linux **6.6.58** LTS (same upstream as Deposit OS) |
| Config | `defconfig` (or `tinyconfig` for CI) + `build/kernel-fragments/polisite-broad.cfg` |
| Arch   | `x86_64` (primary) |
| Source | `https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.6.58.tar.xz` (mirrors in `build-kernel.sh`) |
| Patches| none yet; gaming/AI tuning will land as fragment deltas or small patches |

The broad fragment enables SMP, PCI, ACPI, EFI, NVMe/SATA/USB storage, ext4/FAT/ISO9660/overlay, namespaces/cgroups, VirtIO, common NICs (e1000/e1000e/r8169), USB HID, DRM/simpledrm + fbdev console, 8250 serial, etc. — enough to boot on real hardware or QEMU.

## 4. Boot & loader

- **Live media**: GRUB2 + `live-boot` + SquashFS ISO (planned, mirroring Deposit's `ci/make-iso.sh`).
- **QEMU smoke**: direct `-kernel` boot for the kernel artefact (`vmlinuz-*`) in CI; full ISO boot later.
- **Bare metal**: GPT (ESP + ext4 root), GRUB for BIOS + UEFI.

## 5. Memory model

Linux VM (buddy/SLAB/SLUB, KSM, zswap — kernel defaults). No custom allocator.

## 6. Scheduling (gaming + AI aware, userspace policy)

- Linux CFS + RT classes; a userspace policy layer steers:
  - a render/input "RT-ish" class for the active game,
  - an **AI class** for background inference that can be capped/preempted.

## 7. Graphics & input (gaming)

- DRM/KMS + Mesa in userspace; a small compositor with vsync-aware present;
  low-latency input path (evdev/libinput).

## 8. AI subsystem

- Privileged inference service in userspace (later a tiny tensor runtime);
  hardware offload hooks for NPU/GPU (VirtIO-accel, later vendor).
- Hot math kernels may still be written in **Zig** as userspace libs.

## 9. Driver framework

Upstream Linux drivers. Polisite adds only config/patches.

## 10. Filesystem & userspace (planned)

- `debootstrap` of Ubuntu 24.04 (Noble), glibc-based, systemd — ABI-compatible
  with the Debian/Ubuntu package pool.
- Own packaging (`.mlpds`/`aqa` compat with Deposition/Deposit) and curated apps.

## 11. Repository layout

```
polisite-os/
  docs/                DESIGN.md, ROADMAP.md
  build/               config.sh, build-kernel.sh, kernel-fragments/, build.sh
  ci/                  (future: make-iso.sh, live-boot)
```

## 12. Packaging & installation

### 12.1 Polisite's own installers
Two editions that **install Polisite itself** to disk (ESP + root, bootloader):
**ALP** and **MSX** (variant behaviour TBD — e.g. full GUI vs minimal, desktop
vs handheld, online vs offline media).

### 12.2 Foreign application-install support
Other distros' installers put **apps onto the machine**. Polisite will consume:

| Source OS      | Format(s) |
|----------------|-----------|
| Ubuntu / Mint  | `.deb` (dpkg/apt) |
| Arch           | `.pkg.tar.zst` (pacman) |
| Deposition     | `.mlpds` + `aqa` (successor to Deposit) |

Via compatibility shims onto Polisite's native package DB.

> **TODO:** define what distinguishes **ALP** vs **MSX** installer variants.

## 13. Build pipeline (x86_64)

`build/build.sh` wraps `build/build-kernel.sh`:

1. Download `linux-6.6.58.tar.xz` from kernel.org (mirrors + retries).
2. `make tinyconfig` (CI, `POLISITE_KERNEL_TINY=1`) or `defconfig` + fragments.
3. `make -j$(nproc)` → `build/output/kernel/boot/vmlinuz-6.6.58`.
4. (Planned) debootstrap rootfs + ISO.

Prerequisites (x86_64): `build-essential` `bc` `flex` `bison` `libelf-dev`
`libssl-dev` `qemu-system-x86` (for smoke).

## 14. Non-goals (v1)

- No from-scratch scheduler/VM reimplementation.
- No GUI toolkit in-kernel.

## 15. Risks

- Large kernel builds need RAM/time — mitigated by `tinyconfig` in CI and
  `POLISITE_KERNEL_JOBS` caps.
- Keeping fragments in sync with Deposit — shared broad cfg reduces drift.
