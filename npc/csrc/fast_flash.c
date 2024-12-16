#include "fast_flash.h"

/*
char-test.o:     file format elf32-littleriscv

Disassembly of section .text:

00000000 <_start>:
   0:   100007b7                lui     a5,0x10000
   4:   04100713                li      a4,65
   8:   00e78023                sb      a4,0(a5) # 10000000 <.L2+0xffffff4>

0000000c <.L2>:
   c:   0000006f                j       c <.L2>
*/

static uint8_t flash_mem[FLASH_MSIZE];

void init_fast_flash() {
    uint8_t* addr_ptr = flash_mem;
    *(uint32_t *)(addr_ptr) = 0x73737373;
    *(uint32_t *)(addr_ptr+0x4) = 0x04100713;
    *(uint32_t *)(addr_ptr+0x8) = 0x00e78023;
    *(uint32_t *)(addr_ptr+0xc) = 0x0000006f;

    // memset(flash_mem, rand(), FLASH_MSIZE);
    Log("flash(simulation) memory area [" FMT_PADDR ", " FMT_PADDR "]", FLASH_LEFT, FLASH_RIGHT);
}

void flash_read(int32_t addr, int32_t *data) { 
    // assert(0); 
    uint8_t flash_addr_offset = addr - FLASH_BASE;
    *data = *(int32_t*)(flash_mem + flash_addr_offset);
}

