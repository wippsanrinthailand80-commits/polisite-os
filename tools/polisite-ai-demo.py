#!/usr/bin/env python3
"""Polisite AI Demo — placeholder for the on-device inference runtime.

Uses the same vector-dot kernel idea from the original Zig layer, now as a
userspace demo. Real model weights + NPU/GPU offload land in Phase 3.
"""
def vector_dot(a, b):
    return sum(x*y for x, y in zip(a, b))

if __name__ == "__main__":
    a = [1.0, 2.0, 3.0, 4.0]
    b = [4.0, 3.0, 2.0, 1.0]
    print(f"Polisite AI demo — vector_dot({a}, {b}) = {vector_dot(a, b)}")
    print("AI runtime: CPU fallback active (NPU/GPU offload planned).")
