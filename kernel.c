
void printf(char* message){
    volatile char* vga_buffer = (char*) 0xb8000;
    int i = 0;
    while (message[i] != '\0')
    {
        vga_buffer[2*i] = message[i];
        vga_buffer[2*i + 1] = 0x0F;
        i++;
    }
}


void kmain() {
    printf("Whoaaa!! Its working..... It will work :)");
    while (1) {}    
}

