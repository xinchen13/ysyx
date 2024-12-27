#include "paddr.h"
#include "common.h"
#include "host.h"
#include "reg.h"
#include "fast_flash.h"

static uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {}; // pmem is flash now

static uint8_t psram[CONFIG_PSRAM_SIZE] PG_ALIGN = {};   // psram


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

void init_psram() {
    memset(psram, 0x73, CONFIG_PSRAM_SIZE);
    Log("psram memory area [" FMT_PADDR ", " FMT_PADDR "]", CONFIG_PSRAM_BASE, CONFIG_PSRAM_BASE+CONFIG_PSRAM_SIZE);
}

void init_mem() {
    memset(pmem, rand(), CONFIG_MSIZE);
    Log("flash memory area [" FMT_PADDR ", " FMT_PADDR "]", PMEM_LEFT, PMEM_RIGHT);
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
    // else if (aligned_address == 0xa0000048) {
    //     struct timespec ts;
    //     clock_gettime(CLOCK_THREAD_CPUTIME_ID, &ts);
    //     int microseconds = ts.tv_nsec / 1000 + ts.tv_sec * 1000000;
    //     return microseconds;
    // }
    else {
        // printf("rdata(last) = 0x%x\n", dut->rootp->soc_top__DOT__xcore_u0__DOT__wb_alu_result);
        // printf("raddr(last) = 0x%x\n", dut->rootp->soc_top__DOT__xcore_u0__DOT__wb_dmem_rdata);
        // printf("raddr(alu out) = 0x%x\n", dut->rootp->soc_top__DOT__xcore_u0__DOT__alu_result);
        // printf("raddr(arbiter out) = 0x%x\n", dut->rootp->soc_top__DOT__arbiter_xbar_araddr);
        isa_reg_display();
        Assert(0, "wrong read: " FMT_PADDR, raddr);
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
    // else if (waddr == 0xa00003f8) {
    //     putchar(wdata);
    // }
    else {
        // printf("waddr(alu out) = 0x%x\n", dut->rootp->soc_top__DOT__xcore_u0__DOT__wb_alu_result);
        // printf("waddr(arbiter out) = 0x%x\n", dut->rootp->soc_top__DOT__arbiter_xbar_awaddr);
        // printf("bus grant = 0x%x\n", dut->rootp->soc_top__DOT__arbiter_u0__DOT__grant);
        // printf("lsu awvalid = 0x%x\n", dut->rootp->soc_top__DOT__arbiter_xbar_awvalid);
        isa_reg_display();
        Assert(0, "wrong write: " FMT_PADDR, waddr);
    }
}

void mrom_read(int32_t addr, int32_t *data) {
    // execute ebreak
    // assert(0);
    // if (addr == 0x20000000) {
    //     *data = 0x100073u; 
    // }

    int aligned_address = addr & (~0x3u);
    if (aligned_address >= CONFIG_MBASE && aligned_address <= (CONFIG_MBASE + CONFIG_MSIZE)) {
        int read_data = paddr_read(aligned_address, 4);
        // memory trace
        #ifdef CONFIG_MTRACE
            Log(" read %d (bytes)  @addr = " FMT_WORD, 4, aligned_address);
        #endif
        *data = read_data;
    }
    else {
        isa_reg_display();
        Assert(0, "wrong read: " FMT_PADDR, addr);
    }
}

#ifdef CONFIG_XIP_FLASH
void flash_read(int32_t addr, int32_t *data) {
    uint32_t aligned_address = (addr & (~0x3u)) + CONFIG_MBASE;
    if (aligned_address >= CONFIG_MBASE && aligned_address <= (CONFIG_MBASE + CONFIG_MSIZE)) {
        int read_data = paddr_read(aligned_address, 4);
        // memory trace
        #ifdef CONFIG_MTRACE
            Log(" read %d (bytes)  @addr = " FMT_WORD, 4, aligned_address);
        #endif
        *data = read_data;
    }
    else {
        isa_reg_display();
        Assert(0, "wrong read: " FMT_PADDR, addr);
    }
}
#endif

int psram_read(int addr) {
    // raddr & ~0x3u
    int aligned_address = addr & (~0x3u) + CONFIG_PSRAM_BASE;
    if (aligned_address >= CONFIG_PSRAM_BASE && aligned_address <= (CONFIG_PSRAM_BASE + CONFIG_PSRAM_SIZE)) {
        int read_data = host_read(psram + aligned_address - CONFIG_PSRAM_BASE, 4);
        // memory trace
        #ifdef CONFIG_MTRACE
            Log(" read %d (bytes)  @addr = " FMT_WORD, 4, aligned_address);
        #endif 
        return read_data;
    }

    else {
        isa_reg_display();
        Assert(0, "wrong read: " FMT_PADDR, addr);
    }
}


void psram_write(int addr, int data) {
    ;
}