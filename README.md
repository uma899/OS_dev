# Changes...

Made many seperate files for different functions.
Functions like integer to characters (itoc) is generalised.
Added time.
Added reboot command.
Calculator is unsigned and can work upto 31 bits result (probably..)

# What's New?
Its a terminal with a running process (time) !!!!

# Next Task
* Seperate terminal as other process instead of relying on keyboard handler to do everything. 
* Scheduler, which works with timer inerrupt, to handle these two processes.



Read prev versions for better documentation


---

## How to Build

Make sure you have **NASM** and **QEMU** installed.

```bash
nasm -f bin boot.asm -o boot.bin && \
nasm -f elf32 kernel.asm -o kernel_entry.o && \
nasm -f elf32 io_port.asm -o io_port.o && \
nasm -f elf32 sys_utils.asm -o sys_utils.o && \
gcc -m32 -ffreestanding -fno-pic -fno-stack-protector -c kernel.c -o kernel.o && \
gcc -m32 -ffreestanding -fno-pic -fno-stack-protector -c io.c -o io.o && \
gcc -m32 -ffreestanding -fno-pic -fno-stack-protector -c funs.c -o funs.o && \
ld -m elf_i386 -T linker.ld -o kernel.bin --oformat binary kernel_entry.o kernel.o io.o sys_utils.o io_port.o funs.o && \
cat boot.bin kernel.bin > os-image.bin && \
qemu-system-i386 -fda os-image.bin

```