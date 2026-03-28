ENTRY(start)

SECTIONS {
    /* Stage 1: The Bootloader (512 bytes) */
    . = 0x7C00;
    .boot : {
        boot.o(.text)
        boot.o(.data)
    }
    
    /* Ensure the boot signature is exactly at the end of the first 512 bytes */
    . = 0x7C00 + 510;
    .sig : { SHORT(0xAA55) }

    /* Stage 2: The Kernel (Starts at 0x7E00) */
    . = 0x7E00;
    .text : { *(.text) }
    .data : { *(.data) }
    .bss  : { *(.bss)  }
}