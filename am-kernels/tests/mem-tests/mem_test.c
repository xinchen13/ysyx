#include <am.h>

#define SRAM_START  0x0f000000
#define SRAM_END    0x0f001000

int main () {
    volatile uint8_t *write_ptr_8 = (uint8_t *)SRAM_START;
    volatile uint8_t *check_ptr_8 = (uint8_t *)SRAM_START;

    // write 
    while ((uint32_t)write_ptr_8 < SRAM_END) {
        *write_ptr_8 = (uint32_t)write_ptr_8;
        write_ptr_8++;
    }

    // check
    while ((uint32_t)check_ptr_8 < SRAM_END) {
        if (*check_ptr_8 == (uint8_t)((uint32_t)check_ptr_8)) {
            // putch('P');
            ;
        } else {
            // putch('F');
            halt(1);
        }
        check_ptr_8++;
    }

    return 0;
}