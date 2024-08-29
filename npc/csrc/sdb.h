#ifndef __SDB_H__
#define __SDB_H__

#include "common.h"


// -------------------  watchpoint  ---------------------
// define WP type 
typedef struct watchpoint {
    int NO;
    struct watchpoint *next;

    /* TODO: Add more members if necessary */
    char WP_expr[64]; // the expression to watch
    word_t val;       // val = expr(WP_expr)

} WP;

// get a new watchpoints in free_ and return
WP* new_wp(char* WP_expr, bool *success);

// free a watchpoint in head by num
void free_wp(int num);

// display all of the wp
void watchpoint_display();

// check all the wp, return whether changed
int check_watchpoint();
// -------------------------------------------------------


// ------------------  itrace ringbuf  -------------------
#define IRINGBUF_SIZE 20
#define LOG_LEHGTH 128 // which is equal to s->logbuf

typedef struct {
    char data[IRINGBUF_SIZE][LOG_LEHGTH];
    int write_ptr;
} iRingBuffer;

void init_iringbuf();
void write_iringbuf(const char *log_buf);
void print_iringbuf();
// -------------------------------------------------------


// ------------------ ftrace elfstfunc -------------------
#include <elf.h>
#define ELF_ST_NAME_LEN 64
#define ELF_ST_FUNC_NUM 1024

typedef struct {
    char name[ELF_ST_FUNC_NUM][ELF_ST_NAME_LEN];
    word_t addr[ELF_ST_FUNC_NUM];
    word_t size[ELF_ST_FUNC_NUM];
    word_t valid_func;
} elfStFunc;

void init_ftrace_stfunc(const char *elf_file);
void display_elfstfunc(); // for debug
void ftrace_call(word_t curr_addr, word_t j_addr, int depth);
void ftrace_retn(word_t curr_addr, int depth);
// -------------------------------------------------------


word_t expr(char *e, bool *success);

void init_wp_pool();
void init_regex();
void init_sdb();

void sdb_mainloop();

int is_exit_status_bad();

#endif