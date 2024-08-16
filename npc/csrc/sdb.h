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


word_t expr(char *e, bool *success);

void init_wp_pool();
void init_regex();
void init_sdb();

void sdb_mainloop();

int is_exit_status_bad();

#endif