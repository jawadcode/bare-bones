CC := clang
ASM := nasm
TARGET_EXEC := myos.bin

BUILD_DIR := ./build
SRC_DIRS := ./src

SRCS := $(shell find $(SRC_DIRS) -name '*.c' -or -name '*.nasm')
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

INC_DIRS := $(shell find $(SRC_DIRS) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))
CFLAGS := -ffreestanding -O3 --target=i386
ASMFLAGS := -f elf -w-all
LDFLAGS := -m elf_i386 -T linker.ld

$(BUILD_DIR)/$(TARGET_EXEC): $(OBJS)
	ld $(OBJS) -o $@ $(LDFLAGS)

$(BUILD_DIR)/%.c.o: %.c
	mkdir -p $(dir $@)
	$(CC) -c $< -o $@ $(CFLAGS)

$(BUILD_DIR)/%.nasm.o: %.nasm
	mkdir -p $(dir $@)
	$(ASM) $< $(ASMFLAGS) -o $@

.PHONY: clean run

clean:
	rm -rf $(BUILD_DIR)

run: $(BUILD_DIR)/$(TARGET_EXEC)
	qemu-system-i386 -kernel $(BUILD_DIR)/$(TARGET_EXEC)

-include $(DEPS)

