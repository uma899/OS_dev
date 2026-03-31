31 Mar 2026

# **V6**

## Changes...
A better version..
Added scroll. Can now type commands as words instead of letters. 

## Next
Seperate keyboard handler from terminal process. Make handler generic. Write a scheduler to manage two 
processes - Terminal and Clock. Use timer interrupt to switch between processes.

---

# **V5**
## Changes...

Made many seperate files for different functions.
Functions like integer to characters (itoc) is generalised.
Added time.
Added reboot command.
Calculator is unsigned and can work upto 31 bits result

## What's New?
Its a terminal with a running process (time) !!!!

## Next Task
* Seperate terminal as other process instead of relying on keyboard handler to do everything. 
* Scheduler, which works with timer inerrupt, to handle these two processes.




#### How to Build


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


---

# **V4**
## Changes...
Its a calculator!!!! Terminal like...

---

# **V3**
## What's new?
There is a linker. Now can use C to write kernel!!
In the final compilation is such that all object files are attached. So, the kernel.asm can call the 
main function of C. From then, what instructions in kernel.c are executed. As while (1) is written, it
cant come out of that C code to assembly.

We can now write in C. Access hardware ports from C!

**How?**
See io.asm file. Same names used in kernel.c. As we call that function with some parameters in, it places
that variable on stack and then call that function. That function in assembly does something and put 
result in ax (eax) register. It is a convention in C that return value must be in eax and functional 
arguments to be pushed onto stack.

And, keyboard handler, which used to be in assembly in previous version, now written in C and its address 
(just label) is given to isr. So from now, all interrupt handers can be written in C but they should be 
informed to isr so it can know where to jump.


## What it can do 
You can write, press enter, scroll down (but not up).


## Whats next?
Trying to use direct pixels to display!


---

# **V2**

## Into 32 bit

- This is a simple x86 bootloader written in assembly and coverted into binary instructions using NASM. It starts in **16-bit real mode** and successfully enter **32-bit protected mode** and prints Current time from the RTC (hours:minutes:seconds) on screen.

#### Working

- Boots using bootloader - boot.asm. It will be in real mode at start. It can access atmost 1MB of RAM.
- So, before entering enter into protected mode (32 bit), we have to make CPU aware of memory mapping and security. For that, a **Global Descriptor Table (GDT)** need to be specified and to be loaded.
- Once GDT is loaded, we can activate PM enable pin (by toggling LSB of CR0 register). Now, we are in Protected Mode and we have access to 4GB.
- Now, we can access VGA using memory addresses (0xB8000). When we write something to this address, Memory Controller reroutes it to VGA card wires.
- But, we can't do all these by loading just 512 bytes of instructions into RAM. (Since, CPU expects a bootloader to be exactly 512 bytes and its same as one sector of harddisk). So, we need to tell CPU to load remaining instructions into specific address in RAM (0x1000 in this case). Technically, we tell CPU to load remaining sectors from hard disk (or floppy).
- Now, CPU can successfully enter 32 bit PM. Now, CPU is instructed to:  Read RTC (Real-Time Clock) to get current time from its output ports and then copying into a register, then to a memory locaion, later to display character wise.
- Small Delay is given between reads using loops to prevent continuous reads from RTC.
- To add a feature, a keyboard interrrupt is written. Writing custom interrupt handlers involve declaring **IDT** and loading correct address into IDTR. 



#### How to Build

Make sure you have **NASM** and **QEMU** installed.

```bash
nasm -f bin boot.asm -o boot.bin && \
nasm -f bin kernel.asm -o kernel.bin && \
cat boot.bin kernel.bin > os-image.bin && \
truncate -s 8192 os-image.bin && \
qemu-system-i386 -fda os-image.bin

```
If wanted to experiment, burn os-image.bin file into a USB and plug it in your PC. Boot into it. You can see it working! Try it at your own risk!

---
# **V1**

## An OS Bootloader

This is a simple x86 bootloader written in NASM assembly. It runs in **16-bit real mode** and prints this on screen:

- Current time from the RTC (hours:minutes:seconds)


#### What it do?

- Clears screen with VGA text memory
- Prints text using BIOS teletype interrupt (`int 0x10`)
- Reads RTC (Real-Time Clock) to display current time
- Delay loops for timing



#### How to Build

Make sure you have **NASM** and **QEMU** installed.

```bash
## Assemble the bootloader
nasm -f bin boot.asm -o boot.bin

## Run in QEMU
qemu-system-x86_64 boot.bin