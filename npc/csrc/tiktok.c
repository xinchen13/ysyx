#include "common.h"
#include "tiktok.h"
#include "vaddr.h"
#include "reg.h"
#include "sdb.h"

static char logbuf[256];    // for itrace

static void trace_and_difftest() {
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
    dut->clk ^= 1; dut->eval();  // negedge
    tfp->dump(contextp->time());
    contextp->timeInc(1);
    dut->inst = vaddr_ifetch(dut->pc, 4);
    dut->clk ^= 1; dut->eval();  // posedge
    tfp->dump(contextp->time());
    contextp->timeInc(1); // time + 1

    // update regs in monitor
    isa_reg_update();

    // #ifdef CONFIG_ITRACE
    //     char *p = logbuf;
    //     p += snprintf(p, sizeof(logbuf), FMT_WORD ":", core.pc);
    //     int ilen = s->snpc - s->pc;
    //     int i;
    //     uint8_t *inst = (uint8_t *)&s->isa.inst.val;
    //     for (i = ilen - 1; i >= 0; i --) {
    //         p += snprintf(p, 4, " %02x", inst[i]);
    //     }
    //     int ilen_max = MUXDEF(CONFIG_ISA_x86, 8, 4);
    //     int space_len = ilen_max - ilen;
    //     if (space_len < 0) space_len = 0;
    //     space_len = space_len * 3 + 1;
    //     memset(p, ' ', space_len);
    //     p += space_len;

    //     #ifndef CONFIG_ISA_loongarch32r
    //     void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);
    //     disassemble(p, s->logbuf + sizeof(s->logbuf) - p,
    //         MUXDEF(CONFIG_ISA_x86, s->snpc, s->pc), (uint8_t *)&s->isa.inst.val, ilen);
    //     #else
    //     p[0] = '\0'; // the upstream llvm does not support loongarch32r
    //     #endif
    // #endif
}

static void execute(uint64_t n) {
    for (;n > 0; n --) {
        exec_once();
        trace_and_difftest();
        if (dpi_that_accesses_inst() == 0x00100073 || contextp->time() > 999) {
            set_npc_state(NPC_END, core.pc, core.gpr[10]);
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
}