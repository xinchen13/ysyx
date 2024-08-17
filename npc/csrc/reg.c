#include "common.h"
#include "reg.h"

const char *regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

void isa_reg_display() {
    // rv32e: 16 * gprs
    // rv32/rv64: 32 * gprs
    int gpr_count = MUXDEF(CONFIG_RVE, 16, 32);
    printf(" pc = " FMT_WORD "\n", core.pc); // display the value of pc
    for (int i = 0; i < gpr_count; i++) {
        // display the value of gpr
        printf("%3s = " FMT_WORD "\n",regs[i], core.gpr[i]);
    }
}

word_t isa_reg_str2val(const char *s, bool *success) {
    if (strcmp(s, "pc") == 0) {
        return core.pc;
    }
    int gpr_count = MUXDEF(CONFIG_RVE, 16, 32);
    for (int i = 0; i < gpr_count; i++) {
        if (strcmp(s, regs[i]) == 0) {
            return core.gpr[i];
        }
    }
    *success = false;
    return 0;
}

// for monitor
void isa_reg_update() {
    core.pc = dut->pc;
    int gpr_count = MUXDEF(CONFIG_RVE, 16, 32);
    for (int i = 0; i < gpr_count; i++) {
        core.gpr[i] = dut->rootp->xcore__DOT__regfile_u0__DOT__regs[i];
    }
}