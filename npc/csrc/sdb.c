#include "common.h"
#include "sdb.h"
#include "vaddr.h"
#include "reg.h"
#include "tiktok.h"

void init_regex();
void init_wp_pool();

/* We use the `readline' library to provide more flexibility to read from stdin. */
static char* rl_gets() {
    static char *line_read = NULL;

    if (line_read) {
        free(line_read);
        line_read = NULL;
    }

    line_read = readline("(npc) ");

    if (line_read && *line_read) {
        add_history(line_read);
    }

    return line_read;
}

static int cmd_c(char *args) {
    cpu_exec(-1);
    return 0;
}


static int cmd_q(char *args) {
    npc_state.state = NPC_QUIT;
    return -1;
}

static int cmd_si(char *args) {
    // default step count = 1
    int step_counter = 1;
    // step count string
    char *step_arg = strtok(NULL, " ");
    if (step_arg != NULL) {
        sscanf(step_arg, "%d", &step_counter);
    }
    cpu_exec(step_counter);
    return 0;
}

static int cmd_info(char *args) {
    char *info_arg = strtok(NULL, " ");
    if (info_arg != NULL) {
        if (strcmp(info_arg, "r") == 0) {
            isa_reg_display();
            return 0;
        }
        else if (strcmp(info_arg, "w") == 0) {
            watchpoint_display();
            return 0;
        }
    }
    printf("Please offer a valid info type: \"r\" or \"w\"\n");
    return 0;
}

static int cmd_x(char *args) {
    int scan_len = 1;                   // default scan len: 4 bytes
    vaddr_t base_addr = 0x80000000;     // default scan addr: 0x80000000
    vaddr_t addr;
    bool eval_success;
    // parse args, get scan_len & scan_addr
    char *scan_len_str = strtok(NULL, " ");
    char *base_addr_expr = strtok(NULL, " ");
    if ((scan_len_str != NULL) && (base_addr_expr != NULL)) {
        sscanf(scan_len_str, "%d", &scan_len);
        base_addr = expr(base_addr_expr, &eval_success);
        if (eval_success) {
            for (int i = 0; i < scan_len; i++) {
                addr = base_addr + i * 4;
                printf("mem[" FMT_WORD "] = " FMT_WORD "\n", addr, vaddr_read(addr, 4));
            }
        }
        else {
            printf("expr ERROR: wrong expression\n");
        }
    }
    else {
        printf("ERROR: [Usage] scan the memory: [x N expr]\n");
    }
    return 0;
}

static int cmd_p(char *args) {
    bool success = true;    // default: true
    // call expr() in monitor/sdb/expr.c
    if (args != NULL) {
        word_t result = expr(args, &success);
        if (success) {
            printf("%s = %d = " FMT_WORD "\n", args, result, result);
        }
        else {
            printf("expr ERROR: wrong expression\n");
        }
    }
    else {
        printf("ERROR: [Usage] Expression evaluation: [p EXPR]\n");
    }
    return 0;
}

static int cmd_w(char *args) {
    bool success = true;
    if (args != NULL) {
        WP* wp = new_wp(args, &success);
        if (success) {
            printf("watchpoint %d: %s\n", wp->NO, wp->WP_expr);
        }
        else {
            printf("failed to set watchpoint!!!!\n");
            // if expr() in new_wp() fails, free the wp allocated
            free_wp(wp->NO);
        }
    return 0;
    }
    printf("ERROR: [Usage] Set watchpoint: [w expr]\n");
    return 0;
}

static int cmd_d(char *args) {
    int num = 0;
    if (args != NULL) {
        // get num and free
        sscanf(args, "%d", &num);
        free_wp(num);
    }
    else {
        printf("ERROR: [Usage] Delete watchpoint by number: [d N]\n");
    }
  return 0;
}

static int cmd_help(char *args);

static struct {
    const char *name;
    const char *description;
    int (*handler) (char *);
    } cmd_table [] = {
        { "help", "Display information about all supported commands", cmd_help },
        { "c", "Continue the execution of the program", cmd_c },
        { "q", "Exit NEMU", cmd_q },

        /* TODO: Add more commands */
        { "si", "Single step execution: [si N]", cmd_si },
        { "info", "Print program status: [info r / info w]", cmd_info },
        { "x", "Scan the memory: [x N expr]", cmd_x },
        { "p", "Expression evaluation: [p EXPR]", cmd_p },
        { "w", "Set watchpoint: [w expr]", cmd_w },
        { "d", "Delete watchpoint by number: [d N]", cmd_d },

};

#define NR_CMD ARRLEN(cmd_table)

static int cmd_help(char *args) {
  /* extract the first argument */
  char *arg = strtok(NULL, " ");
  int i;

  if (arg == NULL) {
    /* no argument given */
    for (i = 0; i < NR_CMD; i ++) {
      printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
    }
  }
  else {
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(arg, cmd_table[i].name) == 0) {
        printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
        return 0;
      }
    }
    printf("Unknown command '%s'\n", arg);
  }
  return 0;
}


void sdb_mainloop() {
    if (CONFIG_BATCH_MODE) {
        cmd_c(NULL);
        return;
    }

    for (char *str; (str = rl_gets()) != NULL; ) {
        char *str_end = str + strlen(str);

        /* extract the first token as the command */
        char *cmd = strtok(str, " ");
        if (cmd == NULL) { continue; }

        /* treat the remaining string as the arguments,
        * which may need further parsing
        */
        char *args = cmd + strlen(cmd) + 1;
        if (args >= str_end) {
            args = NULL;
        }

        int i;
        for (i = 0; i < NR_CMD; i ++) {
        if (strcmp(cmd, cmd_table[i].name) == 0) {
            if (cmd_table[i].handler(args) < 0) { return; }
            break;
        }
        }

        if (i == NR_CMD) { printf("Unknown command '%s'\n", cmd); }
    }
}

void init_sdb() {
    /* Compile the regular expressions. */
    init_regex();

    /* Initialize the watchpoint pool. */
    init_wp_pool();
}

int is_exit_status_bad() {
    int good = (npc_state.state == NPC_END && npc_state.halt_ret == 0) ||
        (npc_state.state == NPC_QUIT);
    return !good;
}