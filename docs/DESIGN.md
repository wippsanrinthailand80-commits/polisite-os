# Polisite OS — Kernel Design

> A from-scratch, gaming- and AI-first operating system kernel for `x86_64`.
> Built to run first under QEMU, then on real hardware (BIOS + UEFI).

This document is the source of truth for **architecture and intent**. Code in
`kernel/` is the matching skeleton. Nothing here is set in stone — it is a
living plan.

---

## 1. Why a new kernel (not another Linux distro)

`deposit-os` and `dietpex-os` in this family are **Linux distributions** (custom
kernel config + userspace). Polisite OS is different: it is a **new kernel
written from scratch**, not a repackaged Linux. The goal is direct control over
scheduling, graphics, and compute so gaming and on-device AI get first-class,
low-latency treatment that a general-purpose OS cannot easily give.

## 2. Product positioning

- **Gaming-first**: predictable frame pacing, low-latency input, a lean
  graphics/composition path, and a scheduler that treats the render thread as a
  priority citizen.
- **AI-first**: first-class support for on-device inference (NPU/GPU offload,
  a small tensor runtime in the kernel or a privileged userspace service), and
  an "AI scheduler" that allocates compute between games, background inference,
  and the OS.
- **Still a real OS**: preemptive multitasking, virtual memory, drivers,
  filesystems, a shell, and a package story — powerful enough to live on a
  desktop or handheld.

## 3. Language strategy (the "mix")

Each language owns a layer it is best at. They meet at a clean **FFI boundary**
(`extern "C"` ABI, System V x86_64 calling convention).

| Language | Role in the kernel | Why here |
|----------|--------------------|----------|
| **Assembly (NASM)** | CPU port I/O (`inb`/`outb`), early CPU setup, `hlt`, context-switch / interrupt trampolines, tight `memcpy`/`memset`. | Nothing else can touch the hardware primitives; smallest, dependency-free. |
| **C** | Low-level hardware/ABI glue, early C runtime (`crt0`-style helpers), reuse of battle-tested C algorithms (compression, crypto, filesystem codecs). | Maximum control, vast existing embedded/OS code to borrow. |
| **Zig** | Performance & math kernels and **AI primitives**: vector/matrix ops, activations, quantisation, SIMD kernels. | Excellent freestanding support, C ABI, safe-but-fast, great for hot numeric loops. |
| **Rust** | The **systems core**: kernel `kmain`, physical/virtual memory manager, scheduler, driver framework, VFS, framebuffer compositor, shell, and the FFI surface to C/Zig. | Memory safety without GC, strong type system, best tooling for a large, evolving codebase. |

Hard rule: **all cross-language calls go through `extern "C"`**. No language
reaches into another's internals. Rust is the integrator; C/Zig/asm expose
flat C-ABI functions.

## 4. Boot & loader

- **Bootloader: [Limine](https://limine-bootloader.org/)** (per the sibling
  convention of GRUB-free, BIOS+UEFI-capable images).
- Limine jumps straight to a **64-bit** entry (`_start` in Rust), so we avoid
  hand-writing long-mode paging bring-up. Limine sets up the page tables and
  hands us a rich `BootInfo` (framebuffer, memory map, ACPI/RSDP, SMP).
- **Higher-half kernel**: linked at `0xffffffff80000000` (the Limine-recommended
  location). Identity/recursive mapping is Limine's job.
- Output targets: **BIOS** (`limine bios-install`) and **UEFI**
  (`limine-uefi`), plus a hybrid **ISO** for QEMU and USB install.

## 5. Memory model (first cut)

- Higher-half direct map for physical RAM below 4 GiB; proper page tables for
  the rest.
- **Buddy allocator** for physical pages (C or Rust).
- **Heap**: a small `bump`/`slab` allocator for kernel allocations (start with a
  bump allocator, graduate to slab).
- No swap in v1; on-demand paging only for the kernel's own needs.

## 6. Scheduling (gaming + AI aware)

