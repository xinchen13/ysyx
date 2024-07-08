#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h" // for wave gen

vluint64_t sim_time = 5; // initial simulation time

int main(int argc, char** argv) {
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    Vtop* top = new Vtop{contextp};

    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("obj_dir/wave.vcd");
    while(contextp->time() < sim_time && !contextp->gotFinish()){
        contextp->timeInc(1); // time + 1
        int a = rand() & 1;
        int b = rand() & 1;
        top->a = a;
        top->b = b;
        top->eval();
        printf("a = %d, b = %d, f = %d\n", a, b, top->f);
        assert(top->f == (a ^ b));
        tfp->dump(contextp->time()); // dump wave
    }
    tfp->close(); //close
    delete top;
    delete contextp;
    return 0;
}