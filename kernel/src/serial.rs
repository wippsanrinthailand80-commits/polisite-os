//! Minimal 16550 UART serial driver (COM1, 0x3F8).
//! Now polls THR empty (LSR bit 5) before each write.

use crate::io;
use core::fmt::Write;

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
    // Wait for THR empty (LSR bit 5 at offset 5 from base port)
    unsafe {
        while (io::inb(COM1 + 5) & 0x20) == 0 {}
        io::outb(COM1, byte);
    }
}

pub fn write_str(msg: &str) {
    let mut ser = Serial;
    let _ = ser.write_str(msg);
}

pub fn write_fmt(args: core::fmt::Arguments) {
    let mut ser = Serial;
    let _ = ser.write_fmt(args);
}
