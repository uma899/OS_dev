#include "io.h"

// Actual definitions
volatile char* vga = (char*) 0xb8000;

char scancode_to_ascii[128] = {
    0,    27,  '1', '2', '3', '4', '5', '6',        // 0x00 - 0x07
    '7',  '8', '9', '0', '-', '=', '\b', '\t',      // 0x08 - color
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





void update_cursor(int y, int x) {
    short int pos = y * 80 + x;

    port_byte_out(0x3D4, 0x0F);             // Select Low Byte
    port_byte_out(0x3D5, (int)(pos & 0xFF));
    
    port_byte_out(0x3D4, 0x0E);             // Select High Byte
    port_byte_out(0x3D5, (int)((pos >> 8) & 0xFF));
}



// These will be linked to your assembly implementations later
// (Keep them empty here or implement them in a separate .asm file)
