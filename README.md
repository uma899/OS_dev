# An OS Bootloader

This is a simple x86 bootloader written in NASM assembly. It runs in **16-bit real mode** and prints this on screen:

- Current time and date from the RTC (hours:minutes:seconds) and DD/MM/YY

---

## What it do?

- Clears screen with VGA text memory
- Prints text using BIOS teletype interrupt (`int 0x10`)
- Reads RTC (Real-Time Clock) to get current time and date from its output ports and then copying into a register, later to display character wise
- Used Delay loops to get in between intervals to prevent continuous reads from RTC


---

## How to Build

Make sure you have **NASM** and **QEMU** installed.

```bash
# Assemble the bootloader
nasm -f bin boot.asm -o boot.bin

# Run in QEMU
qemu-system-x86_64 boot.bin

```
If wanted to experiment, burn boot.bin into to the first sector of the USB and plug it in your PC. Boot into it. You can see it working! Try it at your own risk!
