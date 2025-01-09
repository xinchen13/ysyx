#include <am.h>

#define VGA_WIDTH       640
#define VGA_HEIGHT      480
#define VGA_FB_ADDR     0x21000000

void __am_gpu_init() {
    ;
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
    *cfg = (AM_GPU_CONFIG_T) {
        .present = true, 
        .has_accel = false,
        .width = VGA_WIDTH, 
        .height = VGA_HEIGHT,
        .vmemsz = VGA_WIDTH * VGA_HEIGHT * 4
    };
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
    int w = ctl->w;
    int h = ctl->h;
    int y = ctl->y;
    int x = ctl->x;
    uint32_t *pix = ctl->pixels;
    uint32_t *fb = (uint32_t *)(uintptr_t)VGA_FB_ADDR;
    int i, j;
    for (j = y; j < y+h; j++) {
        for (i = x; i < x+w; i++) {
        fb[VGA_WIDTH * j + i] = pix[(j-y)*w+(i-x)];
        }
    }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
    status->ready = true;
}
