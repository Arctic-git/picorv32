
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

int test = 2;

#define reg_spictrl (*(volatile uint32_t*)0x02000000)
#define reg_uart_clkdiv (*(volatile uint32_t*)0x02000004)
#define reg_uart_data (*(volatile uint32_t*)0x02000008)
#define reg_leds (*(volatile uint32_t*)0x03000000)

static int sample_putc(char c, FILE* file) {
    (void)file; /* Not used in this function */
    reg_uart_data = c;
    return c;
}

static int sample_getc(FILE* file) {
    unsigned char c;
    (void)file;        /* Not used in this function */
    c = reg_uart_data;
    return c;
}

static FILE __stdio = FDEV_SETUP_STREAM(sample_putc,
                                        sample_getc,
                                        NULL,
                                        _FDEV_SETUP_RW);

FILE *const stdin = &__stdio; __strong_reference(stdin, stdout); __strong_reference(stdin, stderr);



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

    int i = 0;
    while (1) {
        myprint("jo myprint\n");

        printf("jo printf %d\n", i++);
        sleep();
    }
}
