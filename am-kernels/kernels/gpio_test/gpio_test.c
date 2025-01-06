#include <am.h>
#include <klib-macros.h>

static inline uint8_t  inb(uintptr_t addr) { return *(volatile uint8_t  *)addr; }
static inline uint16_t inw(uintptr_t addr) { return *(volatile uint16_t *)addr; }
static inline uint32_t inl(uintptr_t addr) { return *(volatile uint32_t *)addr; }
static inline void outb(uintptr_t addr, uint8_t  data) { *(volatile uint8_t  *)addr = data; }
static inline void outw(uintptr_t addr, uint16_t data) { *(volatile uint16_t *)addr = data; }
static inline void outl(uintptr_t addr, uint32_t data) { *(volatile uint32_t *)addr = data; }

int main(const char *args) {

    putch('\n');
    while (inw(0x10002004) != 0xf0f0);
    putstr("GPIO test: passwd correct!\n");

    outl(0x10002008, 0xdeadbeef);
    putstr("GPIO test: segment out done!\n");

    int cnt = 9999;
    while(1) {
        if (cnt != 0) {
            cnt--;
        }
        else {
            cnt = 9999;
            putstr("GPIO test: LED cycle once!\n");
        }

        if (cnt == 7500) outw(0x10002000, 0x000f);
        if (cnt == 5000) outw(0x10002000, 0x00f0);
        if (cnt == 2500) outw(0x10002000, 0x0f00);
        if (cnt == 0000) outw(0x10002000, 0xf000);
    }

    return 0;
}
