#include "fast_flash.h"

static uint8_t flash_mem[FLASH_MSIZE] = {};

void init_fast_flash() {
    uint8_t* addr_ptr = flash_mem;
    while (addr_ptr < flash_mem + FLASH_MSIZE) {
        *addr_ptr = 0xff;
        addr_ptr++;
    }
    // memset(flash_mem, rand(), FLASH_MSIZE);
    Log("flash(simulation) memory area [" FMT_PADDR ", " FMT_PADDR "]", FLASH_LEFT, FLASH_RIGHT);
}

void flash_read(int32_t addr, int32_t *data) { 
    // assert(0); 
    // uint8_t* flash_addr = flash_mem + addr - FLASH_BASE;
    // *data = *(uint8_t  *)flash_addr;
    *data = flash_mem[0];
}

