#include <am.h>
#include <klib-macros.h>
#include "ysyxsoc.h"

// ****************** uart *******************
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
    uart_init();
    int ret = main(mainargs);
    halt(ret);
}

// *************** bootloader ****************
// ss-bootloader
extern unsigned char _text_section_start, _data_section_end, _text_section_src;
extern unsigned char _bss_start, _bss_end;
void __attribute__((section(".ssbl"))) _ss_bootloader() {
    uint32_t *src = (uint32_t *)&_text_section_src;
    uint32_t *dest = (uint32_t *)&_text_section_start;
    uint32_t *end = (uint32_t *)&_data_section_end;
    while (dest <= end) {
        *dest = *src;
        dest++;
        src++;
    }
    unsigned char *bss_src = &_bss_start;
    unsigned char *bss_end = &_bss_end;
    while (bss_src <= bss_end) {
        *(bss_src++) = 0;
    }
    _trm_init();
}

// fs-bootloader
extern unsigned char _ssbl_section_start, _ssbl_section_end, _ssbl_section_src;
void __attribute__((section(".fsbl"))) _fs_bootloader() {
    unsigned char *src = &_ssbl_section_src;
    unsigned char *dest = &_ssbl_section_start;
    unsigned char *end = &_ssbl_section_end;
    while (dest <= end) {
        *dest = *src;
        dest++;
        src++;
    }
    _ss_bootloader();
}
// *******************************************