[org 0x7c00]
KERNEL_OFFSET equ 0x1000 
;global start
;extern kmain

start:

    mov [BOOT_DRIVE], dl    ; BIOS automatically stores boot device type (floppy - 0x00, HDD - 0x80) in dl register

    xor ax, ax    ; Set AX to 0
    mov ds, ax    ; DS = 0
    mov es, ax    ; ES = 0
    mov ss, ax    ; SS = 0
    mov sp, 0x7c00 ; Stack starts below the bootloader

    mov ax, 0xb800    ; AX is just a 16-bit accumulator register. The VGA "window" starts at 0xb8000
    mov es, ax        ; ES (Extra Segment) now points to Video Memory. We cant directly move an immediate into es register.

    

    

    xor ax, ax    ; Set AX to 0
    mov ds, ax    ; DS = 0
    mov es, ax    ; ES = 0
    mov ss, ax    ; SS = 0    
    mov si, ax    ; SS = 0    

    ; Setup a simple stack for the BIOS to work
    mov bp, 0x9000
    mov sp, bp

    call load_from_disk

    jmp KERNEL_OFFSET 





[bits 16]
load_from_disk:

    push dx
    xor ax, ax          ; Reset ES to 0
    mov es, ax
    mov ah, 0x00        ; Reset disk system
    int 0x13
    pop dx

    mov ah, 0x02            ; BIOS "Read Sectors" function
    mov al, 16              ; Number of sectors to read (increase this as your big file grows)
    mov ch, 0x00            ; Cylinder 0
    mov dh, 0x00            ; Head 0
    mov cl, 0x02            ; Start reading from sector 2 (Sector 1 is this bootloader)
    mov dl, [BOOT_DRIVE]    ; The drive we saved earlier
    mov bx, KERNEL_OFFSET   ; Destination address in RAM (0x1000)
    int 0x13                ; BIOS Interrupt for Disk I/O
    jc disk_error           ; If Carry Flag is set, the hardware failed
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

; BOOT_DRIVE db 0 is not a command for the CPU; it is an instruction for the Assembler (NASM).
; This is a label. It acts as a human-friendly name for a memory address. When you compile, NASM replaces this name with the actual offset (e.g., 0x7c3e).
; db: Stands for Define Byte. It tells the assembler, "Reserve exactly 1 byte of space right here."
; 0: This is the initial value placed in that byte.

 
times 510-($-$$) db 0       ; Pad to 510 bytes
dw 0xaa55                   ; The Magic Number