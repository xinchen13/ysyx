#ifndef __COMMON_H__
#define __COMMON_H__

// ---------------------------- configs -----------------------------
#define CONFIG_MBASE 0x30000000u
#define CONFIG_MSIZE 0xffffffu
#define CONFIG_PSRAM_BASE 0x80000000u
#define CONFIG_PSRAM_SIZE 0x00ffffffu   // 16MiB
#define CONFIG_BATCH_MODE 1
#define CONFIG_RVE 1
#define CONFIG_XIP_FLASH 1
// #define CONFIG_WATCHPOINT 1
#define CONFIG_ITRACE 1
#define CONFIG_FTRACE 1
// #define CONFIG_MTRACE 1
// #define CONFIG_DIFFTEST 1

#if defined(CONFIG_ITRACE) || defined(CONFIG_FTRACE) || defined(CONFIG_MTRACE)
    #define CONFIG_TRACE 1
#endif
// ------------------------------------------------------------------


// ----------------------------- header -----------------------------
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <assert.h>
#include <regex.h>
#include <getopt.h>
#include <dlfcn.h>
#include <time.h>
#include <readline/readline.h>
#include <readline/history.h>
#include "VysyxSoCFull.h"
#include "verilated.h"
#include "verilated_vcd_c.h" // for wave gen
#include "VysyxSoCFull__Dpi.h"
#include "VysyxSoCFull___024root.h"
#include "svdpi.h"
// ------------------------------------------------------------------


// ----------------------------- macros -----------------------------
#define PG_ALIGN __attribute((aligned(4096)))
// strlen() for string constant
#define STRLEN(CONST_STR) (sizeof(CONST_STR) - 1)

// calculate the length of an array
#define ARRLEN(arr) (int)(sizeof(arr) / sizeof(arr[0]))

// macro concatenation
#define concat_temp(x, y) x ## y
#define concat(x, y) concat_temp(x, y)
#define concat3(x, y, z) concat(concat(x, y), z)
#define concat4(x, y, z, w) concat3(concat(x, y), z, w)
#define concat5(x, y, z, v, w) concat4(concat(x, y), z, v, w)

#define CHOOSE2nd(a, b, ...) b
#define MUX_WITH_COMMA(contain_comma, a, b) CHOOSE2nd(contain_comma a, b)
#define MUX_MACRO_PROPERTY(p, macro, a, b) MUX_WITH_COMMA(concat(p, macro), a, b)
// define placeholders for some property
#define __P_DEF_0  X,
#define __P_DEF_1  X,
#define __P_ONE_1  X,
#define __P_ZERO_0 X,
// define some selection functions based on the properties of BOOLEAN macro
#define MUXDEF(macro, X, Y)  MUX_MACRO_PROPERTY(__P_DEF_, macro, X, Y)
#define MUXNDEF(macro, X, Y) MUX_MACRO_PROPERTY(__P_DEF_, macro, Y, X)
#define MUXONE(macro, X, Y)  MUX_MACRO_PROPERTY(__P_ONE_, macro, X, Y)
#define MUXZERO(macro, X, Y) MUX_MACRO_PROPERTY(__P_ZERO_,macro, X, Y)

// test if a boolean macro is defined
#define ISDEF(macro) MUXDEF(macro, 1, 0)
// test if a boolean macro is undefined
#define ISNDEF(macro) MUXNDEF(macro, 1, 0)
// test if a boolean macro is defined to 1
#define ISONE(macro) MUXONE(macro, 1, 0)
// test if a boolean macro is defined to 0
#define ISZERO(macro) MUXZERO(macro, 1, 0)
// test if a macro of ANY type is defined
// NOTE1: it ONLY works inside a function, since it calls `strcmp()`
// NOTE2: macros defined to themselves (#define A A) will get wrong results
#define isdef(macro) (strcmp("" #macro, "" str(macro)) != 0)

