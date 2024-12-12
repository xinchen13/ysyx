#include <am.h>
#include <klib-macros.h>

static inline uint8_t inb(uintptr_t addr) { return *(volatile uint8_t  *)addr; }
static inline uint32_t inw(uintptr_t addr) { return *(volatile uint32_t  *)addr; }

int main(const char *args) {
    const char *fmt = "fast flash test!\n";
    for (const char *p = fmt; *p; p++) {
        putch(*p);
    }

    uint32_t init_data[4];
    init_data[0] = inw(0x30000000);
    init_data[1] = inw(0x30000fff);
    init_data[2] = inw(0x30000123);
    init_data[3] = inw(0x30077772);

    int i = 0;
    while (i <= 3) {
        putch(init_data[i]);
        putch(init_data[i]>>8);
        putch(init_data[i]>>16);
        putch(init_data[i]>>24);
        putch('\n');
        i++;
    }
  return 0;
}
