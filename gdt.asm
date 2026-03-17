

; =================== GDT Start ===================


gdt_start:          ; These are just labels (memory addresses). gdt_start marks the beginning of your table in RAM. gdt_end marks the end.
    dq 0x0          ; Null Descriptor: 8 bytes of zeros (Hardware Requirement)

; These are not an instructions. It is a Data Directive.
; 'd' for 'define', q - Quad-word (8 bytes), w - word (2 bytes), b - byte

gdt_code:           ; THE CODE SEGMENT
    dw 0xffff       ; Limit (0-15)
    dw 0x0          ; Base (0-15)
    db 0x0          ; Base (16-23), together with above gives 24 bits - only 24 as the original 80286 used 24-bit addresses.
    db 10011010b    ; Access: Present, Ring 0, Code, Executable, Readable. Here, b for binary
    db 11001111b    ; Flags: High 4 bits, (Granularity bit and 32-bit mode bit).
    db 0x0          ; Base (24-31)
                    ; Total = 8 bytes

; Note that, just the pointer of 'gdt_code' goes into 16 bit CS register. 
; Above big 8 bytes is just entry in the table and CS register has the label for this entry. CPU uses that address to look for the rules in this

gdt_data:           ; THE DATA SEGMENT
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b    ; Access: Present, Ring 0, Data, Writable
    db 11001111b
    db 0x0

; Observe that here we are using "Overlapping" segments
gdt_end:

; This is what we actually load into the CPU with the 'lgdt' instruction and this is the way lgdt instr expects.

gdt_descriptor:

    dw gdt_end - gdt_start - 1              ; Size (16 bits). This is an Expression. assembler does the math. 
                                            ; It subtracts the address of the start from the end to get the length in bytes
    dd gdt_start                            ; Assembler replaces this with the actual physical memory address of where gdt_start lives.


; So the data in this gdt_descriptor is actualluy an address. This is what stored in GDTR

; =================== GDT End ===================