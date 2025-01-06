#define UART_BASE       0x10000000L
#define RX_REG          (UART_BASE + 0x1)
#define LSR             (UART_BASE + 0x5)
static inline uint8_t inb(uintptr_t addr) { return *(volatile uint8_t  *)addr; }