// simplification for conditional compilation
#define __IGNORE(...)
#define __KEEP(...) __VA_ARGS__
// keep the code if a boolean macro is defined
#define IFDEF(macro, ...) MUXDEF(macro, __KEEP, __IGNORE)(__VA_ARGS__)
// keep the code if a boolean macro is undefined
#define IFNDEF(macro, ...) MUXNDEF(macro, __KEEP, __IGNORE)(__VA_ARGS__)
// keep the code if a boolean macro is defined to 1
#define IFONE(macro, ...) MUXONE(macro, __KEEP, __IGNORE)(__VA_ARGS__)
// keep the code if a boolean macro is defined to 0
#define IFZERO(macro, ...) MUXZERO(macro, __KEEP, __IGNORE)(__VA_ARGS__)

#define likely(cond)   __builtin_expect(cond, 1)
#define unlikely(cond) __builtin_expect(cond, 0)
// ------------------------------------------------------------------


// --------------------------- data types ---------------------------
typedef uint32_t word_t;
typedef int32_t sword_t;
#define FMT_WORD "0x%08" PRIx32

typedef word_t vaddr_t;
typedef uint32_t paddr_t;
#define FMT_PADDR "0x%08" PRIx32
// ------------------------------------------------------------------


// ----------------------------- log --------------------------------
#define ANSI_FG_BLACK   "\33[1;30m"
#define ANSI_FG_RED     "\33[1;31m"
#define ANSI_FG_GREEN   "\33[1;32m"
#define ANSI_FG_YELLOW  "\33[1;33m"
#define ANSI_FG_BLUE    "\33[1;34m"
#define ANSI_FG_MAGENTA "\33[1;35m"
#define ANSI_FG_CYAN    "\33[1;36m"
#define ANSI_FG_WHITE   "\33[1;37m"
#define ANSI_BG_BLACK   "\33[1;40m"
#define ANSI_BG_RED     "\33[1;41m"
#define ANSI_BG_GREEN   "\33[1;42m"
#define ANSI_BG_YELLOW  "\33[1;43m"
#define ANSI_BG_BLUE    "\33[1;44m"
#define ANSI_BG_MAGENTA "\33[1;35m"
#define ANSI_BG_CYAN    "\33[1;46m"
#define ANSI_BG_WHITE   "\33[1;47m"
#define ANSI_NONE       "\33[0m"

#define ANSI_FMT(str, fmt) fmt str ANSI_NONE

#define log_write(...)  \
    do { \
        extern FILE* log_fp; \
        fprintf(log_fp, __VA_ARGS__); \
        fflush(log_fp); \
    } while (0)


#define _Log(...) \
    do { \
        printf(__VA_ARGS__); \
        log_write(__VA_ARGS__); \
    } while (0)

#define Log(format, ...) \
    _Log(ANSI_FMT("[%s:%d %s] " format, ANSI_FG_BLUE) "\n", \
        __FILE__, __LINE__, __func__, ## __VA_ARGS__)

#define Assert(cond, format, ...) \
    do { \
        if (!(cond)) { \
            fflush(stdout), fprintf(stderr, ANSI_FMT(format, ANSI_FG_RED) "\n", ##  __VA_ARGS__); \
            extern FILE* log_fp; fflush(log_fp); \
            assert(cond); \
        } \
    } while (0)

#define panic(format, ...) Assert(0, format, ## __VA_ARGS__)

#define TODO() panic("please implement me")
// ------------------------------------------------------------------

void init_monitor(int argc, char *argv[]);

// ----------------------------- npc state --------------------------
enum { NPC_RUNNING, NPC_STOP, NPC_END, NPC_ABORT, NPC_QUIT };

typedef struct {
    int state;
    vaddr_t halt_pc;
    uint32_t halt_ret;
} npcState;
// ------------------------------------------------------------------


// ---------------------------- monitor regs ------------------------
typedef struct {
    word_t gpr[MUXDEF(CONFIG_RVE, 16, 32)];
    vaddr_t pc;
    word_t mstatus;
    word_t mtvec;
    word_t mepc;
    word_t mcause;
} coreState;
// ------------------------------------------------------------------

#endif