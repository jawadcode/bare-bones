extern kernel_main

; Declare constants for the Multiboot header:
ALIGNM   equ 1                 ; Align loaded modules on page boundaries
MEMINFO  equ 1 << 1            ; Provide memory map
FLAGS    equ ALIGNM | MEMINFO  ; Multiboot 'flag' field
MAGIC    equ 0x1BADB002        ; 'magic number' which allows the bootloader to find the header
CHECKSUM equ -(MAGIC + FLAGS)  ; Checksum of the above, to prove we are Multiboot

; Declare the Multiboot header (which allows the bootloader to detect this program as a kernel).
; These are magic values that are documented in the multiboot standard (https://www.gnu.org/software/grub/manual/multiboot/multiboot.html).
; The bootloader will search for this header in the first 8KiB of the kernel, aligned at a 32 bit boundary.
; The header is in its own section so the header can be forced to be within the first 8KiB of the kernel.
SECTION .multiboot
    align 4

    dd MAGIC
    dd FLAGS
    dd CHECKSUM

; The Multiboot standard does not define the value of ESP, the stack pointer register, so it is up to the kernel to provide a stack.
; This allocates room for a small stack by creating a symbol at the bottom of it, then allocating 16384 bytes for it, and finally, creating a symbol at the top.
; The stack grows downwards on x86, and is in its own section because it does not contain an uninitialised stack.
; The stack on x86 must be 16-byte aligned according to the System V ABI standard and de-facto extensions.
; The compiler will assume the stack is properly aligned and failure to align the stack will result in UB
SECTION .bss
    ; A gap of 16 bits
    align 16

    ; The bottom of the stack (actually the top)
    stack_bottom:
        times 16384 db 0 ; 16 KiB
    ; The top of the stack (actually the bottom)
    stack_top:

; The linker script specifies _start as the entry point to the kernel and the bootloader will jump to this position once the kernel has been loaded.
; It doesn't make sense to return from this block as the bootloader is gone.
SECTION .text
    global _start
    _start:
        ; The bootloader has loaded us into 32-bit protected mode on an x86 machine.
        ; Interrupts and paging are both disabled.
        ; The processor state is as defined in the Multiboot standard.
        ; The kernel has full control of the CPU and can only use hardware features and code it provides itself.
        ; There's no printf function, unless the kernel provides its own <stdio.h> header and a printf implementation.
        ; There are no security restrictions, no safeguards, no debugging mechanisms, only what the kernel provides itself.
        ; It has absolute and complete power over the machine.

        ; To setup a stack, we set the ESP register to point to the top of the stack (as it grows downwards on x86).
        ; This must be done in assembly because C programs require a stack
        mov esp, stack_top

        ; This is a good place to initialise crucial processor state before the high(ish)-level kernel is entered.
        ; It's best to minimise the early environment where crucial features are offline.
        ; Note that the processor is not fully initialised yet: features such as floating point instructions and instruction set instructions are not initialised yet.
        ; The GDT should be loaded here, paging should be enabled here.
        ; C++ features such as global constructors and exceptions will require runtime support to work as well.

        ; Enter the high-level kernel, the ABI requires the stack is 16-byte aligned at the time of the call instruction (which afterwards pushes the 4 byte return pointer).
        ; The stack was originally 16-byte aligned above and we've pushed a multiple of 16 bytes to the stack since (0 bytes so far), thus the alignment has been preserved and the call is well defined.
        call kernel_main

        ; If the system has nothing more to do, make the CPU hang:

        ; Enable CPU Interrupts, not technically needed since they are already disabled by the bootloader, but the kernel_main function may enable them and return (which is sort of nonsensical, but not impossible):
        cli

        hang:
            ; Halt the CPU:
            hlt
            ; Jump back to the hlt instruction if the CPU ever wakes up due to a non-maskable interrupt occurring or due to system management mode:
            jmp hang


