//! Minimal 16550 UART serial driver (COM1, 0x3F8).
//! Non-blocking for the skeleton; a proper THRE poll + UART init comes later.

use crate::io;

const COM1: u16 = 0x3f8;

pub struct Serial;

impl core::fmt::Write for Serial {
    fn write_str(&mut self, s: &str) -> core::fmt::Result {
        for byte in s.bytes() {
            putc(byte);
        }
        Ok(())
    }
}

fn putc(byte: u8) {
    // QEMU's UART is always ready; a real driver should poll LSR.THRE first.
    unsafe { io::outb(COM1, byte) };
}

pub fn write_str(s: &str) {
    let mut s = Serial;
    let _ = s.write_str(s);
}

pub fn write_fmt(args: core::fmt::Arguments) {
    let mut s = Serial;
    let _ = s.write_fmt(args);
}
