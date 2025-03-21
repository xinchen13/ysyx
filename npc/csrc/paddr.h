#ifndef __PADDR_H__
#define __PADDR_H__

#include "common.h"

extern coreState core;

#define PMEM_LEFT  ((paddr_t)CONFIG_MBASE)
#define PMEM_RIGHT ((paddr_t)CONFIG_MBASE + CONFIG_MSIZE - 1)
#define RESET_VECTOR PMEM_LEFT


uint8_t* guest_to_host(paddr_t paddr);
paddr_t host_to_guest(uint8_t *haddr);

static inline bool in_pmem(paddr_t addr) {
    return addr - CONFIG_MBASE < CONFIG_MSIZE;
}

word_t paddr_read(paddr_t addr, int len);
void paddr_write(paddr_t addr, int len, word_t data);

void init_mem();

void init_psram();

// DPI-C
extern "C" int dpic_pmem_read(int raddr);
extern "C" void dpic_pmem_write(int waddr, int wdata, char wmask);

extern "C" void mrom_read(int32_t addr, int32_t *data);

extern "C" int psram_read(int addr);
extern "C" void psram_write(int addr, int data, int wmask);

#endif
