; =============== ISR ===============
[bits 32]
keyboard_handler:
    pusha                ; Save all registers

    in al, 0x60          ; Read the scan code from the keyboard controller
    
    ; --- Logic to handle the key ---
    ; (For now, let's just change a color on screen to prove it works)
    mov byte [0xb8001], al 

    ; --- SIGNAL THE EOI (End of Interrupt) ---
    ; We must tell the PIC chip we are done, or it will never 
    ; trigger another interrupt!
    mov al, 0x20
    out 0x20, al         ; Send EOI to Master PIC

    popa                 ; Restore registers
    iretd                ; Interrupt Return (32-bit version)


setup_keyboard_idt:
    mov eax, keyboard_handler   ; Load the full 32-bit address into EAX
    mov edx, idt_start          ; Point to the start of the IDT
    add edx, (33 * 8)           ; Offset to the 33rd slot (Keyboard)

    mov [edx], ax               ; Write Low 16 bits of address to Bytes 0-1
    mov word [edx + 2], 0x08    ; Write Selector (0x08) to Bytes 2-3
    mov byte [edx + 4], 0       ; Write Zero to Byte 4
    mov byte [edx + 5], 0x8E    ; Write Access/Type to Byte 5
    
    shr eax, 16                 ; Shift EAX right by 16 bits (Now EAX has High bits)
    mov [edx + 6], ax           ; Write High 16 bits of address to Bytes 6-7

    ret





; Re-address the PIC pins

remap_pic:
    ; ICW1 - Start initialization
    mov al, 0x11
    out 0x20, al        ; Master PIC
    out 0xA0, al        ; Slave PIC

    ; ICW2 - Remap the offset (Move IRQs to start at 0x20 / 32)
    mov al, 0x20
    out 0x21, al        ; Master IRQs (0-7) -> 32-39
    mov al, 0x28
    out 0xA1, al        ; Slave IRQs (8-15) -> 40-47

    ; ICW3 - Tell them how they are wired (Master/Slave connection)
    mov al, 0x04
    out 0x21, al
    mov al, 0x02
    out 0xA1, al

    ; ICW4 - Set 8086 mode
    mov al, 0x01
    out 0x21, al
    out 0xA1, al

    ; Mask everything except the Keyboard (IRQ 1)
    ; Bit 0 is Timer, Bit 1 is Keyboard. (0 = On, 1 = Off)
    mov al, 11111101b   
    out 0x21, al        ; Set mask on Master PIC
    mov al, 11111111b
    out 0xA1, al        ; Set mask on Slave PIC
    ret
    


