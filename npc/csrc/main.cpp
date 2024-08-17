#include "common.h"
#include "vaddr.h"
#include "sdb.h"

FILE *log_fp = NULL;
npcState npc_state;
coreState core = {};
VerilatedContext* contextp;
Vxcore* dut;
VerilatedVcdC* tfp;

int main(int argc, char** argv) {
    // ----------------------- verilator init ---------------------------------
    contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    dut = new Vxcore{contextp};

    // open trace: generate waveform
    Verilated::traceEverOn(true);
    tfp = new VerilatedVcdC;
    dut->trace(tfp, 99);
    tfp->open("build/wave.vcd");

    // set scope
    const svScope scope = svGetScopeFromName("TOP.xcore");
    assert(scope); // Check for nullptr if scope not found
    svSetScope(scope);
    // ------------------------------------------------------------------------


    init_monitor(argc, argv);

    sdb_mainloop();


    while (dpi_that_accesses_ebreak() == 0 && contextp->time() < 999){
        dut->clk ^= 1; dut->eval();  // negedge
        tfp->dump(contextp->time());

        contextp->timeInc(1);
        dut->inst = vaddr_ifetch(dut->pc, 4);
        dut->clk ^= 1; dut->eval();  // posedge
        tfp->dump(contextp->time());
        contextp->timeInc(1); // time + 1
    }


    // ------------------------------- exit ----------------------------------
    tfp->close();   // close waveform gen
    delete dut;
    delete contextp;
    fclose(log_fp); // close log file
    // ------------------------------------------------------------------------


    // ----------- return the return value of the guest program ---------------
    return is_exit_status_bad();
    // ------------------------------------------------------------------------

}