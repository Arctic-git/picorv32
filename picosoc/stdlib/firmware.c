
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>

// a pointer to this is a null pointer, but the compiler does not
// know that because "sram" is a linker symbol from sections.lds.
extern uint32_t sram;

int test = 2;

#define reg_spictrl (*(volatile uint32_t*)0x02000000)
#define reg_uart_clkdiv (*(volatile uint32_t*)0x02000004)
#define reg_uart_data (*(volatile uint32_t*)0x02000008)
#define reg_leds (*(volatile uint32_t*)0x03000000)


void myputchar(char c) {
    reg_uart_data = c;
    if (c == '\n')
        reg_uart_data = '\r';
}
void myprint(const char* str) {
    while (*str) {
        myputchar(*str);
        str++;
    }
}

void sleep() {
    uint32_t cycles_begin, cycles_now = 0, cycles = 0;
    __asm__ volatile("rdcycle %0"
                     : "=r"(cycles_begin));
    while (cycles < 20000000) {
        __asm__ volatile("rdcycle %0"
                         : "=r"(cycles_now));
        cycles = cycles_now - cycles_begin;
    }
}

// void _end() {
//     while (1)

// 		;
// }


void main() {
    reg_leds = 1;
    reg_uart_clkdiv = 20 - 2;
    myprint("Booting..\n");

    // char s[50];
    // snprintf(s, sizeof(s), "test %d\n", reg_leds);

    reg_leds = 2;
    // set_flash_qspi_flag();

    reg_leds = 3;
    reg_leds = test;

    int i=0;
    while (1) {
        myprint("jo myprint\n");

        printf("jo printf %d\n", i++);
        sleep();
    }
}
