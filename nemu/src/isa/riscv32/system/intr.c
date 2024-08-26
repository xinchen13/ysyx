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

word_t isa_raise_intr(word_t NO, vaddr_t epc) {
    /* TODO: Trigger an interrupt/exception with ``NO''.
    * Then return the address of the interrupt/exception vector.
    */

    // // ------------- for debug ------------
    // printf("ref mcause  = %d \n", NO);
    // printf("ref mstatus = %d \n", cpu.mstatus);
    // printf("ref mepc    = %d \n", epc);
    // for (int i = 0; i < ARRLEN(cpu.gpr); i++) {
    //     printf("ref reg[%d] = %d \n", i, cpu.gpr[i]);
    // }
    // // ------------------------------------

    #ifdef CONFIG_ETRACE
        Log("etrace: cpu.mcause  = %d", NO);
        Log("etrace: cpu.mstatus = " FMT_WORD, cpu.mstatus);
        Log("etrace: cpu.mepc    = " FMT_WORD, epc);
    #endif

    cpu.mepc = epc;
    cpu.mcause = NO;
    return cpu.mtvec;
}

word_t isa_query_intr() {
  return INTR_EMPTY;
}
