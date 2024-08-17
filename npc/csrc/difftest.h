#ifndef __DIFFTEST_H__
#define __DIFFTEST_H__

#include "common.h"

extern npcState npc_state;
extern coreState core;

enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };

#define RISCV_GPR_TYPE MUXDEF(CONFIG_RV64, uint64_t, uint32_t)
#define RISCV_GPR_NUM  MUXDEF(CONFIG_RVE, 16, 32)
#define DIFFTEST_REG_SIZE (sizeof(RISCV_GPR_TYPE) * (RISCV_GPR_NUM + 1)) // GPRs + pc

void init_difftest(char *ref_so_file, long img_size, int port);
void difftest_step(word_t pc, word_t npc);
void difftest_skip_ref();

#endif