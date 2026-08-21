# Polisite OS

**A from-scratch, gaming- and AI-first operating system kernel for `x86_64`.**
Booted with [Limine](https://limine-bootloader.org/), developed under QEMU,
targeting real hardware (BIOS + UEFI).

Polisite OS is **not** another Linux distribution — it is a new kernel written
in a deliberate mix of languages, each owning the layer it is best at:

| Language | Owns |
|----------|------|
| **Assembly (NASM)** | port I/O, early CPU setup, `hlt`, context-switch/ISR trampolines |
| **C** | low-level ABI glue, early runtime, reusable C algorithms |
| **Zig** | performance & AI math kernels (vectors, matrices, quantisation) |
| **Rust** | the systems core: memory, scheduler, drivers, compositor, shell, FFI hub |

All cross-language calls use a flat `extern "C"` ABI (System V x86_64).

See [`docs/DESIGN.md`](docs/DESIGN.md) for the full architecture and
[`docs/ROADMAP.md`](docs/ROADMAP.md) for the plan.

## Status

Phase 0 (skeleton + toolchain). It boots to a framebuffer banner under QEMU and
proves the Rust↔C↔Zig↔asm FFI works. Everything beyond is planned.

## Prerequisites

```bash
rustup target add x86_64-unknown-none
# plus, from your package manager:
nasm  gcc (or clang)  zig  lld (ld.lld)  limine  qemu-system-x86_64
```

## Build & run

```bash
bash build/build.sh        # -> build/output/polisite.iso (+ .elf)
bash build/run-qemu.sh     # boots the ISO in QEMU
```

## Project layout

```
docs/        DESIGN.md, ROADMAP.md
kernel/      Rust core + asm + C + Zig, linker script, limine.conf
build/       build.sh, run-qemu.sh
ci/          GitHub Actions (build + QEMU smoke test)
tools/       future userspace tooling
```

## License

MIT — see [LICENSE](LICENSE).
