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

#define BITREV_NUM      0x00000080
#define BITREV_CTRL     0x00000910      // 0b00100100010000

int main(const char *args) {
    // tx data
    outl(SPI_TX_REG0, 0x000000ce);        // s: 0x73, bitrev: 0b11001110 = 0x000000ce

    // divider
    outl(SPI_DIVIDER, 0x0000ffff);

    // set SS
    outl(SPI_SS, BITREV_NUM);

    // set CTRL
    outl(SPI_CTRL, BITREV_CTRL);

    // polling
    while ((inl(SPI_CTRL) & 0x00000100) == 0x00000100) {
        ;
    }

    putch('\n');
    putch(inl(SPI_RX_REG0)>>8);
    putch('\n');

    outl(SPI_TX_REG0, 0x00000002);        // @: 0x40, bitrev: 0b00000010 = 0x00000002
    outl(SPI_CTRL, BITREV_CTRL);
    while ((inl(SPI_CTRL) & 0x00000100) == 0x00000100) {
        ;
    }
    putch('\n');
    putch(inl(SPI_RX_REG0)>>8);
    putch('\n');
    return 0;
}
