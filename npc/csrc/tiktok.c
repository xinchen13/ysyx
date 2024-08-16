#include "common.h"

extern npcState npc_state;

static void exec_once() {
    ;
}

static void execute(uint64_t n) {
    for (;n > 0; n --) {
        exec_once();
        if (npc_state.state != NPC_RUNNING) break;
    }
}

/* Simulate how the core works. */
void cpu_exec(uint64_t n) {
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