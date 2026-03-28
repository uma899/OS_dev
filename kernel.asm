[bits 16]
section .text
global start_kernel
extern kmain

start_kernel:
    cli                     ; Disable interrupts during transition
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 0x1             
    mov cr0, eax

    jmp CODE_SEG:init_pm

[bits 32]
init_pm:

    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000            ; Just some random address to be far but not chhosen over 1GB far as we are not guaranteed to have that much
    mov esp, ebp
    call setup_keyboard_idt     ; This and below one are in in isr.asm file 
    call remap_pic              
    lidt [idt_descriptor]       ; Tell CPU where the IDT is
    sti                         ; Turn on the "Interrupt" line    

    call clear_screen
; ====================== JUMP to C code !!!! ======================
    call kmain
; Below all wont if work if it jumped
    call print_string_32
    jmp $

print_string_32:
    pusha
    mov edx, 0xb8000
    mov ebx, string_from_32_mode
    .loop:
        mov al, [ebx] 
        mov ah, 0x0f            
        cmp al, 0               ; Null terminator?
        je .done
        mov [edx], ax           ; Write 16-bit word to VGA bus. al (16 byte) = ah (high byte) al (low byte)
        add ebx, 1              ; Next char
        add edx, 2              ; Next VGA slot
        jmp .loop
    .done:
        popa                    ; Note that ret just takes back to exact previous instruction. But, hardware state might get changed
        ret                     ; So, push and pop are used.



string_from_32_mode: db 'Text from Protected mode, You shouldnt have saw me :( ', 0

clear_screen:
    pusha
    mov edx, 0xb8000    ; Start of video memory
    mov eax, 0x0f20     ; White text on Black background, Space char
    mov ecx, 2000       ; 80 * 25 characters

.loop:
    mov [edx], ax       ; [ ] means value. Without it means address
    add edx, 2
    loop .loop

    popa
    ret

%include "gdt.asm"
%include "idt.asm"
%include "isr.asm"


CODE_SEG equ gdt_code - gdt_start  ; It just tells the assembler: "Every time you see the word CODE_SEG, replace it with the result of this math.". Here, its 0x08
DATA_SEG equ gdt_data - gdt_start  ; Assembler uses addresses of these labels and subtract. Here, its 0x10


;times 7680-($-$$) db 0