#include <am.h>
#include <klib-macros.h>

static inline uint8_t  inb(uintptr_t addr) { return *(volatile uint8_t  *)addr; }
static inline uint16_t inw(uintptr_t addr) { return *(volatile uint16_t *)addr; }
static inline uint32_t inl(uintptr_t addr) { return *(volatile uint32_t *)addr; }
static inline void outb(uintptr_t addr, uint8_t  data) { *(volatile uint8_t  *)addr = data; }
static inline void outw(uintptr_t addr, uint16_t data) { *(volatile uint16_t *)addr = data; }
static inline void outl(uintptr_t addr, uint32_t data) { *(volatile uint32_t *)addr = data; }

#define SPI_MASTER_BASE 0x10001000
#define SPI_TX_REG0     (SPI_MASTER_BASE + 0x00)
#define SPI_TX_REG1     (SPI_MASTER_BASE + 0x04)
#define SPI_RX_REG0     (SPI_MASTER_BASE + 0x00)
#define SPI_RX_REG1     (SPI_MASTER_BASE + 0x04)
#define SPI_DIVIDER     (SPI_MASTER_BASE + 0x14)
#define SPI_CTRL        (SPI_MASTER_BASE + 0x10)
#define SPI_SS          (SPI_MASTER_BASE + 0x18)

#define FLASH_NUM       0x00000001
#define FLASH_CTRL      0x00000140      // 0b00000101000000

uint32_t flash_read(uint32_t addr) {
    uint32_t tx_data = 0x03000000 | ((addr & 0x00ffffff));
    outl(SPI_TX_REG1, tx_data);
    outl(SPI_TX_REG0, 0x00000000);

    // divider
    outl(SPI_DIVIDER, 0x00000001);
    // set SS
    outl(SPI_SS, FLASH_NUM);
    // set CTRL
    outl(SPI_CTRL, FLASH_CTRL);
    // polling
    while ((inl(SPI_CTRL) & 0x00000100) == 0x00000100) {
        ;
    }
    return inl(SPI_RX_REG0);

}

int main(const char *args) {
    uint32_t init_data_spi;
    putstr("Start - reading falsh (through spi)\n");
    init_data_spi = flash_read(0x30000010);
    putstr("End - reading falsh (through spi)\n");
    putch((uint8_t)init_data_spi);
    putch((uint8_t)(init_data_spi>>8));
    putch((uint8_t)(init_data_spi>>16));
    putch((uint8_t)(init_data_spi>>24));
    putch('\n');

    // uint32_t init_data_xip;
    putstr("Start - reading falsh (XIP)\n");
    // init_data_xip = inl(0x30000010);
    putstr("End - reading falsh (XIP)\n");
    // putch(init_data_xip);
    // putch(init_data_xip>>8);
    // putch(init_data_xip>>16);
    // putch(init_data_xip>>24);
    putch('\n');

    return 0;
}
