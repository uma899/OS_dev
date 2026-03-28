// This is your new "main"
void kmain() {
    // Create a pointer to the VGA buffer
    // Volatile tells the compiler: "Don't optimize this away, the hardware is watching!"
    volatile char* vga_buffer = (char*) 0xb8000;

    // Write 'C' to the top left
    vga_buffer[0] = 'C'; 
    vga_buffer[1] = 0x0F; // White on Black
}