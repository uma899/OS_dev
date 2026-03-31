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

typedef void (*command_func)(void); // A pointer to a function that takes nothing and returns nothing

struct CommandEntry {
    char* name;
    command_func func;
};

// Your actual functions

unsigned int var_a = 0;
unsigned int var_b = 0;


void add() {         
        int result;
        result = var_a + var_b;
        char* itoc_ptr;
        itoc_ptr = itoc(result);
        fill_output("ADD result: ", itoc_ptr);
}

void sub() {         
        int result;
        result = var_a - var_b;
        char* itoc_ptr;
        itoc_ptr = itoc(result);
        fill_output("SUB result: ", itoc_ptr);
}

void mul() {         
        int result;
        result = var_a * var_b;
        char* itoc_ptr;
        itoc_ptr = itoc(result);
        fill_output("MUL result: ", itoc_ptr);
}

void div() {         
        int result;
        result = var_a / var_b;
        char* itoc_ptr;
        itoc_ptr = itoc(result);
        fill_output("DIV result: ", itoc_ptr);
}

void help() {
    if (line >= 15) {
        line = 15;
        scroll_screen();
        scroll_screen();
        scroll_screen();
        scroll_screen();
    }    
    show("Help:", line);
    line++;        
    show("Ex: add 2 4", line);
    line++;
    show("Ex: say hello", line);
    line++;
    show("Size of numbers is limited. Try crashing system by typing something. You can :)", line);
    line++;
    show("Available: add sub mul div say reboot", line);
    line++;
    show("If went out of screen, dont panic! type 'reboot' and press enter. Yet to correct", line);    
}

void say() {
    char* itoc_ptr;
    itoc_ptr = input_buffer + 2;
    fill_output("", itoc_ptr);    
}

void do_ntng() {
    char temp = '\0';
    fill_output("Invalid operation!! type help for help", &temp);
}


void do_reboot() { 
    show("Rebooting in a sec...", line);
    delay(200);
    reboot();    
 }

// The Table
struct CommandEntry cmd_table[] = {
    {"add", add},
    {"sub", sub},
    {"mul", mul},
    {"div", div},
    {"say", say},
    {"reboot", do_reboot},
    {"help", help},
    {0, 0}          // Null terminator for the table
};

void read_op() {

    char cmd_name[15];
    // char* cmd_name;    // Try avoiding this as it allocates at random spot, which can be idt itself
    int i = 0;

    while (input_buffer[i] != ' ')
    {
        cmd_name[i] = input_buffer[i];
        i++;
    }

    cmd_name[i] = '\0';
    i++;
    
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

    int j = 0;
    while (cmd_table[j].name != 0) {
        if (strcmp(cmd_name, cmd_table[j].name) == 0) {
            cmd_table[j].func(); // JUMP to the function!
            return;
        }
        j++;
    }
    do_ntng();
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

                update_cursor(line, offset);
            } 
            break;

        case 0x1C: // Enter key 

            if (line >= 20) {
                line = 19;
                scroll_screen();
                scroll_screen();
            }


            input_buffer[buffer_index] = ' ';   // to put space character at last. As read_op looks for it as end

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
            update_cursor(line, offset);
            break;

        default:
            if (scancode_to_ascii[scancode] != 0) {
                vga[position] = scancode_to_ascii[scancode];
                vga[position + 1] = color;
                offset++;
                update_cursor(line, offset);
                input_buffer[buffer_index] = scancode_to_ascii[scancode];
                buffer_index++;
            }
            break;
    }
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
    update_cursor(line, offset);

    while (1) {
        show_time();
    }    
}
