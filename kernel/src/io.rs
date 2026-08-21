//! FFI declarations for the assembly layer (kernel/asm/io.asm).
//! System V x86_64 calling convention, C ABI.

extern "C" {
    /// Write a byte to an I/O port.
    pub fn outb(port: u16, val: u8);
    /// Read a byte from an I/O port.
    pub fn inb(port: u16) -> u8;
    /// Halt the CPU until the next interrupt.
    pub fn halt();
}
