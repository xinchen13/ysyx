#include <am.h>
#include <riscv/riscv.h>
#include <klib.h>

static Context* (*user_handler)(Event, Context*) = NULL;

Context* __am_irq_handle(Context *c) {
  if (user_handler) {
    Event ev = {0};
    switch (c->mcause) {
        case (-1): 
            ev.event = EVENT_YIELD;
            c->mepc = c->mepc + 4;
            break;
        default: ev.event = EVENT_ERROR; break;
    }

    c = user_handler(ev, c);
    assert(c != NULL);
  }

  return c;
}

extern void __am_asm_trap(void);

bool cte_init(Context*(*handler)(Event, Context*)) {
  // initialize exception entry
  asm volatile("csrw mtvec, %0" : : "r"(__am_asm_trap));

  // register event handler
  user_handler = handler;

  return true;
}

Context *kcontext(Area kstack, void (*entry)(void *), void *arg) {
    Context *new_c = kstack.end - sizeof(Context);
    new_c->mepc = (uintptr_t)entry;
    new_c->mstatus = 0x1800;  // for difftest
    #ifdef __riscv_e
        // a0 - a5
        for (int i = 10; i <= 15; i++) {
            new_c->gpr[i] = (uintptr_t)(arg+i-10);
        }
    #else
        // a0 - a7
        for (int i = 10; i <= 17; i++) {
            new_c->gpr[i] = (uintptr_t)(arg+i-10);
        }
    #endif
    return new_c;
}

void yield() {
#ifdef __riscv_e
  asm volatile("li a5, -1; ecall");
#else
  asm volatile("li a7, -1; ecall");
#endif
}

bool ienabled() {
  return false;
}

void iset(bool enable) {
}
