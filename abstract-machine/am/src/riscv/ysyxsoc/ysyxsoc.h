// uart
#define UART_BASE       0x10000000L
#define TX_REG          (UART_BASE + 0x0)
#define RX_REG          (UART_BASE + 0x0)
#define LCR             (UART_BASE + 0x3)
#define FCR             (UART_BASE + 0x2)
#define LSR             (UART_BASE + 0x5)
#define DLL             (UART_BASE + 0x0)
#define DLH             (UART_BASE + 0x1)

// keyboard
#define KEYBOARD_BASE           0x10011000
#define KEYBOARD_SCAN_CODE      KEYBOARD_BASE + 0x0

// timer
#define DEVICE_BASE     0xa0000000
#define RTC_ADDR        (DEVICE_BASE + 0x0000048)

static inline uint8_t inb(uintptr_t addr) { return *(volatile uint8_t  *)addr; }
static inline uint32_t inl(uintptr_t addr) { return *(volatile uint32_t *)addr; }
static inline void outb(uintptr_t addr, uint8_t  data) { *(volatile uint8_t  *)addr = data; }
