/* Polisite OS — Rust kernel core.
 *
 * Language roles (see docs/DESIGN.md):
 *   - asm  (kernel/asm/io.asm)      : port I/O, halt
 *   - C    (kernel/c/rt.c)           : low-level helpers
 *   - Zig  (kernel/zig/ai_math.zig)  : AI / vector math kernels
 *   - Rust (here)                    : the systems core + FFI hub
 *
 * Entry point is `_start` (Limine jumps here in 64-bit mode).
 */

#![no_std]
#![no_main]

mod serial;
mod framebuffer;
mod io;
mod ffi;

use limine::request::FramebufferRequest;

/// Limine request: ask for a framebuffer.
static FRAMEBUFFER_REQUEST: FramebufferRequest = FramebufferRequest::new();

#[no_mangle]
pub extern "C" fn _start() -> ! {
    serial::write_str("Polisite OS — kernel starting\r\n");

    // Prove the C layer works (flat extern "C" FFI).
    let c_val = unsafe { ffi::c_hello() };
    serial::write_fmt(format_args!("C layer returned: 0x{:08x}\r\n", c_val));

    // Prove the Zig AI-math layer works.
    let a = [1.0f32, 2.0, 3.0, 4.0];
    let b = [4.0f32, 3.0, 2.0, 1.0];
    let dot = unsafe { ffi::zig_vector_dot(a.as_ptr(), b.as_ptr(), 4) };
    serial::write_fmt(format_args!("Zig vector_dot(a, b) = {}\r\n", dot));

    // Prove the asm layer works (read a harmless status port).
    let port_val = unsafe { io::inb(0x92) };
    serial::write_fmt(format_args!("asm inb(0x92) = 0x{:02x}\r\n", port_val));
    unsafe { io::outb(0x80, 0x00) }; // POST port write (no-op, proves outb)

    // Framebuffer proof-of-life: fill with a brand color.
    if let Some(resp) = FRAMEBUFFER_REQUEST.response() {
        if let Some(fb) = resp.framebuffers().first() {
            framebuffer::fill(fb, 0x002b_3a_5b);
            serial::write_str("Framebuffer acquired and filled.\r\n");
        }
    }

    serial::write_str("Polisite OS — boot OK. Halting in idle loop.\r\n");
    loop {
        unsafe { io::halt() };
    }
}

#[panic_handler]
fn panic(info: &core::panic::PanicInfo) -> ! {
    serial::write_str("KERNEL PANIC: ");
    let msg = info.message();
    serial::write_fmt(format_args!("{}\r\n", msg));
    loop {
        unsafe { io::halt() };
    }
}
