#include <am.h>
#include <klib-macros.h>

static inline uint8_t inb(uintptr_t addr) { return *(volatile uint8_t  *)addr; }

int main(const char *args) {
  // const char *fmt =
  //   "Hello, AbstractMachine!\n"
  //   "mainargs = '%'.\n";

  // for (const char *p = fmt; *p; p++) {
  //   (*p == '%') ? putstr(args) : putch(*p);
  // }
  uint8_t init_data = inb(0x30000fff);
  putch(init_data);
  
  return 0;
}
