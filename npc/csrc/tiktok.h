#ifndef __TIKTOK_H__
#define __TIKTOK_H__

#include "common.h"

extern npcState npc_state;
extern coreState core;
extern VerilatedContext* contextp;
extern Vxcore* dut;
extern VerilatedVcdC* tfp;

void core_exec(uint64_t n);
void core_init();

#endif