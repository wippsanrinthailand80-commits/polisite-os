/* Polisite OS kernel linker script.
 * Higher-half kernel loaded by Limine at 0xffffffff80000000.
 * Limine sets up the page tables; we only describe our layout.
 */
ENTRY(_start)

KERNEL_BASE = 0xffffffff80000000;

SECTIONS {
    . = KERNEL_BASE;

    .text : ALIGN(0x1000) {
        *(.text .text.*)
    }

    .rodata : ALIGN(0x1000) {
        *(.rodata .rodata.*)
        /* Limine scans this section for boot requests; must not be stripped. */
        KEEP(*(.limine_reqs))
        KEEP(*(.limine_reqs.*))
    }

    .data : ALIGN(0x1000) {
        *(.data .data.*)
    }

    .bss (NOLOAD) : ALIGN(0x1000) {
        *(COMMON)
        *(.bss .bss.*)
    }

    _kernel_end = .;
}
