#include <am.h>
#include <nemu.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

void __am_gpu_init() {
    // int i;
    // int w = io_read(AM_GPU_CONFIG).width;  // TODO: get the correct width
    // int h = io_read(AM_GPU_CONFIG).height;  // TODO: get the correct height
    // uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
    // for (i = 0; i < w * h; i ++) fb[i] = i;
    // outl(SYNC_ADDR, 1);
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
    uint32_t gpu_config_reg = inl(VGACTL_ADDR);
    uint32_t gpu_width = (gpu_config_reg & 0xffff0000) >> 16;
    uint32_t gpu_height = gpu_config_reg & 0xffffu;
    *cfg = (AM_GPU_CONFIG_T) {
        .present = true, 
        .has_accel = false,
        .width = gpu_width, 
        .height = gpu_height,
        .vmemsz = 0             // unused
    };
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
    int w = ctl->w;
    int h = ctl->h;
    int y = ctl->y;
    int x = ctl->x;
    uint32_t *pix = ctl->pixels;
    uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
    uint32_t sc_width = (inl(VGACTL_ADDR) & 0xffff0000) >> 16;
    int i, j;
    for (j = y; j < y+h; j++) {
        for (i = x; i < x+w; i++) {
        fb[sc_width * j + i] = pix[(j-y)*w+(i-x)];
        }
    }
    if (ctl->sync) {
        outl(SYNC_ADDR, 1);
    }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}
