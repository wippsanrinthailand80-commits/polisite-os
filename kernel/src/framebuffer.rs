//! Framebuffer helpers (Limine linear framebuffer).
//! Skeleton only fills the screen with a solid color; a real text/UI layer
//! (font, compositor, double buffering) is a Phase 2 task.

use limine::framebuffer::Framebuffer;

/// Fill the framebuffer with a 32-bit color (0x00RRGGBB).
pub fn fill(fb: &Framebuffer, color: u32) {
    let bpp = fb.bpp as usize;
    if bpp < 32 {
        return; // skeleton only handles 32-bit framebuffers
    }
    let pitch = fb.pitch as usize;
    let width = fb.width as usize;
    let height = fb.height as usize;

    // NOTE: limine crate 0.4 exposes the base as `fb.address` (a *mut u8).
    // If your pinned version uses `fb.addr`, change this one line.
    let base = fb.address as *mut u8;

    for y in 0..height {
        for x in 0..width {
            let offset = y * pitch + x * (bpp / 8);
            unsafe {
                let px = base.add(offset) as *mut u32;
                *px = color;
            }
        }
    }
}
