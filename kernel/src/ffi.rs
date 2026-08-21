//! FFI declarations for the C and Zig layers.
//! All cross-language calls use a flat `extern "C"` ABI (see docs/DESIGN.md).

extern "C" {
    /// Defined in kernel/c/rt.c. Returns a sentinel so we can prove C linkage.
    pub fn c_hello() -> u32;

    /// Defined in kernel/zig/ai_math.zig. Dot product of two f32 vectors.
    /// This is the seed of the AI math kernel layer.
    pub fn zig_vector_dot(a: *const f32, b: *const f32, n: usize) -> f32;
}
