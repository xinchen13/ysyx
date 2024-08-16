#include "common.h"
#include "vaddr.h"
#include "sdb.h"

int is_exit_status_bad(Vxcore* dut) {
    int good = dut->rootp->xcore__DOT__regfile_u0__DOT__regs[10];
    return good;
}

FILE *log_fp = NULL;
npcState npc_state;
coreState core = {};

int main(int argc, char** argv) {
    // ----------------------- verilator init ---------------------------------
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    Vxcore* dut = new Vxcore{contextp};

    // open trace: generate waveform
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    dut->trace(tfp, 99);
    tfp->open("build/wave.vcd");

    // set scope
    const svScope scope = svGetScopeFromName("TOP.xcore");
    assert(scope); // Check for nullptr if scope not found
    svSetScope(scope);
    // ------------------------------------------------------------------------


    init_monitor(argc, argv);

    sdb_mainloop();

    dut->clk = 1;
    dut->rst_n = 0;
    dut->clk ^= 1; dut->eval();
    tfp->dump(contextp->time()); // dump wave
    contextp->timeInc(1); // time + 1
    dut->clk ^= 1; dut->eval();
    tfp->dump(contextp->time()); // dump wave
    contextp->timeInc(1); // time + 1
    dut->rst_n = 1;
    while (dpi_that_accesses_ebreak() == 0 && contextp->time() < 999){
        dut->clk ^= 1; dut->eval();  // single_cycle();
        tfp->dump(contextp->time()); // dump wave
        contextp->timeInc(1); // time + 1
        dut->inst = vaddr_ifetch(dut->pc, 4);
        dut->clk ^= 1; dut->eval();  // single_cycle();
        tfp->dump(contextp->time()); // dump wave
        contextp->timeInc(1); // time + 1
    }
    int return_val = is_exit_status_bad(dut);


    // ----------------------- ------- exit ----------------------------------
    tfp->close();   // close waveform gen
    delete dut;
    delete contextp;
    fclose(log_fp); // close log file
    // ------------------------------------------------------------------------


    // ----------- return the return value of the guest program ---------------
    return return_val;
    // ------------------------------------------------------------------------

}