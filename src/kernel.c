#include "types.h"

// This is the x86 VGA textmode buffer, in order to display text, we must write data to this memory location
volatile u16 *vga_buffer = (u16 *)0xB8000;

typedef struct {
    u32 col;
    u32 row;
} Pos;

typedef enum {
    VGA_COLOUR_BLACK         = 0x0,
	VGA_COLOUR_BLUE          = 0x1,
	VGA_COLOUR_GREEN         = 0x2,
	VGA_COLOUR_CYAN          = 0x3,
	VGA_COLOUR_RED           = 0x4,
	VGA_COLOUR_MAGENTA       = 0x5,
	VGA_COLOUR_BROWN         = 0x6,
	VGA_COLOUR_LIGHT_GREY    = 0x7,
	VGA_COLOUR_DARK_GREY     = 0x8,
	VGA_COLOUR_LIGHT_BLUE    = 0x9,
	VGA_COLOUR_LIGHT_GREEN   = 0xA,
	VGA_COLOUR_LIGHT_CYAN    = 0xB,
	VGA_COLOUR_LIGHT_RED     = 0xC,
	VGA_COLOUR_LIGHT_MAGENTA = 0xD,
	VGA_COLOUR_LIGHT_BROWN   = 0xE,
	VGA_COLOUR_WHITE         = 0xF,
} VgaColour;

// By default, the VGA textmode buffer has a size of 80x25 characters
#define VGA_COLS 80
#define VGA_ROWS 25

// We begin displaying text in the top-left of the screen: (0, 0)
Pos cursor_pos = { 0, 0 };

// The first 4 bits signify the background colour, which is black
// and the next 4 bits, the foreground, which is white
u8 text_colour = VGA_COLOUR_BLACK << 4 | VGA_COLOUR_WHITE;

// Takes in the desired background and foreground colour and returns the two combined
static inline u8 vga_colour(VgaColour bg, VgaColour fg) {
    return bg << 4 | fg;
}

// Initialises the text buffer
void init_vga() {
    for (u32 col = 0; col < VGA_COLS; col++) {
        for (u32 row = 0; row < VGA_ROWS; row++) {
            // The VGA textmode buffer has size (VGA_COLS * VGA_ROWS)
            // Given this, we find an index into the buffer for our character
            const u32 index = (VGA_COLS * row) + col;
            
            // An entry in the VGA buffer has the following format:
            //      4 bits       4 bits              8 bits
            //  ┌────────────┬────────────┬──────────────────────────┐
            //  │ Background │ Foreground │     ASCII Character      │ 
            //  └────────────┴────────────┴──────────────────────────┘
            //  ╰────────────────────────────────────────────────────╯
            //                         16 bits
            vga_buffer[index] = ((u16)text_colour << 8) | ' '; // Set character to space
        }
    }

    cursor_pos = (Pos){ 0, 0 };
}

void print_char(char c) {
    // Note: We don't want to display ALL characters
    switch (c) {
    // Newline char should return the column to 0 and increment the row
    case '\n':
        cursor_pos.col = 0;
        cursor_pos.row++;
        break;

    // Normal characters just get displayed and then increment the column
    default: {
        const u32 index = (VGA_COLS * cursor_pos.row) + cursor_pos.col;
        vga_buffer[index] = ((u16)text_colour << 8) | c;
        cursor_pos.col++;
        break;
    }
    }

    // If we have reached the last column:
    //  - reset the column to 0
    //  - increment the row to wrap to a new line
    if (cursor_pos.col >= VGA_COLS) {
        cursor_pos.col = 0;
        cursor_pos.row++;
    }

    // If we have reached the last row:
    //  - Reset the buffer
    //  - Reset column to 0
    //  - Reset row to 0
    if (cursor_pos.row >= VGA_ROWS) {
        init_vga();
        cursor_pos.col = 0;
        cursor_pos.row = 0;
    }
}

// Print `string` to the VGA text buffer
void print_string(const char *string) {
    for (u32 i = 0; string[i] != '\0'; i++)
        print_char(string[i]);
}

void kernel_main() {
    // Initiate terminal
    init_vga();

    text_colour = vga_colour(VGA_COLOUR_BLUE, VGA_COLOUR_RED);
    print_string("Hello world!\n");

    text_colour = vga_colour(VGA_COLOUR_LIGHT_BROWN, VGA_COLOUR_LIGHT_GREEN);
    print_string("I don't do anything too fancy yet :(\n");
}
