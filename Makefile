# Variables
AS = nasm
VM = qemu-system-x86_64
SRC = boot.asm
BIN = boot.bin

# Default target (runs when you just type 'make')
all: $(BIN)

# Rule to assemble the binary
$(BIN): $(SRC)
	$(AS) -f bin $(SRC) -o $(BIN)

# Rule to run the emulator
run: $(BIN)
	$(VM) $(BIN)

# Rule to clean up files
clean:
	rm -f $(BIN)

