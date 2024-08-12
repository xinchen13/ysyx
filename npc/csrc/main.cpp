#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "Vxcore.h"
#include "verilated.h"
#include "verilated_vcd_c.h" // for wave gen

#include "Vxcore__Dpi.h"
#include "svdpi.h"


#define MEMORY_SIZE 1024
#define BASE_ADDRESS 0x80000000

uint32_t memory[MEMORY_SIZE];

static void initialize_memory() {
    for (int i = 0; i < MEMORY_SIZE; i++) {
        memory[i] = 0; // initialize
    }
    
    // instructions (addi)
    memory[0x80000000 - BASE_ADDRESS] = 0b00000000000100000000101010010011;  // rf[21] = rf[0] + 1 = 0x00000001
    memory[0x80000004 - BASE_ADDRESS] = 0b00000000000100000000000100010011; // rf[2] = rf[0] + 1 = 0x00000001
    memory[0x80000008 - BASE_ADDRESS] = 0b11111111111000010000000100010011;  // rf[2] = rf[2] - 2 = 0xffffffff
    memory[0x8000000c - BASE_ADDRESS] = 0b11111111111100000000000110010011;  // rf[3] = rf[0] - 1 = 0xffffffff
    memory[0x80000010 - BASE_ADDRESS] = 0b00000000000100000000000001110011;   //  ebreak: 32'h00100073
    // ...
}

static uint32_t fetch_instruction(uint32_t pc) {
    if (pc >= BASE_ADDRESS && pc < BASE_ADDRESS + MEMORY_SIZE) {
        return memory[pc - BASE_ADDRESS];
    } else {
        // address out of memory bound
        printf("Error: PC value is out of memory bounds\n");
        return 0;
    }
}

// vluint64_t sim_time = 8; // initial simulation time

int main(int argc, char** argv) {
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    Vxcore* top = new Vxcore{contextp};
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("build/obj_dir/wave.vcd");

    initialize_memory(); // memory init
    top->clk = 1;
    
    top->rst_n = 0;
    top->clk ^= 1; top->eval();
    tfp->dump(contextp->time()); // dump wave
    contextp->timeInc(1); // time + 1
    top->clk ^= 1; top->eval();
    tfp->dump(contextp->time()); // dump wave
    contextp->timeInc(1); // time + 1
    
    top->rst_n = 1;

    // set scope
    const svScope scope = svGetScopeFromName("TOP.xcore");
    assert(scope); // Check for nullptr if scope not found
    svSetScope(scope);
    
    while (dpi_that_accesses_ebreak() == 0){
        // printf("%x\n",top->pc);
        top->clk ^= 1; top->eval();  // single_cycle();
        tfp->dump(contextp->time()); // dump wave
        contextp->timeInc(1); // time + 1

        top->inst = fetch_instruction(top->pc);

        top->clk ^= 1; top->eval();  // single_cycle();
        tfp->dump(contextp->time()); // dump wave
        contextp->timeInc(1); // time + 1
    }
    tfp->close(); //close
    delete top;
    delete contextp;
    return 0;
}