#ifndef __TIKTOK_H__
#define __TIKTOK_H__

#include "common.h"

extern npcState npc_state;
extern coreState core;
extern VerilatedContext* contextp;
extern Vxcore* dut;
extern VerilatedVcdC* tfp;

// llvm - disasm.cc
#ifdef CONFIG_ITRACE
extern "C" void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);
extern "C" void init_disasm(const char *triple);
#endif

void core_exec(uint64_t n);
void core_init();

#endif