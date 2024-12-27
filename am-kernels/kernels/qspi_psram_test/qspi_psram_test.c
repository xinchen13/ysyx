#include <am.h>
#include <klib-macros.h>

static inline uint8_t  inb(uintptr_t addr) { return *(volatile uint8_t  *)addr; }
static inline uint16_t inw(uintptr_t addr) { return *(volatile uint16_t *)addr; }
static inline uint32_t inl(uintptr_t addr) { return *(volatile uint32_t *)addr; }
static inline void outb(uintptr_t addr, uint8_t  data) { *(volatile uint8_t  *)addr = data; }
static inline void outw(uintptr_t addr, uint16_t data) { *(volatile uint16_t *)addr = data; }
static inline void outl(uintptr_t addr, uint32_t data) { *(volatile uint32_t *)addr = data; }

int main(const char *args) {
    uint32_t read_data;
    putstr("Start - reading psram\n");
    read_data = inl(0x80000134);
    putstr("End - reading psram\n");
    putch((uint8_t)read_data);
    putch((uint8_t)(read_data>>8));
    putch((uint8_t)(read_data>>16));
    putch((uint8_t)(read_data>>24));
    putch('\n');

    return 0;
}