- Preemptive, priority + **deadline** aware.
- A render/input "real-time-ish" class for the active game's main + render
  threads (low latency, pinned).
- An **AI class** for inference workloads that can tolerate preemption and be
  steered by an "AI scheduler" policy (e.g. cap background inference to N% unless
  on AC power).
- SMP via Limine's SMP request; per-CPU run queues.

## 7. Graphics & input (gaming)

- Early: Limine **framebuffer** (linear, direct pixel writes) + a tiny text/UI
  layer in Rust.
- Next: a kernel **compositor** with vsync-aware presentation and a low-latency
  input path (keyboard/mouse/gamepad via the relevant drivers).
- GPU: start with framebuffer; add a VirtIO-GPU and (later) vendor drivers.

## 8. AI subsystem

- A privileged **inference service** (runs in kernel-managed memory; later a
  trusted userspace daemon) exposing a small tensor runtime.
- Core math implemented in **Zig** (`kernel/zig/ai_math.zig`): dot products,
  matrix multiply, activations, quantised INT8/INT4 kernels.
- Hardware offload hooks for NPU/GPU (VirtIO-accel, later vendor).
- Use cases: NPC behavior, upscaling/denoising, accessibility, OS assistant.

## 9. Driver framework

- Uniform `Driver` trait in Rust; probe/attach via device tree / ACPI.
- First drivers: UART (serial), framebuffer, PS/2 or VirtIO input, VirtIO-BLK
  (disk), VirtIO-GPU, RTC, HPET/APIC timers, PCI scan.

## 10. Filesystem & userspace (later)

- Start with a **tarfs/initial ramdisk** loaded by Limine.
- Then a native read/write FS; FAT32 for USB interchange.
- A minimal **userspace**: a static `init` + shell; eventually a libc + loader
  so native Polisite apps and a compatibility layer (Linux-ABI binary compat is a
  stretch goal) can run.

## 11. Repository layout

```
polisite-os/
  docs/            DESIGN.md, ROADMAP.md
  kernel/
    Cargo.toml     Rust crate (crate-type = staticlib)
    kernel.ld      linker script (higher-half)
    limine.conf    Limine config
    src/           Rust: main(kmain), framebuffer, serial, io, ffi glue
    asm/           io.asm (port I/O, hlt, memcpy/set)
    c/             rt.c (C helpers), linkage.h
    zig/           ai_math.zig (AI/vector kernels)
  build/           build.sh (nasm+gcc+zig+cargo+ld.lld), run-qemu.sh
  ci/              GitHub Actions build + QEMU smoke test
  tools/           future userspace tooling
```

## 12. Build pipeline

`build/build.sh` orchestrates (all output to `build/output/`):

1. `nasm` → `io.o` (asm)
2. `gcc -ffreestanding -mno-red-zone -fno-pic -nostdlib` → `rt.o` (C)
3. `zig build-obj -target x86_64-freestanding` → `ai_math.o` (Zig)
4. `cargo build --release` → `libkernel.a` (Rust, `x86_64-unknown-none`)
5. `ld.lld -T kernel.ld` links the above into `polisite.elf`
6. Limine builds the hybrid ISO / disk image.

Prerequisites: `nasm`, `gcc`/`clang`, `zig`, `rustup` (+`x86_64-unknown-none`),
`lld` (or `ld.lld`), `limine`, `qemu-system-x86_64`.

## 13. Non-goals (v1)

- No network stack in the very first boot (added right after framebuffer).
- No GUI toolkit in-kernel; compositor only.
- No binary compat with Linux/Windows yet.
- No security MAC in v1 (add after the core is stable).

## 14. Risks

- Mixing 4 toolchains increases build complexity — mitigated by one script and a
  fixed FFI ABI.
- `x86_64-unknown-none` + Limine version drift — pin both (see `build.sh`).
- Bringing up real hardware drivers is the long pole; QEMU (VirtIO) is the
  primary dev target.
