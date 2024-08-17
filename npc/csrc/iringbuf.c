#include "sdb.h"

static iRingBuffer npc_iringbuf;

void init_iringbuf() {
    for (int i = 0; i < IRINGBUF_SIZE; i++) {
        for (int j = 0; j < LOG_LEHGTH; j++) {
            npc_iringbuf.data[i][j] = '\0';
        }
    }
    npc_iringbuf.write_ptr = 0;
}

void write_iringbuf(const char *data) {
    npc_iringbuf.write_ptr = (npc_iringbuf.write_ptr + 1) % IRINGBUF_SIZE;
    strcpy(npc_iringbuf.data[npc_iringbuf.write_ptr], data);
}

void print_iringbuf() {
    for (int current_ptr = 0; current_ptr < IRINGBUF_SIZE; current_ptr++) {
        if (current_ptr == npc_iringbuf.write_ptr) {
            Log(" --> %s", npc_iringbuf.data[current_ptr]);
        }
        else {
            Log("     %s", npc_iringbuf.data[current_ptr]);
        } 
    }
}