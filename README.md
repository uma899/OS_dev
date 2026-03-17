# An OS Bootloader

- This is a simple x86 bootloader written in assembly and coverted into binary instructions using NASM. It starts in **16-bit real mode** and successfully enter **32-bit protected mode** and prints Current time from the RTC (hours:minutes:seconds) on screen.
---

## Steps

- Boots using bootloader - boot.asm. It will be in real mode at start. It can access atmost 1MB of RAM.
- So, before entering enter into protected mode (32 bit), we have to make CPU aware of memory mapping and security. For that, a **Global Descriptor Table (GDT)** need to be specified and to be loaded.
- Once GDT is loaded, we can activate PM enable pin (by toggling LSB of CR0 register). Now, we are in Protected Mode and we have access to 4GB.
- Now, we can access VGA using memory addresses (0xB8000). When we write something to this address, Memory Controller reroutes it to VGA card wires.
- But, we can't do all these by loading just 512 bytes of instructions into RAM. (Since, CPU expects a bootloader to be exactly 512 bytes and its same as one sector of harddisk). So, we need to tell CPU to load remaining instructions into specific address in RAM (0x1000 in this case). Technically, we tell CPU to load remaining sectors from hard disk (or floppy).
- Now, CPU can successfully enter 32 bit PM. Now, CPU is instructed to:  Read RTC (Real-Time Clock) to get current time from its output ports and then copying into a register, then to a memory locaion, later to display character wise.
- Small Delay is given between reads using loops to prevent continuous reads from RTC.
- To add a feature, a keyboard interrrupt is written. Writing custom interrupt handlers involve declaring **IDT** and loading correct address into IDTR. 


---

## How to Build

Make sure you have **NASM** and **QEMU** installed.

```bash
nasm -f bin boot.asm -o boot.bin && \
nasm -f bin kernel.asm -o kernel.bin && \
cat boot.bin kernel.bin > os-image.bin && \
truncate -s 8192 os-image.bin && \
qemu-system-i386 -fda os-image.bin

```
If wanted to experiment, burn os-image.bin file into a USB and plug it in your PC. Boot into it. You can see it working! Try it at your own risk!
