#include <am.h>
#include <klib-macros.h>
#include <klib.h>

int main(const char *args) {
    const char *fmt =
        "Hello, AbstractMachine!\n"
        "mainargs = '%'.\n";
    printf("%s",fmt);
    return 0;
}
