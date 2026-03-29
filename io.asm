global port_byte_in
global port_byte_out

port_byte_in:
    mov dx, [esp + 4] ; Get port from stack
    in al, dx         ; Read from port
    ret

port_byte_out:
    mov dx, [esp + 4] ; Get port from stack
    mov al, [esp + 8] ; Get value from stack
    out dx, al        ; Write to port
    ret