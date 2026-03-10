# An OS Bootloader

This is a simple x86 bootloader written in NASM assembly. It runs in **16-bit real mode** and prints this on screen:

- Current time from the RTC (hours:minutes:seconds)

---

## What it do?

- Clears screen with VGA text memory
- Prints text using BIOS teletype interrupt (`int 0x10`)
- Reads RTC (Real-Time Clock) to display current time
- Delay loops for timing


---

## How to Build

Make sure you have **NASM** and **QEMU** installed.

```bash
# Assemble the bootloader
nasm -f bin boot.asm -o boot.bin

# Run in QEMU
qemu-system-x86_64 boot.bin
