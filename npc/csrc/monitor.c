#include "common.h"
#include "paddr.h"
#include "host.h"
#include "sdb.h"
#include "tiktok.h"
#include "difftest.h"

static char *img_file = NULL;   // image file
static char *log_file = NULL;   // log file
static char *elf_file = NULL;
static char *diff_so_file = NULL;
static char *wave_file = NULL;

extern FILE *log_fp;
extern VerilatedVcdC* tfp;
extern VysyxSoCFull* dut;

static void init_wave_dump () {
    if (wave_file != NULL) {
        Verilated::traceEverOn(true);
        dut->trace(tfp, 99);
        tfp->open(wave_file);
    }
    else {
        Verilated::traceEverOn(false);
    }
}

static void welcome() {
    Log("Trace: %s", MUXDEF(CONFIG_TRACE, ANSI_FMT("ON", ANSI_FG_GREEN), ANSI_FMT("OFF", ANSI_FG_RED)));
    Log("Build time: %s, %s", __TIME__, __DATE__);
    printf("Welcome to %s-npc!\n", ANSI_FMT("riscv32e", ANSI_FG_YELLOW ANSI_BG_RED));
    printf("For help, type \"help\"\n");
}

static void init_log(const char *log_file) {
    log_fp = stdout;
    if (log_file != NULL) {
        FILE *fp = fopen(log_file, "w");
        Assert(fp, "Can not open '%s'", log_file);
        log_fp = fp;
    }
    Log("Log is written to %s", log_file ? log_file : "stdout");
}

static long load_img() {
    // if (img_file == NULL) {
    //     Assert("No image is given. Use the default build-in image.\n");
    //     return 0;
    // }

    FILE *fp = fopen(img_file, "rb");
    Assert(fp, "Can not open '%s'", img_file);

    fseek(fp, 0, SEEK_END);
    long size = ftell(fp);

    Log("load_img(): The image is %s, size = %ld\n", img_file, size);

    fseek(fp, 0, SEEK_SET);
    int ret = fread(guest_to_host(RESET_VECTOR), size, 1, fp);
    assert(ret == 1);

    fclose(fp);
    return size;
}

static int parse_args(int argc, char *argv[]) {
    const struct option table[] = {
        {"log"      , required_argument, NULL, 'l'},
        {"img"      , required_argument, NULL, 'i'},
        {"elf"      , required_argument, NULL, 'e'},
        {"diff"     , required_argument, NULL, 'd'},
        {"wave"     , required_argument, NULL, 'w'},
        {"help"     , no_argument      , NULL, 'h'},
        {0          , 0                , NULL,  0 },
    };
    int o;
    while ((o = getopt_long(argc, argv, "-hl:i:e:d:w:", table, NULL)) != -1) {
        switch (o) {
            case 'l': log_file = optarg; break;
            case 'i': img_file = optarg; break;
            case 'e': elf_file = optarg; break;
            case 'd': diff_so_file = optarg; break;
            case 'w': wave_file = optarg; break;
            default:
                printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
                printf("\t-l,--log=FILE        output log to FILE\n");
                printf("\t-i,--img=FILE        read img file\n");
                printf("\t-e,--elf=FILE        get ftrace elf to elf_file\n");
                printf("\t-d,--diff=REF_SO     run DiffTest with reference REF_SO\n");
                printf("\t-w,--wave=FILE       dump wave to FILE\n");
                printf("\n");
                exit(0);
        }
    }
    return 0;
}


void init_monitor(int argc, char *argv[]) {
    /* Perform some global initialization. */

    // initialize itrace ringbuffer
    IFDEF(CONFIG_ITRACE, init_iringbuf());

    /* Parse arguments. */
    parse_args(argc, argv);

    // dump waves to "wave_file"
    init_wave_dump();   // verilator

    // read elf file to get function infomation
    IFDEF(CONFIG_FTRACE, init_ftrace_stfunc(elf_file));
    display_elfstfunc();

    /* Open the log file. */
    init_log(log_file);

    /* Initialize memory. */
    init_mem();
    init_psram();

    /* Load the image to memory. This will overwrite the built-in image. */
    long img_size = load_img();

    /* Initialize the simple debugger. */
    init_sdb();

    // init difftest
    #ifdef CONFIG_DIFFTEST
        init_difftest(diff_so_file, img_size, 1234);
    #endif

    /* init disasm */
    IFDEF(CONFIG_ITRACE, init_disasm("riscv32-pc-linux-gnu"));

    /* Display welcome message. */
    welcome();
}
