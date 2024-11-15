#include <am.h>
#include <klib-macros.h>

extern char _heap_start;
int main(const char *args);

#define HEAP_SIZE 0x1000
#define HEAP_END  ((uintptr_t)&_heap_start + HEAP_SIZE)

Area heap = RANGE(&_heap_start, HEAP_END);
#ifndef MAINARGS
#define MAINARGS ""
#endif
static const char mainargs[] = MAINARGS;

// ------- simulate serial port -------
#define UART_BASE       0x10000000
#define TX_REG          (UART_BASE + 0x0)
static inline void outb(uintptr_t addr, uint8_t  data) { *(volatile uint8_t  *)addr = data; }
// ------------------------------------

void putch(char ch) {
    outb(TX_REG, ch);
}

#define ysyxsoc_trap(code) asm volatile("mv a0, %0; ebreak" : :"r"(code))

void halt(int code) {
    ysyxsoc_trap(code);
    while(1);       // should not reach here
}

void _trm_init() {
    int ret = main(mainargs);
    halt(ret);
}
