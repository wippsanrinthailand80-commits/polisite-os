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

    // limine crate 0.6 exposes the base via `fb.address()` (a *mut ()),
    // and width/height/pitch/bpp as public fields.
    let base = fb.address() as *mut u8;

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
