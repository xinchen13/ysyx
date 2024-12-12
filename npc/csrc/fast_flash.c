#include "fast_flash.h"

static uint8_t flash_mem[FLASH_MSIZE];

void init_fast_flash() {
    uint8_t* addr_ptr = flash_mem;
    uint8_t  wdata = 0x30;
    while (addr_ptr < flash_mem + FLASH_MSIZE) {
        *addr_ptr = wdata;
        addr_ptr++;
        wdata = (wdata == 0x39) ? 0x30 : wdata++;
    }
    // memset(flash_mem, rand(), FLASH_MSIZE);
    Log("flash(simulation) memory area [" FMT_PADDR ", " FMT_PADDR "]", FLASH_LEFT, FLASH_RIGHT);
}

void flash_read(int32_t addr, int32_t *data) { 
    // assert(0); 
    uint8_t flash_addr_offset = addr - FLASH_BASE;
    *data = flash_mem[flash_addr_offset];
}

