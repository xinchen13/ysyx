#include <am.h>
#include <klib-macros.h>

static inline uint8_t  inb(uintptr_t addr) { return *(volatile uint8_t  *)addr; }
static inline uint16_t inw(uintptr_t addr) { return *(volatile uint16_t *)addr; }
static inline uint32_t inl(uintptr_t addr) { return *(volatile uint32_t *)addr; }
static inline void outb(uintptr_t addr, uint8_t  data) { *(volatile uint8_t  *)addr = data; }
static inline void outw(uintptr_t addr, uint16_t data) { *(volatile uint16_t *)addr = data; }
static inline void outl(uintptr_t addr, uint32_t data) { *(volatile uint32_t *)addr = data; }


void jump_to_address() {
    asm volatile (
        "lui t2, 0x0f000;"
        "addi t2, t2, 0x400;"
        "jr t2;"
    );
}

int main(const char *args) {
    putstr("Reading 1st ins...\n");
    outl(0x0f000400, inl(0x30000000));
    if (inl(0x0f000400) != 0x100007b7) {
        return 1;
    }

    putstr("Reading 2nd ins...\n");
    outl(0x0f000404, inl(0x30000004));
    if (inl(0x0f000404) != 0x04100713) {
        return 1;
    }

    putstr("Reading 3rd ins...\n");
    outl(0x0f000408, inl(0x30000008));
    if (inl(0x0f000408) != 0x00e78023) {
        return 1;
    }

    putstr("Reading 4th ins...\n");
    outl(0x0f00040c, inl(0x3000000c));
    if (inl(0x0f00040c) != 0x0000006f) {
        return 1;
    }

    putstr("Let's goooo!\n");
    jump_to_address();

    return 0;
}
