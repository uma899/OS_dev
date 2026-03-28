[org 0x1000]
[bits 16]


; To debug
; mov ah, 0x0e
; mov al, 'K'    ; just to say kernel mode entered
; int 0x10



start:

; getting into 32 bit mode! 

    cli                     ; Disable interrupts during transition

    lgdt [gdt_descriptor]   ; To search for GDT table in RAM and store that pointer into CPU's gdt register
                            ; Still, CS, DS .. register contains their old values
                            ; Assembler replaces [gdt_descriptor] with actual data in that address



; 3. Set Protected Mode bit. As CR0 has many other controls, just copy is, change bit and put back
    mov eax, cr0
    or eax, 0x1             
    mov cr0, eax

    jmp CODE_SEG:init_pm    ; Far jump to flush the pipeline as already 16-bit instructions would get loaded into its internal buffer.
    ; Also, it loads CS (Code Segment) register from the GDT



; ---------------------------------------------------------
; We are now in 32-bit MODE!
; ---------------------------------------------------------

;extern kmain


[bits 32]
init_pm:
    ; In 32-bit mode, our old segments (DS, ES, etc.) are invalid.
    ; we must point them to our DATA_SEG defined in the GDT.
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; Setup a new 32-bit stack. There are registers in CPU to hold top and current of stack
    ; EBP (Base Pointer): The fixed "High" address. Think of it as the Reference Point.
    ; ESP (Stack Pointer): The moving "Low" address. Think of it as the Active Probe.
    ; 'e' for extended
    mov ebp, 0x90000        ; Just some random address to be far but not chhosen over 1GB far as we are not guaranteed to have that much
    mov esp, ebp
    ; Once Kernel is written, we can change these pointers to high addresses.



    call setup_keyboard_idt     ; This and below one are in in isr.asm file 
    call remap_pic              
    lidt [idt_descriptor]       ; Tell CPU where the IDT is
    sti                         ; Turn on the "Interrupt" line    



; ====================== JUMP to C code !!!! ======================
    ;call kmain
; Below all wont if work if it jumped



    call clear_screen
    call print_string_32

    jmp main_32bit         ; Jump to your new OS logic
    ;jmp $


main_32bit:

    call update_time_buffer
    
    ; Add a small 32-bit delay here so it doesn't flicker.
    mov ecx, 0x1000000
    .delay:
        dec ecx
        jnz .delay
        jmp main_32bit


[bits 32]

; EBX = Address of the string to print
; EDX = Screen offset (e.g., 0 for top-left, 160 for second line)
print_string_32:
    pusha                   ; pusha = Save the state of all 8 general-purpose registers to the stack. We can even save state of just one register
                            ; popa = Restore those registers from the stack.
                            ; CPU has Stack Pointer (ESP) register in it.

    mov edx, 0xb8000
    mov ebx, string_from_32_mode       ; Find the physical address where the string starts and put that number into the EBX register.

    .loop:
        mov al, [ebx]           ; Get character. Without brackets, you are loading the memory address into the register. 
                                ; With brackets, you are reaching into that address to grab the actual data stored there.

        mov ah, 0x0f            ; Attribute (White on Black)

        cmp al, 0               ; Null terminator?
        je .done

        mov [edx], ax           ; Write 16-bit word to VGA bus. al (16 byte) = ah (high byte) al (low byte)
        add ebx, 1              ; Next char
        add edx, 2              ; Next VGA slot
        jmp .loop

    .done:
        popa                    ; Note that ret just takes back to exact previous instruction. But, hardware state might get changed
        ret                     ; So, push and pop are used.




update_time_buffer:
    pusha

    ; Hours
    mov al, 0x04
    out 0x70, al
    in al, 0x71
    mov edi, time_string    ; Point to the start of our buffer
    call bcd_to_buffer      ; Convert AL and store at EDI

    ; Minutes
    mov al, 0x02
    out 0x70, al
    in al, 0x71
    mov edi, time_string + 3 ; Skip "00:"
    call bcd_to_buffer

    ; Seconds
    mov al, 0x00
    out 0x70, al
    in al, 0x71
    mov edi, time_string + 6 ; Skip "00:00:"
    call bcd_to_buffer

    popa
    call print_time_buffer
    ret


; Same code is used to print as before
print_time_buffer:
    pusha
    mov edx, 0xb80f0        ; Make sure you start on right byte. Else, there will be color and character mismatch!
    mov ebx, time_string
    .loop:
        mov al, [ebx]
            

        mov ah, 0x0f 

        cmp al, 0    
        je .done

        mov [edx], ax
        add ebx, 1   
        add edx, 2   
        jmp .loop

    .done:
        popa                    ; Note that ret just takes back to exact previous instruction. But, hardware state might get changed
        ret                     ; So, push and pop are used.


bcd_to_buffer:
    mov bl, al
    shr al, 4
    add al, '0'
    mov [edi], al           ; Store tens digit
    mov al, bl
    and al, 0x0f
    add al, '0'
    mov [edi+1], al         ; Store units digit
    ret





; Never place these in between execution lines. CPU tries to execute them also which crashes system.

string_from_32_mode: db 'Text from Protected mode, You shouldnt have saw me :( ', 0
time_string: db '00:00:00', 0           ; We will store the time string here: "00:00:00", 0




[bits 32]
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




; Constants to help us jump to the right segments later
CODE_SEG equ gdt_code - gdt_start  ; It just tells the assembler: "Every time you see the word CODE_SEG, replace it with the result of this math.". Here, its 0x08
DATA_SEG equ gdt_data - gdt_start  ; Assembler uses addresses of these labels and subtract. Here, its 0x10



times 7680-($-$$) db 0