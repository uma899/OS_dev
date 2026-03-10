[org 0x7c00]    ; Tell the assembler where the BIOS will load this code


; This function clears the screen AND resets the cursor
manual_clear:
    ; 1. Set up the Segment Register
    mov ax, 0xb800    ; The VGA "window" starts at 0xb8000
    mov es, ax        ; ES (Extra Segment) now points to Video Memory

    ; 2. Start at the beginning of the "Wire"
    xor di, di        ; DI = 0 (The very first byte of the screen)

    ; 3. Prepare the Data Packet
    ; AH = Color (0x07 is Light Grey on Black)
    ; AL = Character (0x20 is ASCII Space)
    mov ax, 0x0720    

    ; 4. The Loop (The "Banger")
    mov cx, 2000      ; 80 columns * 25 rows = 2000 cells
.loop:
    mov [es:di], ax   ; Write the 16-bit word (Char + Color) to the bus
    add di, 2         ; Move to the next 16-bit slot (2 bytes further)
    dec cx            ; Decrement counter
    jnz .loop         ; If CX is not 0, repeat



; ============   This should be rewritten   ============
;call reset
mov ah, 0x0e
mov al, 'M'
call print_char
mov al, 'a'
call print_char
mov al, 'h'
call print_char
mov al, 'e'
call print_char
mov al, 's'
call print_char
mov al, 'h'
call print_char
mov al, ' '
call print_char
mov al, 'O'
call print_char
mov al, 'S'
call print_char

mov dx, 0x5000    ; Outer Counter (2^11 iterations) => 2048*(1/2.5Ghz)*65535*2 = 0.1 sec
.outer2:
    mov cx, 0xFFFF  ; Inner Counter (65,535 iterations)
.inner2:
    nop             ; 1 cycle
    dec cx
    jnz .inner2	    ; Looks at the result of the previous operation
    dec dx          ; 1 cycle
    jnz .outer2      ; 3 cycles
    
; ====================================    





; --- Read Seconds from RTC ---
timer:
	call reset
	call title
	mov al, 0x04        ; "hrs"
	out 0x70, al        

	; Tiny delay is sometimes needed for the hardware to latch, 
	; but usually, the next instruction is fine on modern buses.

	in al, 0x71         ; Read the 8-bit value from the Data Port into AL

	call convert_BCD
	mov al, ':'
	call print_char


	mov al, 0x02        ; "mins"
	out 0x70, al    

	in al, 0x71         ; Read the 8-bit value from the Data Port into AL
	call convert_BCD
	mov al, ':'
	call print_char

	mov al, 0x00        ; Index 0 is "Seconds"
	out 0x70, al        ; Tell RTC we want to look at the Seconds register

	in al, 0x71         ; Read the 8-bit value from the Data Port into AL
	call convert_BCD
	
	call delay
	jmp timer
	

reset:
    mov ah, 0x02    ; BIOS function: Set Cursor Position
    mov bh, 0       ; Page number 0
    mov dh, 0       ; Row 0
    mov dl, 0       ; Column 0
    int 0x10       
    ret	


delay:
    mov dx, 0x400    ; Outer Counter (2^11 iterations) => 2048*(1/2.5Ghz)*65535*2 = 0.1 sec
.outer:
    mov cx, 0xFFFF  ; Inner Counter (65,535 iterations)
.inner:
    nop             ; 1 cycle
    dec cx
    jnz .inner	    ; Looks at the result of the previous operation
    dec dx          ; 1 cycle
    jnz .outer      ; 3 cycles
    ret
    
    
title:
	mov ah, 0x0e    ; BIOS scrolling teletype function
	mov al, 'T'     ; The character to print
	call print_char 
	mov al, 'i'
	call print_char 
	mov al, 'm'
	call print_char 
	mov al, 'e'
	call print_char 
	mov al, '-'
	call print_char
	mov al, ' '
	call print_char
	ret    
    
convert_BCD:
	; Convert BCD in AL to ASCII to print '2' then '5'
	mov bl, al          ; Save original BCD (e.g., 0x25)
	shr al, 4           ; Shift right by 4: AL is now 0x02
	add al, '0'         ; Convert 0x02 to ASCII '2'
	call print_char     ; Your custom print function

	mov al, bl          ; Get original back
	and al, 0x0F        ; Mask out high nibble: AL is now 0x05
	add al, '0'         ; Convert 0x05 to ASCII '5'
	call print_char
	ret



print_char:
  int 0x10
  ret


times 510-($-$$) db 0 ; Fill the rest of the 512 bytes with zeros
dw 0xaa55             ; The "Magic Number" that tells BIOS this is a bootable OS
