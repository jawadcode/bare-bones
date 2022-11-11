zig build-obj kernel.c -target i386-freestanding
nasm boot.nasm -f elf -o boot.o
ld.mold -m elf_i386 -T linker.ld -o myos.bin boot.o kernel.o
