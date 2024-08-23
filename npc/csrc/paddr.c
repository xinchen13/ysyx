#include "paddr.h"
#include "common.h"
#include "host.h"

static uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {};


uint8_t* guest_to_host(paddr_t paddr) { return pmem + paddr - CONFIG_MBASE; }
paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + CONFIG_MBASE; }

static word_t pmem_read(paddr_t addr, int len) {
    word_t ret = host_read(guest_to_host(addr), len);
    return ret;
}

static void pmem_write(paddr_t addr, int len, word_t data) {
    host_write(guest_to_host(addr), len, data);
}

static void out_of_bound(paddr_t addr) {
    panic("address = " FMT_PADDR " is out of bound of pmem [" FMT_PADDR ", " FMT_PADDR "] at pc = " FMT_WORD,
        addr, PMEM_LEFT, PMEM_RIGHT, core.pc);
}

void init_mem() {
    memset(pmem, rand(), CONFIG_MSIZE);
    Log("physical memory area [" FMT_PADDR ", " FMT_PADDR "]", PMEM_LEFT, PMEM_RIGHT);
}

word_t paddr_read(paddr_t addr, int len) {
    if (likely(in_pmem(addr))) {
        return pmem_read(addr, len);
    }
    out_of_bound(addr);
    return 0;
}

void paddr_write(paddr_t addr, int len, word_t data) {
    if (likely(in_pmem(addr))) { 
        pmem_write(addr, len, data); 
        return; 
    }
    out_of_bound(addr);
}

int dpic_pmem_read(int raddr) {
    // raddr & ~0x3u
    int aligned_address = raddr & (~0x3u);
    if (aligned_address >= CONFIG_MBASE && aligned_address <= (CONFIG_MBASE + CONFIG_MSIZE)) {
        int read_data = paddr_read(aligned_address, 4);
        // memory trace
        #ifdef CONFIG_MTRACE
            Log(" read %d (bytes)  @addr = " FMT_WORD, 4, aligned_address);
        #endif 
        return read_data;
    }
    else {
        return -1;
    }
}

void dpic_pmem_write(int waddr, int wdata, char wmask) {
    int aligned_address = waddr & (~0x3u);

    if (aligned_address >= CONFIG_MBASE && aligned_address <= (CONFIG_MBASE + CONFIG_MSIZE)) {
        // memory trace
        #ifdef CONFIG_MTRACE
            Log("write %d (bytes)  @addr = " FMT_WORD, 4, aligned_address);
        #endif 
        int *wdata_ptr = &wdata;
        char *byte_ptr = (char *)wdata_ptr;
        for (int i = 0; i < 4; i++) {
            if (wmask & (1u << i)) {
                paddr_write(aligned_address+i, 1, *(byte_ptr + i));
            }
        }
    }
    else if (waddr == 0xa00003f8) {
        putchar(wdata);
    }
    else {
        Assert(0, "wrong write: " FMT_PADDR, waddr);
    }
}