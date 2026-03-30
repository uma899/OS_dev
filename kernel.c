#include "funs.h"
#include "io.h"
#define padding 9
#define color 0x0E


volatile int line = 2;
volatile int offset = padding;

int position;


char input_buffer[80]; // Stores up to 80 characters of a command
volatile int buffer_index = 0;

char output_buffer[80];


void clear_buffer(char buffer[]) {
    for (int i = 0; i < 80; i++)
    {
        buffer[i] = '\0';
    }
    
}

void fill_output(char* operation, char* result_text) {

    int i = 0;
    
    while (operation[i] != '\0')
    {
        output_buffer[i] = operation[i];
        i++;
    }    

    int j = 0;

    while (result_text[j] != '\0')
    {
        output_buffer[i] = result_text[j];
        j++;
        i++;
    }
    
}

unsigned int var_a = 0;
unsigned int var_b = 0;

// strictly, Input format: a 56 89

void read_op() {
    int i = 2;
    while (input_buffer[i] != ' ')
    {
        var_a = var_a * 10 + ctoi(input_buffer[i]);
        i++;
    }

    i++;
    while (input_buffer[i] != ' ')
    {
        var_b = var_b * 10 + ctoi(input_buffer[i]);
        i++;
    }    

    unsigned int result;    

    char* itoc_ptr;
   
    
    switch (input_buffer[0])
    {
    case 'a':
        result = var_a + var_b;

        itoc_ptr = itoc(result);
        fill_output("ADD result: ", itoc_ptr);
        break;

    case 's':
        result = var_a - var_b;

        itoc_ptr = itoc(result);
        fill_output("SUB result: ", itoc_ptr);
        break;   

    case 'm':
        result = var_a * var_b;

        itoc_ptr = itoc(result);
        fill_output("MUL result: ", itoc_ptr);
        break;
        
    case 'd':
        result = var_a / var_b;

        itoc_ptr = itoc(result);
        fill_output("DIV result: ", itoc_ptr);
        break;
        
    case 'h':

        show("Help:", line);
        line++;        
        show("Ex: a 2 4", line);
        line++;
        show("Ex: t hello", line);
        line++;
        show("Size of numbers is limited. Try crashing system by typing something. You can :)", line);
        line++;
        show("All commands are single letters for now. Available: a s m d t r", line);
        line++;
        show("If went out of screen, dont panic! type 'r' and press enter. Yet to correct", line);
        
        break;

    case 't':       // tell
        itoc_ptr = input_buffer + 2;
        fill_output("", itoc_ptr);    
        break;

    case 'r':
        show("Rebooting in a sec...", line);
        delay(200);
        reboot();
        break;        
        
    
    default:
        char temp = '\0';
        fill_output("Invalid operation!! type h for help", &temp);
        break;
    }    
   
}


void handle_keyboard() {
    unsigned char scancode = port_byte_in(0x60);


    position = line*160 + 2*offset;


    if (scancode & 0x80) {
        return;
    }

    switch (scancode) {
        case 0x0E: // Backspace
            if (offset > padding) {
                offset--;
                buffer_index--; // Important: Step back in the buffer too!
                input_buffer[buffer_index] = '\0'; // Clear the character in the buffer                
                vga[line*160 + 2*offset] = ' ';
                vga[line*160 + 2*offset + 1] = color;     
            } 
            break;

        case 0x1C: // Enter key 
            input_buffer[buffer_index] = ' ';


            line++;

            read_op();
            show(output_buffer, line);
            buffer_index = 0;
            clear_buffer(input_buffer);
            clear_buffer(output_buffer);

            line++ ;        

            var_a = 0;
            var_b = 0;            

            show("Command> ", line);
            offset = padding;
            break;


        default:
            if (scancode_to_ascii[scancode] != 0) {
                vga[position] = scancode_to_ascii[scancode];
                vga[position + 1] = color;
                offset++;


                input_buffer[buffer_index] = scancode_to_ascii[scancode];
                buffer_index++;
            }
            break;
    }


    //vga[position + 1] = '_';
    //vga[position + 3] = color;

}


void show_time() {

    

    port_byte_out(0x70, 0x04);
    unsigned char h_bcd = port_byte_in(0x71);       // unsigned char is like 8 bit int

    port_byte_out(0x70, 0x02);
    unsigned char m_bcd = port_byte_in(0x71);

    port_byte_out(0x70, 0x00);
    unsigned char s_bcd = port_byte_in(0x71);


    unsigned char hours = ((h_bcd >> 4) * 10) + (h_bcd & 0x0F);
    unsigned char mins = ((m_bcd >> 4) * 10) + (m_bcd & 0x0F);
    unsigned char secs = ((s_bcd >> 4) * 10) + (s_bcd & 0x0F);

    put(itoc(hours), 1, 36);
    put(":", 1, 38);
    put(itoc(mins), 1, 39);
    put(":", 1, 41);
    put(itoc(secs), 1, 42);

    delay(200);
}




void kmain() {
    show("Command Line - OS by Mahesh", 0);

    show("Command> ", 2);


    while (1) {
        show_time();
    }    
}















/*
void scroll_screen() {
    volatile char* vga = (char*)0xB8000;

    for (int i = 0; i < 24 * 80 * 2; i++) {
        vga[i] = vga[i + 160];
    }

    for (int i = 24 * 80 * 2; i < 25 * 80 * 2; i += 2) {
        vga[i] = ' '; 
        vga[i + 1] = color;
    }
}
*/


/*
int pow(int base, int power) {
    int i = 0;
    int value = 1;
    while (i < power)
    {
        value = value*base;
        i++;
    }
    return value;
}*/