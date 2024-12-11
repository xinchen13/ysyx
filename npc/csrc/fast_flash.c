#include "fast_flash.h"

static uint8_t flash_mem[FLASH_MSIZE] = {};

void init_fast_flash() {
    paddr_t i = FLASH_LEFT;
    while (i <= FLASH_RIGHT) {
        memset(flash_mem + i - FLASH_BASE, i, 1);
        i++;
    }
    Log("flash(simulate) memory area [" FMT_PADDR ", " FMT_PADDR "]", FLASH_LEFT, FLASH_RIGHT);
}

void flash_read(int32_t addr, int32_t *data) { 
    // assert(0); 
    uint8_t* flash_addr = flash_mem + addr - FLASH_BASE;
    *data = *(uint8_t  *)flash_addr;
}

