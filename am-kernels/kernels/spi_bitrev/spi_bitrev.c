#include <am.h>
#include <klib-macros.h>

static inline uint8_t  inb(uintptr_t addr) { return *(volatile uint8_t  *)addr; }
static inline uint16_t inw(uintptr_t addr) { return *(volatile uint16_t *)addr; }
static inline uint32_t inl(uintptr_t addr) { return *(volatile uint32_t *)addr; }
static inline void outb(uintptr_t addr, uint8_t  data) { *(volatile uint8_t  *)addr = data; }
static inline void outw(uintptr_t addr, uint16_t data) { *(volatile uint16_t *)addr = data; }
static inline void outl(uintptr_t addr, uint32_t data) { *(volatile uint32_t *)addr = data; }

#define SPI_MASTER_BASE 0x10001000
#define SPI_TX_REG0     (SPI_MASTER_BASE + 0x0)
#define SPI_RX_REG0     (SPI_MASTER_BASE + 0x0)
#define SPI_DIVIDER     (SPI_MASTER_BASE + 0x14)
#define SPI_CTRL        (SPI_MASTER_BASE + 0x10)
#define SPI_SS          (SPI_MASTER_BASE + 0x18)

#define BITREV_NUM      0x80
#define BITREV_CTRL     0b00100100010000

int main(const char *args) {
    // tx data
    outb(SPI_TX_REG0, 0x31);

    // divider
    outw(SPI_DIVIDER, 0xffff);

    // set SS
    outb(SPI_SS, BITREV_NUM);

    // set CTRL
    outw(SPI_CTRL, BITREV_CTRL);

    while ((inw(SPI_CTRL) & 0x0100) == 0x0100) {
        ;
    }

    putch('\n');
    putch(inb(SPI_RX_REG0+1));
    putch('\n');
    putch('\n');
    return 0;
}
