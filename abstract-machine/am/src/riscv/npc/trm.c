#include <am.h>
#include <klib-macros.h>

extern char _heap_start;
int main(const char *args);


#define PMEM_END  0xfffffff

Area heap = RANGE(&_heap_start, PMEM_END);
#ifndef MAINARGS
#define MAINARGS ""
#endif
static const char mainargs[] = MAINARGS;

// ------- simulate serial port -------
#define DEVICE_BASE    0xa0000000
#define SERIAL_PORT    (DEVICE_BASE + 0x00003f8)
static inline void outb(uintptr_t addr, uint8_t  data) { *(volatile uint8_t  *)addr = data; }
// ------------------------------------

void putch(char ch) {
    outb(SERIAL_PORT, ch);
}

#define npc_trap(code) asm volatile("mv a0, %0; ebreak" : :"r"(code))

void halt(int code) {
    npc_trap(code);
    while(1);       // should not reach here
}

void _trm_init() {
    int ret = main(mainargs);
    halt(ret);
}
