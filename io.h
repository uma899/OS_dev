#ifndef IO_H
#define IO_H

// Pointers and Arrays need 'extern' so they aren't redefined
extern volatile char* vga;
extern char scancode_to_ascii[128];
void update_cursor(int y, int x);

// Function prototypes (implicitly extern)
unsigned char port_byte_in(unsigned short port);
void port_byte_out(unsigned short port, unsigned char data);


void end_interrupt();


void reboot();

#endif
