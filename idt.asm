idt_start:
    times 256 dq 0  ; Reserve 256 empty slots (2048 bytes)
idt_end:

idt_descriptor:
    dw idt_end - idt_start - 1 ; Size
    dd idt_start               ; Address
