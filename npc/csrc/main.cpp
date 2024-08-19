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
    tfp = new VerilatedVcdC;
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
    printf("*******tfp_open = %d********\n", tfp->isOpen());
    if (tfp->isOpen()) {
        tfp->close();   // close waveform gen
    }
    delete tfp;
    delete dut;
    delete contextp;
    fclose(log_fp); // close log file
    // ------------------------------------------------------------------------



    // ----------- return the return value of the guest program ---------------
    return is_exit_status_bad();
    // ------------------------------------------------------------------------

}