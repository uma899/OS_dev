[org 0x7c00]    ; Tell the assembler where the BIOS will load this code



; ===============  It's a rule! As, its wired such a way in CISC. ===============
;  The internal circuitry of x86 is physically hardwired to favor specific registers. Explore what register used for what
; ===============						  ===============





; This function clears the screen AND resets the cursor
manual_clear:
    
    mov ax, 0xb800    ; AX is just a 16-bit accumulator register. The VGA "window" starts at 0xb8000
    mov es, ax        ; ES (Extra Segment) now points to Video Memory. We cant directly move an immediate into es register.

    
    xor di, di        ; Just to set DI = 0

    ; Prepare the Data Packet
    ; AH = Color (0x07 is Light Grey on Black)
    ; AL = Character (0x20 is ASCII Space)
    mov ax, 0x0720    

    mov cx, 2000      ; LOOP always uses CX. 80 columns * 25 rows: Its size of display in Real mode.
.loop:
    mov [es:di], ax   ; (ES * 16) + DI = Physical Address. Write the 16-bit word (Char + Color) to the bus
    add di, 2         ; Move to the next 16-bit slot (2 bytes further)
    dec cx            ; Decrement counter
    jnz .loop         ; If CX is not 0, repeat



; ============   This should be rewritten   ============

mov ah, 0x02    ; BIOS function: Set Cursor Position
mov bh, 0       ; Page number 0
mov dh, 12      ; Row 
mov dl, 35      ; Column 
int 0x10	; Its must after cursor update



mov ah, 0x0e
mov al, 'M'
int 0x10
mov al, 'a'
int 0x10
mov al, 'h'
int 0x10
mov al, 'e'
int 0x10
mov al, 's'
int 0x10
mov al, 'h'
int 0x10
mov al, ' '
int 0x10
mov al, 'O'
int 0x10
mov al, 'S'
int 0x10





; Wait sometime
mov dx, 0x5000
.outer2:
    mov cx, 0xFFFF
.inner2:
    nop  
    dec cx
    jnz .inner2	   
    dec dx    
    jnz .outer2
    
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
	int 0x10


	mov al, 0x02        ; "mins"
	out 0x70, al    

	in al, 0x71         ; Read the 8-bit value from the Data Port into AL
	call convert_BCD
	mov al, ':'
	int 0x10

	mov al, 0x00        ; Index 0 is "Seconds"
	out 0x70, al        ; Tell RTC we want to look at the Seconds register

	in al, 0x71         ; Read the 8-bit value from the Data Port into AL
	call convert_BCD
	
	call delay
	jmp timer
	

reset:
    mov ah, 0x02    ; BIOS function: Set Cursor Position
    mov bh, 0       ; Page number 0
    mov dh, 1       ; Row 0
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
	int 0x10 
	mov al, 'i'
	int 0x10 
	mov al, 'm'
	int 0x10 
	mov al, 'e'
	int 0x10 
	mov al, '-'
	int 0x10
	mov al, ' '
	int 0x10
	ret    
    
convert_BCD:
	; Convert BCD in AL to ASCII to print '2' then '5'
	mov bl, al          ; Save original BCD (e.g., 0x25)
	shr al, 4           ; Shift right by 4: AL is now 0x02
	add al, '0'         ; Convert 0x02 to ASCII '2'
	int 0x10     ; Your custom print function

	mov al, bl          ; Get original back
	and al, 0x0F        ; Mask out high nibble: AL is now 0x05
	add al, '0'         ; Convert 0x05 to ASCII '5'
	int 0x10
	ret


times 510-($-$$) db 0 ; Fill the rest of the 512 bytes with zeros
dw 0xaa55             ; The "Magic Number" that tells BIOS this is a bootable OS
