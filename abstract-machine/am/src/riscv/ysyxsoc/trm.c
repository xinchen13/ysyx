#include <am.h>
#include <klib-macros.h>

// ************** load to psram **************
extern char _tmp_psram_load_start;
extern char _tmp_psram_load_end;
#define PSRAM_PRGM_BASE      (uintptr_t)&_tmp_psram_load_start
#define FLASH_PRGM_BASE      0x30000000L

void jump_to_address(uint32_t base_address) {
    asm volatile (
        "jr %0;"
        :
        : "r" (base_address)
        :
    );
}

void load_to_psram() {
    char *src = (char *)FLASH_PRGM_BASE;
    char *dst = (char *)PSRAM_PRGM_BASE;
    while (dst < &_tmp_psram_load_end) {
        *dst++ = *src++;
    }
    jump_to_address(PSRAM_PRGM_BASE + 0xd4);
}


// *******************************************

// *************** bootloader ****************
extern char _mdata, _data_start, _data_end, _bss_start, _bss_end;
void bootloader() {
    char *src = &_mdata;
    char *dst = &_data_start;
    /* ROM has data at end of text; copy it.  */
    while (dst < &_data_end)
        *dst++ = *src++;
    /* Zero bss.  */
    for (dst = &_bss_start; dst< &_bss_end; dst++)
        *dst = 0;
    load_to_psram();    // load to psram
}
// *******************************************


// ****************** uart *******************
#define UART_BASE       0x10000000L
#define TX_REG          (UART_BASE + 0x0)
#define LCR             (UART_BASE + 0x3)
#define FCR             (UART_BASE + 0x2)
#define LSR             (UART_BASE + 0x5)
#define DLL             (UART_BASE + 0x0)
#define DLH             (UART_BASE + 0x1)
static inline uint8_t inb(uintptr_t addr) { return *(volatile uint8_t  *)addr; }
static inline void outb(uintptr_t addr, uint8_t  data) { *(volatile uint8_t  *)addr = data; }

__attribute__((noinline)) void uart_init() {
    outb(LCR, 0x83);        // DLAB = 1
    outb(DLH, 0x00);        // MSB first
    outb(DLL, 0x01);        // LSB next
    outb(LCR, 0x03);        // reset value
}

void putch(char ch) {
    // polling
    while((inb(LSR) & 0x20) == 0x00) {
        ;
    }
    outb(TX_REG, ch);
}
// *******************************************


extern char _heap_start;
extern char _heap_end;
int main(const char *args);

Area heap = RANGE(&_heap_start, &_heap_end);
#ifndef MAINARGS
#define MAINARGS ""
#endif
static const char mainargs[] = MAINARGS;

#define ysyxsoc_trap(code) asm volatile("mv a0, %0; ebreak" : :"r"(code))

void halt(int code) {
    ysyxsoc_trap(code);
    while(1);       // should not reach here
}

void _trm_init() {
    bootloader();
    uart_init();
    int ret = main(mainargs);
    halt(ret);
}
