[bits 16]
; No [org] here if using a linker, but since we will compile to bin, use:
[org 0x7c00]

start_boot:
    mov [BOOT_DRIVE], dl
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    mov ax, 0xb800
    mov es, ax    
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov si, ax
    mov bp, 0x9000
    mov sp, bp
    call load_from_disk
    jmp 0x1000 

[bits 16]
load_from_disk:
    push dx
    xor ax, ax          ; Reset ES to 0
    mov es, ax
    mov ah, 0x00        ; Reset disk system
    int 0x13
    pop dx
    mov ah, 0x02 
    mov al, 16           
    mov ch, 0x00         
    mov dh, 0x00         
    mov cl, 0x02         
    mov dl, [BOOT_DRIVE] 
    mov bx, 0x1000
    int 0x13             
    jc disk_error        
    ret

disk_error:
    mov bh, ah          ; Save error code in BH
    mov ah, 0x0e
    mov al, 'E'         ; 'E' for Error
    int 0x10
    mov al, bh          ; Move error code to AL
    add al, '0'         ; To convert to ASCII digit. ASCII numbers, start from 0. And we get a number for error.
    int 0x10
    jmp $

BOOT_DRIVE db 0
times 510-($-$$) db 0       ; Pad to 510 bytes
dw 0xaa55                   ; The Magic Number