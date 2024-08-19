#include "common.h"
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
    // set scope
    const svScope scope = svGetScopeFromName("TOP.xcore");
    assert(scope); // Check for nullptr if scope not found
    svSetScope(scope);
    // ------------------------------------------------------------------------



    // ----------------------- initialization ---------------------------------
    init_monitor(argc, argv);
    // ------------------------------------------------------------------------



    // ------------------- drive the DUT and monitor --------------------------
    sdb_mainloop();
    // ------------------------------------------------------------------------



    // ------------------------------- exit -----------------------------------
    tfp->close();   // close waveform gen
    delete dut;
    delete contextp;
    fclose(log_fp); // close log file
    // ------------------------------------------------------------------------



    // ----------- return the return value of the guest program ---------------
    return is_exit_status_bad();
    // ------------------------------------------------------------------------

}