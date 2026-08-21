# Contributing to Polisite OS

Thanks for helping build a gaming- and AI-first kernel from scratch.

## Ground rules

1. **FFI only between languages.** Rust integrates; C/Zig/asm expose flat
   `extern "C"` functions. Never reach into another language's internals.
2. **Keep the four-toolchain build green.** `bash build/build.sh` must produce
   `polisite.elf` with no warnings-as-errors regressions. Run it before opening
   a PR.
3. **Document hardware-facing code.** Register bits, magic numbers, and ABI
   contracts belong in a comment or `docs/`.
4. **QEMU-first.** New features must boot and be demonstrable under QEMU before
   real-hardware claims.

## Workflow

- Default branch is `main`.
- Branch per change (`feat/...`, `fix/...`, `docs/...`).
- Open a PR; CI builds the kernel and runs a QEMU smoke test.
- Keep commits focused; write messages in the repo's concise style.

## Where to start

- `docs/DESIGN.md` and `docs/ROADMAP.md` describe intent and the next phases.
- Phase 0 (the skeleton) is the easiest place to learn the build + FFI boundary.
- Good first tasks: extend the framebuffer text layer, add a serial logger, or
  add an AI math kernel in `kernel/zig/ai_math.zig` and call it from Rust.
