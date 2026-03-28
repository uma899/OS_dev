
; Re-address the PIC pins
; Take help to understand this
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
    





; =============== ISR ===============


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



[bits 32]
keyboard_handler:
    pusha
    
    in al, 0x60             
    test al, 0x80           
    jnz .only_eoi           ; If it's a release, just signal EOI and leave

    ; --- Lookup ASCII ---
    movzx ebx, al           
    mov al, [scancode_table + ebx]
    or al, al               
    jz .only_eoi            ; If not printable, don't move cursor or print

    mov cl, al              ; copy ASCII into cl register as we are tampering al below

    call get_cursor_position ; AX = current index
    cmp cl, 0x08
    je .handle_backspace
    
    ; 2. Print
    movzx edi, ax
    shl edi, 1
    add edi, 0xB8000
    mov [edi], cl
    mov byte [edi + 1], 0x0D

    ; 3. INCREMENT and UPDATE
    inc ax                  ; MOVE TO NEXT SLOT
    call update_cursor       ; Tell hardware we moved
    jmp .only_eoi
 
.handle_backspace
    movzx edi, ax
    shl edi, 1
    add edi, 0xB8000
    cmp edi, 0xB86e0
    jz .only_eoi
    mov byte [edi - 2], ' '
    mov byte [edi - 1], 0x07
    dec ax
    call update_cursor


.only_eoi:
    mov al, 0x20            ; EOI
    out 0x20, al
    popa
    iretd


; A simple lookup table for scancodes 0x01 to 0x39
scancode_table:
    db 0, 27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0x08 ; Backspace
    db 0x09, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 0x0D ; Enter
    db 0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '`', 0
    db '\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, '*', 0, ' '




get_cursor_position:
    ; Get High Byte (Register 0x0E)
    mov dx, 0x3D4       ; Port 0x3D4 is the index register
    mov al, 0x0E        ; We want register 0x0E (High byte)
    out dx, al
    
    mov dx, 0x3D5       ; Port 0x3D5 is the data register
    in al, dx           ; Read the high byte into AL
    mov ah, al          ; Move it to AH (High part of AX)

    ; Get Low Byte (Register 0x0F)
    mov dx, 0x3D4
    mov al, 0x0F        ; We want register 0x0F (Low byte)
    out dx, al
    
    mov dx, 0x3D5
    in al, dx           ; Read the low byte into AL

    ; AX now contains the full 16-bit cursor offset (0-1999)
    ret


; Expects the new 1-D position (0-1999) in AX
update_cursor:
    pusha                   ; Save all registers
    mov bx, ax              ; Store the new position in BX

    ; Send High Byte (Register 0x0E)
    mov dx, 0x3D4
    mov al, 0x0E
    out dx, al

    mov dx, 0x3D5
    mov al, bh              ; BH is the high byte of the new position
    out dx, al

    ; Send Low Byte (Register 0x0F)
    mov dx, 0x3D4
    mov al, 0x0F
    out dx, al

    mov dx, 0x3D5
    mov al, bl              ; BL is the low byte of the new position
    out dx, al

    popa
    ret    