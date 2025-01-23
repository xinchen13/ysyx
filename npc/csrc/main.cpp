#include "common.h"
#include "sdb.h"
#include "fast_flash.h"

FILE *log_fp = NULL;
npcState npc_state;
coreState core = {};
VerilatedContext* contextp;
VysyxSoCFull* dut;
VerilatedVcdC* tfp;

void nvboard_bind_all_pins(VysyxSoCFull* ysyxSoCFull);

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
    nvboard_bind_all_pins(dut);
    nvboard_init();

    // ----------------------- initialization ---------------------------------
    init_monitor(argc, argv);

    #ifndef CONFIG_XIP_FLASH
        init_fast_flash();           // for simulation
    #endif


    // ------------------- drive the DUT and monitor --------------------------
    sdb_mainloop();


    // ------------------------------- exit -----------------------------------
    nvboard_quit();
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