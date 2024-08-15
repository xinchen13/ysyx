#include <am.h>
#include <nemu.h>

#define KEYDOWN_MASK 0x8000

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
    // 32-bit keyboard reg:
    // | keydown, keycode[30], keycode[29] ... keycode[0] |
    uint32_t kbd_reg = inl(KBD_ADDR);
    kbd->keydown = (kbd_reg & KEYDOWN_MASK) ? true : false;
    kbd->keycode = kbd_reg & (~KEYDOWN_MASK);
}
