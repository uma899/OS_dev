/* linker.ld */
ENTRY(start_kernel)
SECTIONS {
    . = 0x1000; /* Match your KERNEL_OFFSET */
    .text : { *(.text) }
    .data : { *(.data) }
    .bss  : { *(.bss) }
}