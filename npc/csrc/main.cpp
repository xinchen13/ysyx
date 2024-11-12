#include "common.h"
#include "sdb.h"

FILE *log_fp = NULL;
npcState npc_state;
coreState core = {};
VerilatedContext* contextp;
VysyxSoCFull* dut;
VerilatedVcdC* tfp;

extern "C" void flash_read(int32_t addr, int32_t *data) { assert(0); }
extern "C" void mrom_read(int32_t addr, int32_t *data) { 
    *data = 0x73; 
}

int main(int argc, char** argv) {
    // ----------------------- verilator init ---------------------------------
    contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    dut = new VysyxSoCFull{contextp};
    tfp = new VerilatedVcdC;
    // set scope: for DPI-C
    // const svScope scope = svGetScopeFromName("TOP.soc_top");
    // assert(scope); // Check for nullptr if scope not found
    // svSetScope(scope);


    // ----------------------- initialization ---------------------------------
    init_monitor(argc, argv);


    // ------------------- drive the DUT and monitor --------------------------
    sdb_mainloop();


    // ------------------------------- exit -----------------------------------
    if (tfp->isOpen()) {
        tfp->close();   // close waveform gen
    }
    delete tfp;
    delete dut;
    delete contextp;
    fclose(log_fp); // close log file


    // ----------- return the return value of the guest program ---------------
    return is_exit_status_bad();
}