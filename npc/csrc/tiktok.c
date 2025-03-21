#include "common.h"
#include "tiktok.h"
#include "vaddr.h"
#include "reg.h"
#include "sdb.h"
#include "difftest.h"

static word_t this_inst;
static word_t this_pc;
static word_t dnpc;

#ifdef CONFIG_PMU
static uint64_t cycle_count = 0;
static uint64_t inst_count = 0;
static uint64_t lsu_read_count = 0;
static uint64_t a_type = 0;   
static uint64_t b_type = 0;   
static uint64_t c_type = 0;   
static uint64_t load_type = 0;
static uint64_t store_type = 0;
static uint64_t a_type_cycle = 0;    
static uint64_t b_type_cycle = 0;    
static uint64_t c_type_cycle = 0;    
static uint64_t load_type_cycle = 0;
static uint64_t store_type_cycle = 0;
static uint64_t front_end_fetch_cycle = 0;
static uint64_t icache_hit = 0;
static uint64_t icache_miss = 0;
static uint64_t access_time_total = 0;
static uint64_t miss_penalty_total = 0;
static void pmu_exec() {
    ;
}
static void pmu_display() {
    // read pmu:
    cycle_count = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__pmu_u0__DOT__cycle_count;
    inst_count = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__pmu_u0__DOT__inst_count;
    lsu_read_count = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__pmu_u0__DOT__lsu_read_count;

    // read pmu: inst count
    a_type = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__pmu_u0__DOT__a_type;   
    b_type = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__pmu_u0__DOT__b_type;   
    c_type = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__pmu_u0__DOT__c_type;   
    load_type = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__pmu_u0__DOT__load_type;
    store_type = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__pmu_u0__DOT__store_type;

    // read pmu: 
    a_type_cycle = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__pmu_u0__DOT__a_type_cycle;
    b_type_cycle = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__pmu_u0__DOT__b_type_cycle;  
    c_type_cycle = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__pmu_u0__DOT__c_type_cycle;
    load_type_cycle = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__pmu_u0__DOT__load_type_cycle;
    store_type_cycle = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__pmu_u0__DOT__store_type_cycle;
    front_end_fetch_cycle = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__pmu_u0__DOT__front_end_fetch_cycle;

    // log out
    Log("************ Performance Monitor ************");
    Log("Total cycle count = %" PRIu64, cycle_count);
    Log("   - A(alu) type count         = %" PRIu64 "(%.3lf)", a_type_cycle, ((double)a_type_cycle)/(double(cycle_count)));
    Log("   - B(branch) type count      = %" PRIu64 "(%.3lf)", b_type_cycle, ((double)b_type_cycle)/(double(cycle_count)));
    Log("   - C(csr) type count         = %" PRIu64 "(%.3lf)", c_type_cycle, ((double)c_type_cycle)/(double(cycle_count)));
    Log("   - Memory load type count    = %" PRIu64 "(%.3lf)", load_type_cycle, ((double)load_type_cycle)/(double(cycle_count)));
    Log("   - Memory store type count   = %" PRIu64 "(%.3lf)", store_type_cycle, ((double)store_type_cycle)/(double(cycle_count)));
    Log("   - Front end: fetch count    = %" PRIu64 "(%.3lf)", front_end_fetch_cycle, ((double)front_end_fetch_cycle)/(double(cycle_count)));
    Log("Total insts count = %" PRIu64, inst_count);
    Log("   - A(alu) type count         = %" PRIu64 "(%.3lf)", a_type, ((double)a_type)/(double(inst_count)));
    Log("   - B(branch) type count      = %" PRIu64 "(%.3lf)", b_type, ((double)b_type)/(double(inst_count)));
    Log("   - C(csr) type count         = %" PRIu64 "(%.3lf)", c_type, ((double)c_type)/(double(inst_count)));
    Log("   - Memory load type count    = %" PRIu64 "(%.3lf)", load_type, ((double)load_type)/(double(inst_count)));
    Log("   - Memory store type count   = %" PRIu64 "(%.3lf)", store_type, ((double)store_type)/(double(inst_count)));
    Log("CPI = %.3lf (IPC = %lf)", ((double)cycle_count/(double)inst_count), ((double)inst_count)/(double(cycle_count)));
    Log("   - A(alu) type         = %.3lf", ((double)a_type_cycle)/(double(a_type)));
    Log("   - B(branch) type      = %.3lf", ((double)b_type_cycle)/(double(b_type)));
    Log("   - C(csr) type         = %.3lf", ((double)c_type_cycle)/(double(c_type)));
    Log("   - Memory load type    = %.3lf", ((double)load_type_cycle)/(double(load_type)));
    Log("   - Memory store type   = %.3lf", ((double)store_type_cycle)/(double(store_type)));
    #ifdef CONFIG_ICACHE
    // icache
        icache_hit = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__icache_u0__DOT__real_cache_hit;
        icache_miss = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__icache_u0__DOT__real_cache_miss;
        double icache_hit_rate = ((double)icache_hit)/(double(icache_hit + icache_miss));
        double icache_miss_rate = ((double)icache_miss)/(double(icache_hit + icache_miss));
        access_time_total = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__icache_u0__DOT__access_time_total;
        miss_penalty_total = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__icache_u0__DOT__miss_penalty_total;
        double access_time_avg = (double(access_time_total))/(double(icache_hit));
        double miss_penalty_avg = (double(miss_penalty_total))/(double(icache_miss));
        double amat = icache_hit_rate * access_time_avg + icache_miss_rate * miss_penalty_avg;
        Log("icache report");
        Log("   - icache hit            = %" PRIu64 "(%.3lf)", icache_hit,  icache_hit_rate);
        Log("   - icache miss           = %" PRIu64 "(%.3lf)", icache_miss, icache_miss_rate);
        Log("   - Access time (avg)     = %.3lf cycles", access_time_avg);
        Log("   - Miss penalty (avg)    = %.3lf cycles", miss_penalty_avg);
        Log("   - AMAT                  = %.3lf cycles", amat);
    #endif
    // Log("Total lsu read = %" PRIu64, lsu_read_count);
    Log("*********************************************");
}
#endif

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
    if (dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__fetch_id_valid) {
        Log("%s", logbuf);
        write_iringbuf(logbuf);  // write log to iringbuf
        if (npc_state.state == NPC_ABORT) {
            print_iringbuf();
        }
    }
    #endif

    // difftest
    #ifdef CONFIG_DIFFTEST
        if (!retire_pc) {
            difftest_skip_ref();
        }
        difftest_step(difftest_pc, dnpc);
        // skip device inst
        // if ((uint32_t)dut->rootp->soc_top__DOT__xcore_u0__DOT__wb_alu_result == (0xa00003f8)) {
        //     difftest_skip_ref();
        // }
    #endif

    // ftracer
    #ifdef CONFIG_FTRACE
    if (dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__fetch_id_valid) {
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
    this_inst = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__id_inst;
    this_pc = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__id_pc;
    dnpc = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__ex_dnpc;
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
        retire_pc = dut->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu_wrapper_u0__DOT__xcore_u0__DOT__lsu_wb_valid ? true : false;
    #endif

    dut->clock ^= 1; dut->eval();  // negedge
    tfp->dump(contextp->time());
    contextp->timeInc(1);
    // dut->inst = vaddr_ifetch(dut->pc, 4);
    dut->clock ^= 1; dut->eval();  // posedge
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
        nvboard_update();
        #ifdef CONFIG_PMU
        pmu_exec();
        #endif
        trace_and_difftest();
        if (this_inst == 0x00100073 /* || contextp->time() > 9999999999*/) {
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

    #ifdef CONFIG_PMU
    pmu_display();
    #endif

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
    dut->clock = 1;
    dut->reset = 1;
    dut->clock ^= 1; dut->eval();
    tfp->dump(contextp->time());
    contextp->timeInc(1);
    dut->clock ^= 1; dut->eval(); // posedge
    tfp->dump(contextp->time());
    contextp->timeInc(1);
    dut->clock ^= 1; dut->eval(); // posedge
    tfp->dump(contextp->time());
    contextp->timeInc(1);
    dut->clock ^= 1; dut->eval(); // posedge
    tfp->dump(contextp->time());
    contextp->timeInc(1);
    dut->reset = 0;
    isa_reg_update();
}