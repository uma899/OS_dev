
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


// Declare the assembly functions
unsigned char port_byte_in(unsigned short port);
void port_byte_out(unsigned short port, unsigned char data);
void end_interrupt();

char scancode_to_ascii[128] = {
    0,    27,  '1', '2', '3', '4', '5', '6',        // 0x00 - 0x07
    '7',  '8', '9', '0', '-', '=', '\b', '\t',      // 0x08 - 0x0F
    'q',  'w', 'e', 'r', 't', 'y', 'u', 'i',        // 0x10 - 0x17
    'o',  'p', '[', ']', '\n', 0,   'a', 's',       // 0x18 - 0x1F
    'd',  'f', 'g', 'h', 'j', 'k', 'l', ';',        // 0x20 - 0x27
    '\'', '`', 0,  '\\','z', 'x', 'c', 'v',         // 0x28 - 0x2F
    'b',  'n', 'm', ',', '.', '/', 0,   '*',        // 0x30 - 0x37
    0,    ' ', 0,   0,   0,   0,   0,   0,          // 0x38 - 0x3F (Shift, space, etc.)
    
    // 0x40 - 0x4F
    0,    0,   0,   0,   0,   0,   0,   '7',
    '8',  '9', '-', '4', '5', '6', '+', '1',

    // 0x50 - 0x5F
    '2',  '3', '0', '.', 0,   0,   0,   0,
    0,    0,   0,   0,   0,   0,   0,   0,

    // 0x60 - 0x6F
    0,    0,   0,   0,   0,   0,   0,   0,
    0,    0,   0,   0,   0,   0,   0,   0,

    // 0x70 - 0x7F
    0,    0,   0,   0,   0,   0,   0,   0,
    0,    0,   0,   0,   0,   0,   0,   0
};

volatile int pos = 0;



void scroll_screen() {
    volatile char* vga = (char*)0xB8000;

    for (int i = 0; i < 24 * 80 * 2; i++) {
        vga[i] = vga[i + 160];
    }

    for (int i = 24 * 80 * 2; i < 25 * 80 * 2; i += 2) {
        vga[i] = ' '; 
        vga[i + 1] = 0x0F;
    }
}



void handle_keyboard() {
    unsigned char scancode = port_byte_in(0x60);
    volatile char* vga = (char*) 0xb8140;


    if (scancode & 0x80) {
        end_interrupt();
        return;
    }

    switch (scancode) {
        case 0x0E: // Backspace
            if (pos > 0) {
                pos = pos - 2;
                vga[pos] = ' ';
                vga[pos + 1] = 0x0F;

                vga[pos + 2] = ' ';
                vga[pos + 3] = 0x0F;                    
            }
            break;

        case 0x1C: // Enter key 
            vga[pos] = ' ';
            vga[pos + 1] = 0x0F;         
            pos = 160*(((pos) / 160)+1);
            break;


        default:
            if (scancode_to_ascii[scancode] != 0) {
                vga[pos] = scancode_to_ascii[scancode];
                vga[pos + 1] = 0x0F;
                pos = pos + 2;
            }
            break;
    }

    if (pos > 22*160 - 1) {
        scroll_screen();
        pos = pos - 160;
    }

        vga[pos] = '_';
        vga[pos + 1] = 0x0F;    

    end_interrupt();
}





void kmain() {
    show("Whoaaa!! Its working..... It will work :)", 0);
    show("You cant come here. Type something:-", 1);

    volatile char* vga = (char*) 0xb8140;

    while (1) {

    }    
}

