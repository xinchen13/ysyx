#include <am.h>
#include <klib-macros.h>

static inline uint8_t inb(uintptr_t addr) { return *(volatile uint8_t  *)addr; }

int main(const char *args) {
    const char *fmt = "fast flash test!\n";
    for (const char *p = fmt; *p; p++) {
        putch(*p);
    }

  uint8_t init_data[4];
  init_data[0] = inb(0x30000004);
  init_data[1] = inb(0x30000005);
  init_data[2] = inb(0x30000006);
  init_data[3] = inb(0x30000007);

  putch(init_data[0]);
  putch(init_data[1]);
  putch(init_data[2]);
  putch(init_data[3]);
  putch('\n');
  
  return 0;
}
