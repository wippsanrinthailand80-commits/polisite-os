// Polisite OS — Zig layer (AI / performance math kernels).
//
// Role: hot numeric loops and AI primitives, exposed via a flat C ABI so Rust
// can call them. Build with:
//   zig build-obj -target x86_64-freestanding -O ReleaseSafe ai_math.zig
//
// `export fn` in Zig uses the C calling convention for C-compatible signatures.

/// Dot product of two f32 vectors. Seed for the tensor/AI runtime.
export fn zig_vector_dot(a: [*]const f32, b: [*]const f32, n: usize) f32 {
    var sum: f32 = 0.0;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        sum += a[i] * b[i];
    }
    return sum;
}
