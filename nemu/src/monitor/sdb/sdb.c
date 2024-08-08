/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <isa.h>
#include <cpu/cpu.h>
#include <readline/readline.h>
#include <readline/history.h>
#include "sdb.h"
#include <memory/vaddr.h>

static int is_batch_mode = false;

void init_regex();
void init_wp_pool();

/* We use the `readline' library to provide more flexibility to read from stdin. */
static char* rl_gets() {
  static char *line_read = NULL;

  if (line_read) {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(nemu) ");

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
    nemu_state.state = NEMU_QUIT;
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
    }
    printf("Please offer a valid info type: \"r\" or \"w\"\n");
    return 0;
}

static int cmd_x(char *args) {
    int scan_len = 1;                   // default scan len: 4 bytes
    vaddr_t base_addr = 0x80000000;     // default scan addr: 0x80000000
    vaddr_t addr;
    // parse args, get scan_len & scan_addr
    char *scan_len_str = strtok(NULL, " ");
    char *base_addr_str = strtok(NULL, " ");
    if ((scan_len_str != NULL) && (base_addr_str != NULL)) {
        sscanf(scan_len_str, "%d", &scan_len);
        sscanf(base_addr_str, "%x", &base_addr);
        for (int i = 0; i < scan_len; i++) {
            addr = base_addr + i * 4;
            printf("mem[" FMT_WORD "] = " FMT_WORD "\n", addr, vaddr_read(addr, 4));
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

void sdb_set_batch_mode() {
  is_batch_mode = true;
}

void sdb_mainloop() {
  if (is_batch_mode) {
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

#ifdef CONFIG_DEVICE
    extern void sdl_clear_event_queue();
    sdl_clear_event_queue();
#endif

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

// run this debug: $ make run > tools/gen-expr/result
void sdb_debug_expr() {
    FILE *fp;
    char *line = NULL;
    size_t len = 0;
    ssize_t read;
    char *result_str = NULL;
    word_t result_ref = 0;
    char *args = NULL;

    // open the file 
    fp = fopen("./tools/gen-expr/input", "r");
    if (fp == NULL)
        exit(EXIT_FAILURE);

    while ((read = getline(&line, &len, fp)) != -1) {
        // printf("retrieved line of length %zu:\n", read);
        // printf("%s", line);

        // get the standard result to compare with
        result_str = strtok(line, " ");
        sscanf(result_str, "%u", &result_ref);
        // get the expression
        args = strtok(NULL, "\n");
        Log("expr: %s", args);
        // expression evaluation
        bool success = true;
        word_t result = expr(args, &success);
        // output the result
        if (success) {
            if (result_ref == result) {
                Log(" = %u(ref result) = %u(my nemu result), ", result_ref, result);
                Log("PASS!\n");
            }
            else {
                Log(" = %u(ref result) != %u(my nemu result), ", result_ref, result);
                exit(EXIT_FAILURE);
            }
        }
        else {
            Log("Invalid expression!\n");
        }
    }
    // close the file 
    fclose(fp);
    if (line)
        free(line);
    exit(EXIT_SUCCESS);
}

void init_sdb() {
  /* Compile the regular expressions. */
  init_regex();

  /* Initialize the watchpoint pool. */
  init_wp_pool();
}
