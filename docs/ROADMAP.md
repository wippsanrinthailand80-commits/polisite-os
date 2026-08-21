# Polisite OS — Roadmap

Ordered, living plan. Each phase is independently testable under QEMU.

## Phase 0 — Linux kernel (x86_64) ✅
- Reuses **Deposit** kernel: upstream Linux **6.6.58 LTS** via `build/build-kernel.sh`
  (`defconfig` + `polisite-broad.cfg`; `tinyconfig` in CI).
- QEMU `-kernel` smoke test prints `Linux version 6.6.58` on serial.
- From-scratch Rust/C/Zig/asm work archived in git history (`60db77b^`).

## Phase 1 — Kernel core (the "real OS" feeling)
- Serial + framebuffer drivers; early panic/debug.
- Physical buddy allocator + kernel heap (bump → slab).
- Higher-half paging done properly (Limine gives it; add our own for alloc).
- Basic SMP bring-up (Limine SMP request).
- Timer (HPET/APIC) + a cooperative→preemptive scheduler stub.

## Phase 2 — Gaming foundation
- Preemptive, priority + deadline scheduler (render/input real-time class).
- Input drivers: keyboard, mouse, gamepad (PS/2 + VirtIO).
- Kernel compositor: double-buffered framebuffer, vsync-aware present.
- Low-latency input path; frame-pacing stats.

## Phase 3 — AI foundation
- Zig AI math kernels wired to a Rust tensor runtime (CPU first).
- Privileged inference service + minimal model loader (quantised INT8).
- "AI scheduler" policy: steer background inference vs game perf.
- Demos: NPC logic, upscaling/denoising, OS assistant stub.

## Phase 4 — Drivers & storage
- PCI scan, VirtIO-BLK (disk), VirtIO-GPU, RTC.
- Initial ramdisk (tarfs) + a native read/write FS; FAT32 for USB.
- USB (xHCI) basics.

## Phase 5 — Userspace, boot & bundled apps
- `debootstrap` Noble rootfs (systemd, `apt`/`dpkg` + `.mlpds`/`aqa` compat).
- **Quiet + logo boot**: Plymouth `polisite-quiet` theme (centered logo, no spinner)
  + `quiet splash` on the kernel cmdline; fast, minimal boot.
- **Bundled apps** (Spirit Shores excluded until finished):
  - **VS Code**, **Chrome**, **Steam** (via `aqa` + `steam-installer`; Chrome/VS Code need external repos, installed on first boot/baked when possible),
  - **AI demo** (`tools/polisite-ai-demo.py` → `polisite-ai-demo` userspace service),
  - **Placeholder games** (`supertux`, `0ad`) as generic gaming payloads,
  - `firefox-esr` retained as fallback browser.
- **Polisite's own installers** (ALP + MSX editions) + foreign `.deb`/`.pkg.tar.zst`/`.mlpds` shims.

## Phase 6 — Real hardware & polish
- Validate on a real PC (BIOS + UEFI USB install).
- GPU vendor drivers (stretch), NPU offload, power/turbo modes.
- Performance pass; stability across hardware.

## Stretch goals
- Linux-binary compatibility layer.
- ARM64 / RISC-V secondary targets (reuse the Rust core; swap the asm/C layers).
- Networking + a curated app store.

---
*Note: we are not famous, so this is mostly for ourselves — but writing it down
keeps the direction honest.*
