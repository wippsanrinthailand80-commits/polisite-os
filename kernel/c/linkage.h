/* Shared ABI notes for the C layer. All exported symbols use the C calling
 * convention and a flat signature. Keep this header in sync with the Rust
 * `extern "C"` declarations in kernel/src/ffi.rs.
 */
#ifndef POLISITE_LINKAGE_H
#define POLISITE_LINKAGE_H

typedef unsigned int       uint32_t;
typedef unsigned long long uint64_t;

#endif /* POLISITE_LINKAGE_H */
