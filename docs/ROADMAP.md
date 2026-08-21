# Polisite OS — Roadmap

Ordered, living plan. Each phase is independently testable under QEMU.

## Phase 0 — Skeleton & toolchain ✅ (this repo)
- Repo layout, DESIGN.md, README.
- Build pipeline: nasm + gcc + zig + cargo + ld.lld → `polisite.elf`.
- Limine hybrid ISO; `run-qemu.sh`.
- **Definition of done**: QEMU boots to a framebuffer banner that proves the
  Rust↔C↔Zig↔asm FFI works (each language prints/returns a value).

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

## Phase 5 — Userspace
- Static `init` + shell; a small libc + program loader.
- Package format + installer (mirror `deposit-os` `.mlpds`/`aqa` ideas later).
- Graphics/audio stack enough to host a simple game.

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
