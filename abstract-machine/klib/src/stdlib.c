#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)
static unsigned long int next = 1;

int rand(void) {
  // RAND_MAX assumed to be 32767
  next = next * 1103515245 + 12345;
  return (unsigned int)(next/65536) % 32768;
}

void srand(unsigned int seed) {
  next = seed;
}

int abs(int x) {
  return (x < 0 ? -x : x);
}

int atoi(const char* nptr) {
  int x = 0;
  while (*nptr == ' ') { nptr ++; }
  while (*nptr >= '0' && *nptr <= '9') {
    x = x * 10 + *nptr - '0';
    nptr ++;
  }
  return x;
}

static int cnt = 0;     // malloc counter
static char *addr;      // address
void *malloc(size_t size) {
    // On native, malloc() will be called during initializaion of C runtime.
    // Therefore do not call panic() here, else it will yield a dead recursion:
    //   panic() -> putchar() -> (glibc) -> malloc() -> panic()
    #if !(defined(__ISA_NATIVE__) && defined(__NATIVE_USE_KLIB__))
        // panic("Not implemented");
        if (cnt == 0) {
            addr = (void *)ROUNDUP(heap.start, 8);
            cnt++;  
        }
        size  = (size_t)ROUNDUP(size, 8);
        char *old = addr;
        addr += size;
        // check if address is valid
        assert((uintptr_t)heap.start <= (uintptr_t)addr && (uintptr_t)addr < (uintptr_t)heap.end);
        // initialize
        for (uint64_t *p = (uint64_t *)old; p != (uint64_t *)addr; p ++) {
            *p = 0;
        }
        return old;
    #endif
    return NULL;
}

void free(void *ptr) {

}

#endif
