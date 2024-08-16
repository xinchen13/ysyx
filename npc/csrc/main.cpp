#include "common.h"

#define MEMORY_SIZE 1024
#define BASE_ADDRESS 0x80000000

uint8_t pmem[MEMORY_SIZE];                  // physical memory

void init_mem(uint8_t* mem) {
    memset(mem, rand(), MEMORY_SIZE);
}

long load_img(uint8_t* mem, char *img) {
    if (img == NULL) {
        printf("No image is given. Use the default build-in image.\n");
        return 0;
    }

    FILE *fp = fopen(img, "rb");
    assert(fp);

    fseek(fp, 0, SEEK_END);
    long size = ftell(fp);

    printf("load_img(): The image is %s, size = %ld\n", img, size);

    fseek(fp, 0, SEEK_SET);
    int ret = fread(mem, size, 1, fp);
    assert(ret == 1);

    fclose(fp);
    return size;
}


static uint32_t fetch_instruction(uint32_t pc) {
    if (pc >= BASE_ADDRESS && pc < BASE_ADDRESS + MEMORY_SIZE) {
        return *(uint32_t *)(pmem + pc - BASE_ADDRESS);
    } else {
        // address out of memory bound
        printf("Error: PC value is out of memory bounds\n");
        return 0;
    }
}

// vluint64_t sim_time = 8; // initial simulation time

char *img_file = NULL;                      // image file
int parse_args(int argc, char *argv[]) {
    const struct option table[] = {
        {"img"      , required_argument, NULL, 'i'},
        {"help"     , no_argument      , NULL, 'h'},
        {0          , 0                , NULL,  0 },
    };
    int o;
    while ((o = getopt_long(argc, argv, "-hi:", table, NULL)) != -1) {
        switch (o) {
            case 'i': img_file = optarg; break;
            default:
                printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
                printf("\t-i,--img=FILE read img file\n");
                printf("\n");
                exit(0);
        }
    }
    return 0;
}

int is_exit_status_bad(Vxcore* top) {
    int good = top->rootp->xcore__DOT__regfile_u0__DOT__regs[10];
    return good;
}

int main(int argc, char** argv) {
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    Vxcore* top = new Vxcore{contextp};

    // open trace: generate waveform
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("build/wave.vcd");

    // set scope
    const svScope scope = svGetScopeFromName("TOP.xcore");
    assert(scope); // Check for nullptr if scope not found
    svSetScope(scope);

    parse_args(argc, argv);
    // init physical memory randomly
    init_mem(pmem);

    // load image file to physical memory
    long img_size = load_img(pmem, img_file);

    top->clk = 1;
    
    top->rst_n = 0;
    top->clk ^= 1; top->eval();
    tfp->dump(contextp->time()); // dump wave
    contextp->timeInc(1); // time + 1
    top->clk ^= 1; top->eval();
    tfp->dump(contextp->time()); // dump wave
    contextp->timeInc(1); // time + 1
    
    top->rst_n = 1;


    
    while (dpi_that_accesses_ebreak() == 0 && contextp->time() < 999){
        // printf("%x\n",top->pc);
        top->clk ^= 1; top->eval();  // single_cycle();
        tfp->dump(contextp->time()); // dump wave
        contextp->timeInc(1); // time + 1

        top->inst = fetch_instruction(top->pc);

        top->clk ^= 1; top->eval();  // single_cycle();
        tfp->dump(contextp->time()); // dump wave
        contextp->timeInc(1); // time + 1
    }

    // close waveform gen
    tfp->close();

    int return_val = is_exit_status_bad(top);

    // verilator exit
    delete top;
    delete contextp;
    return return_val;
}