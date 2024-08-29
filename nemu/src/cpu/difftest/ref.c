/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <isa.h>
#include <cpu/cpu.h>
#include <difftest-def.h>
#include <memory/paddr.h>

__EXPORT void difftest_memcpy(paddr_t addr, void *buf, size_t n, bool direction) {
    if (direction == DIFFTEST_TO_REF) {
        memcpy(guest_to_host(addr), buf, n);
    } 
    else {
        assert(0);
    }
}

__EXPORT void difftest_regcpy(void *dut, bool direction) {
    int reg_num = ARRLEN(cpu.gpr);
    CPU_state *cpu_ptr = (CPU_state *)dut;
    if (direction == DIFFTEST_TO_REF) {
        cpu.pc = cpu_ptr->pc;
        for (int i = 0; i < reg_num; i++) {
            cpu.gpr[i] = cpu_ptr->gpr[i];
        }
        // isa_reg_display();
    }
    else if (direction == DIFFTEST_TO_DUT) {
        cpu_ptr->pc = cpu.pc;
        for (int i = 0; i < reg_num; i++) {
            cpu_ptr->gpr[i] = cpu.gpr[i];
        }
    }
    else {
        assert(0);
    }
}

__EXPORT void difftest_exec(uint64_t n) {
    cpu_exec(n);
}

__EXPORT void difftest_raise_intr(word_t NO) {
    assert(0);
}

__EXPORT void difftest_init(int port) {
  void init_mem();
  init_mem();
  /* Perform ISA dependent initialization. */
  init_isa();
}
