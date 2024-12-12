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
  init_data[0] = inw(0x30000004);
  init_data[1] = inw(0x30000004);
  init_data[2] = inw(0x30000004);
  init_data[3] = inw(0x30000004);
  init_data[4] = inw(0x30000004);


  putch(init_data[0]);
  putch(init_data[0]>>8);
  putch(init_data[0]>>16);
  putch(init_data[0]>>24);
  putch('\n');
  
  return 0;
}
