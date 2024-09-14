#include "common.h"
#include "tiktok.h"
#include "vaddr.h"
#include "reg.h"
#include "sdb.h"
#include "difftest.h"

static word_t this_inst;
static word_t this_pc;
static word_t dnpc;
static int inst_count = 0;

#ifdef CONFIG_DIFFTEST
    static word_t difftest_pc;
    static bool retire_pc = false;
#endif

#ifdef CONFIG_ITRACE
    static word_t itrace_pc;
    static char logbuf[128];    // for itrace
    static word_t itrace_inst;
#endif

#ifdef CONFIG_FTRACE
    #define JAL_OPCODE 0x6fu
    #define JALR_OPCODE 0x67u

    static int func_call_depth = 1;     // for ftrace
    static word_t ftrace_inst;
    static word_t ftrace_pc;
    static word_t ftrace_dnpc;
    static uint32_t opcode;
    static uint32_t rd;
    static uint32_t rs1;

    static int func_call() {
        if (opcode == JAL_OPCODE) {
            if ((rd == 1) || (rd == 5)) {
                return 1;
            }
        }
        else if (opcode == JALR_OPCODE) {
            if (((rd == 1) || (rd == 5)) && (rs1 != 1) && (rs1 != 5)) {
                return 1;
            }
            else if (((rd == 1) || (rd == 5)) && (rs1 == rd)) {
                return 1;
            }
            else if (((rd == 1) && (rs1 == 5)) || ((rd == 5) && (rs1 == 1))) {
                return 1;
            }
        }
        return 0;
    }

    static int func_retn() {
        if (opcode == JALR_OPCODE) {
            if (((rs1 == 1) || (rs1 == 5)) && (rd != 1) && (rd != 5)) {
                return 1;
            }
            else if (((rd == 1) && (rs1 == 5)) || ((rd == 5) && (rs1 == 1))) {
                return 1;
            }
        }
        return 0;
    }
#endif

static void trace_and_difftest() {
    // itrace
    #ifdef CONFIG_ITRACE
        Log("%s", logbuf);
        write_iringbuf(logbuf);  // write log to iringbuf
        if (npc_state.state == NPC_ABORT) {
            print_iringbuf();
        }
    #endif

    // difftest
    #ifdef CONFIG_DIFFTEST
        if (!retire_pc) {
            difftest_skip_ref();
        }
        difftest_step(difftest_pc, dnpc);
        // skip device inst
        if ((uint32_t)dut->rootp->xcore__DOT__wb_alu_result == (0xa00003f8)) {
            difftest_skip_ref();
        }
    #endif

    // ftracer
    #ifdef CONFIG_FTRACE
        opcode = ftrace_inst & 0x7fu;
        rd = (ftrace_inst >> 7) & 0x1fu;
        rs1 = (ftrace_inst >> 15) & 0x1fu;
        if (func_retn()) {
            func_call_depth -= 2;
            ftrace_retn(ftrace_pc, func_call_depth);
        }
        if (func_call()) {
            ftrace_call(ftrace_pc, ftrace_dnpc, func_call_depth);
            func_call_depth += 2;
        }
    #endif

    // enable check watchpoints
    IFDEF(CONFIG_WATCHPOINT,
        if (check_watchpoint() == 1 && npc_state.state != NPC_END) {
            npc_state.state = NPC_STOP;
        }
    );
}

void set_npc_state(int state, uint32_t pc, int halt_ret) {
    npc_state.state = state;
    npc_state.halt_pc = pc;
    npc_state.halt_ret = halt_ret;
}

static void exec_once() {
    this_inst = dut->rootp->xcore__DOT__id_inst;
    this_pc = dut->rootp->xcore__DOT__id_pc;
    dnpc = dut->rootp->xcore__DOT__ex_dnpc;
    #ifdef CONFIG_ITRACE
        itrace_inst = this_inst;
        itrace_pc = this_pc;
    #endif

    #ifdef CONFIG_FTRACE
        ftrace_inst = this_inst;
        ftrace_pc = this_pc;
        ftrace_dnpc = dnpc;
    #endif

    #ifdef CONFIG_DIFFTEST
        difftest_pc = this_pc;
        retire_pc = dut->rootp->xcore__DOT__lsu_wb_valid ? true : false;
    #endif

    dut->clk ^= 1; dut->eval();  // negedge
    tfp->dump(contextp->time());
    contextp->timeInc(1);
    // dut->inst = vaddr_ifetch(dut->pc, 4);
    dut->clk ^= 1; dut->eval();  // posedge
    tfp->dump(contextp->time());
    contextp->timeInc(1); // time + 1

    // update regs in monitor
    isa_reg_update();

    #ifdef CONFIG_ITRACE
        char *p = logbuf;
        p += snprintf(p, sizeof(logbuf), FMT_WORD ":", itrace_pc);
        int ilen = 4;
        int i;
        uint8_t *inst = (uint8_t *)&itrace_inst;
        for (i = ilen - 1; i >= 0; i --) {
            p += snprintf(p, 4, " %02x", inst[i]);
        }
        int ilen_max = 4;
        int space_len = ilen_max - ilen;
        if (space_len < 0) space_len = 0;
        space_len = space_len * 3 + 1;
        memset(p, ' ', space_len);
        p += space_len;
        disassemble(p, logbuf + sizeof(logbuf) - p, itrace_pc, (uint8_t *)&itrace_inst, ilen);
    #endif
}

static void execute(uint64_t n) {
    for (;n > 0; n --) {
        exec_once();
        inst_count++;
        trace_and_difftest();
        if (this_inst == 0x00100073 || contextp->time() > 99999999) {
            set_npc_state(NPC_END, this_pc, core.gpr[10]);
            break;
        }
        if (npc_state.state != NPC_RUNNING) {
            break;
        }
    }
}

/* Simulate how the core works. */
void core_exec(uint64_t n) {
    switch (npc_state.state) {
        case NPC_END: case NPC_ABORT:
        printf("Program execution has ended. To restart the program, exit NEMU and run again.\n");
        return;
        default: npc_state.state = NPC_RUNNING;
    }

    execute(n);

    Log("total guest instructions = %d", inst_count);

    switch (npc_state.state) {
        case NPC_RUNNING: 
            npc_state.state = NPC_STOP; 
            break;
        case NPC_END: case NPC_ABORT:
            Log("npc: %s at pc = " FMT_WORD,
                (npc_state.state == NPC_ABORT ? ANSI_FMT("ABORT", ANSI_FG_RED) :
                (npc_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) :
                    ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED))),
                npc_state.halt_pc);
        // fall through
        case NPC_QUIT: ;
    }
}

void core_init() {
    dut->clk = 1;
    dut->rst_n = 0;
    dut->clk ^= 1; dut->eval();
    tfp->dump(contextp->time());
    contextp->timeInc(1);
    dut->clk ^= 1; dut->eval(); // posedge
    tfp->dump(contextp->time());
    contextp->timeInc(1);
    dut->rst_n = 1;
    isa_reg_update();
}