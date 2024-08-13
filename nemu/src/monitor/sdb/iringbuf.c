#include "sdb.h"

static iRingBuffer nemu_iringbuf;

void init_iringbuf() {
    for (int i = 0; i < IRINGBUF_SIZE; i++) {
        for (int j = 0; j < LOG_LEHGTH; j++) {
            nemu_iringbuf.data[i][j] = '\0';
        }
    }
    nemu_iringbuf.write_ptr = 0;
}

void write_iringbuf(const char *data) {
    nemu_iringbuf.write_ptr = (nemu_iringbuf.write_ptr + 1) % IRINGBUF_SIZE;
    strcpy(nemu_iringbuf.data[nemu_iringbuf.write_ptr], data);
}

void print_iringbuf() {
    for (int current_ptr = 0; current_ptr < IRINGBUF_SIZE; current_ptr++) {
        if (current_ptr == nemu_iringbuf.write_ptr) {
            Log(" --> %s", nemu_iringbuf.data[current_ptr]);
        }
        else {
            Log("     %s", nemu_iringbuf.data[current_ptr]);
        } 
    }
}