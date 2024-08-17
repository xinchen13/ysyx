#include "common.h"
#include "tiktok.h"
#include "vaddr.h"

static void exec_once() {
    dut->clk ^= 1; dut->eval();  // negedge
    tfp->dump(contextp->time());
    contextp->timeInc(1);
    dut->inst = vaddr_ifetch(dut->pc, 4);
    dut->clk ^= 1; dut->eval();  // posedge
    tfp->dump(contextp->time());
    contextp->timeInc(1); // time + 1
}

static void execute(uint64_t n) {
    for (;n > 0; n --) {
        if (dpi_that_accesses_ebreak() == 0 && contextp->time() < 999) {
            break;
        }
        exec_once();
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