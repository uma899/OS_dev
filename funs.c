void scroll_screen() {
    volatile char* vga = (char*)0xB8000 + 320;

    for (int i = 0; i < 24 * 80 * 2; i++) {
        vga[i] = vga[i + 160];
    }

    for (int i = 24 * 80 * 2; i < 25 * 80 * 2; i += 2) {
        vga[i] = ' '; 
        vga[i + 1] = 0x0E;
    }
}

void show(char* message, int line){
    unsigned int location = 0xb8000 + 160*line;
    volatile char* vga_buffer = (char*) location;
    int i = 0;
    while (message[i] != '\0')
    {
        vga_buffer[2*i] = message[i];
        vga_buffer[2*i + 1] = 0x0F;
        i++;
    }
}

void put(char* message, int line, int offset) {
    unsigned int location = 0xb8000 + 160*line + offset*2;
    volatile char* vga_buffer = (char*) location;
    int i = 0;
    while (message[i] != '\0')
    {
        vga_buffer[2*i] = message[i];
        vga_buffer[2*i + 1] = 0x0F;
        i++;
    }
}


int strcmp(char* s1, char* s2) {
    int i = 0;
    while (s1[i] == s2[i]) {
        if (s1[i] == '\0') return 0;    // 0 => matched
        i++;
    }
    return s1[i] - s2[i];
}


int ctoi(char c) {
    if (c >= '0' && c <= '9') {
        return c - '0';  // '1' (49) - '0' (48) = 1
    }
    return 0;
}


// May break in some cases. int can be positive for now. Rewrite it!
char* itoc(int number) {

    char* result_text;

    if (number == 0) {
        *(result_text) = '0';
        *(result_text + 1) = '\0';
        return result_text;
    }

    int divBy = 1;
    int currentVal = number;

    int digits = 0;

    while (currentVal)
    {
        digits++;
        currentVal = currentVal / 10;
    }   
    
    *(result_text + digits) = '\0';

    while (digits)
    {
        *(result_text + digits - 1) = ((number % (10*divBy)) / divBy) + '0';
        divBy = divBy * 10;
        digits--;
    }

    return result_text;
}




// Its very inaccurate
void delay(int ms) {
    int delay = ms * 2000000;   // clock speed of CPU
    
    while (delay)
    {
        delay--;
    }
    
}
