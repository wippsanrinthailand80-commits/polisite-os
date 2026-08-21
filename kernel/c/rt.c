/* Polisite OS — C layer (low-level helpers).
 * Built freestanding: -ffreestanding -mno-red-zone -fno-pic -nostdlib.
 * Role: tiny C runtime bits and reusable C algorithms.
 */

#include <stdint.h>

/* Sentinel proving the C layer linked and is callable from Rust. */
uint32_t c_hello(void) {
    return 0xC0FFEEu;
}
