#ifndef __FAST_FLASH_H__
#define __FAST_FLASH_H__

#include "common.h"

#define FLASH_MSIZE 0xfffffff
#define FLASH_BASE  0x30000000

#define FLASH_LEFT  ((paddr_t)FLASH_BASE)
#define FLASH_RIGHT ((paddr_t)FLASH_BASE + FLASH_MSIZE - 1)

void init_fast_flash();

// DPI-C
extern "C" void flash_read(int32_t addr, int32_t *data);


#endif
