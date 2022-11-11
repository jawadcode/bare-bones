// I hate this language with a burning passion

#ifndef ZESTYOS_STDINT_H
#define ZESTYOS_STDINT_H

// Signed 8 bit integer
typedef signed char i8;
// Unsigned 8 bit integer
typedef unsigned char u8;

// Signed 16 bit integer
typedef signed short i16;
// Unsigned 16 bit integer
typedef unsigned short u16;

// Signed 32 bit integer
typedef signed long int i32;
// Unsigned 32 bit integer
typedef unsigned long int u32;

// Signed 64 bit integer
typedef signed long long int i64;
// Unsigned 64 bit integer
typedef unsigned long long int u64;

// Boolean type
typedef u8 bool;
#define false 0
#define true 1

#endif
