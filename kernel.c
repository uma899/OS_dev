# define padding 9
# define color 0x0E

volatile char* vga = (char*) 0xb8000;


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

/*
int ctoi(char number) {
    int i;
    for (i = 1; i <= 10; i++)
    {
        if (number == scancode_to_ascii[i]) break;
    }
    return i;
}
*/


int ctoi(char c) {
    if (c >= '0' && c <= '9') {
        return c - '0';  // '1' (49) - '0' (48) = 1
    }
    return 0;
}



char result_text[5];            // took max result is 9999


// below need to be generalised
void itoc(int number) {
    result_text[0] = (number / 1000) + '0';
    result_text[1] = ((number % 1000) / 100) + '0';
    result_text[2] = ((number % 100) / 10) + '0';
    result_text[3] = (number % 10) + '0';
    result_text[4] = '\0';
}



volatile int line = 1;
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

void fill_output(char* result) {
    int i = 0;
    while (result[i] != '\0')
    {
        output_buffer[i] = result[i];
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
unsigned var_b = 0;

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
   
    
    switch (input_buffer[0])
    {
    case 'a':
        result = var_a + var_b;

        itoc(result);
        fill_output("ADD result: ");
        break;

    case 's':
        result = var_a - var_b;

        itoc(result);
        fill_output("SUB result: ");
        break;   

    case 'm':
        result = var_a * var_b;

        itoc(result);
        fill_output("MUL result: ");
        break;
        
    case 'd':
        result = var_a / var_b;

        itoc(result);
        fill_output("DIV result: ");
        break;        
    
    default:
        fill_output("Invalid operation!!");
        break;
    }    
   
}


void handle_keyboard() {
    unsigned char scancode = port_byte_in(0x60);


    position = line*160 + 2*offset;


    if (scancode & 0x80) {
        end_interrupt();
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

    end_interrupt();
}





void kmain() {
    show("Command Line", 0);

    show("Command> ", 1);

    while (1) {

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