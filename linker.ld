ENTRY(_start)

SECTIONS {
    /* Begin putting sections at 1M,
     * the conventional place for kernels to be loaded at by the bootloader,
     * this is because memory below this point is reserved for other x86-related things, 
     * so we can't use it.
     */
    . = 1M;

    /* We align all sections in the executable at multiples of 4K,
     * this will become useful later in development when we add paging.
     */

    /* First put the multiboot header, as it is required to be put very early
	 * early in the image or the bootloader won't recognize the file format.
	 * Next we'll put the .text section. */
	.text BLOCK(4K) : ALIGN(4K) {
		*(.multiboot)
		*(.text)
	}
 
	/* Read-only data. */
	.rodata BLOCK(4K) : ALIGN(4K) {
		*(.rodata)
	}
 
	/* Read-write data (initialized) */
	.data BLOCK(4K) : ALIGN(4K) {
		*(.data)
	}
 
	/* Read-write data (uninitialized) and stack */
	.bss BLOCK(4K) : ALIGN(4K) {
		*(COMMON)
		*(.bss)
	}
}
