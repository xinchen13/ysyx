#include <stdio.h>
#include <ctype.h>
#include <string.h>

// forward declarations
void print_letters(char arg[], int len);

void print_arguments(int argc, char *argv[])
{
    int i = 0;

    for(i = 0; i < argc; i++) {
        int len = strlen(argv[i]);
        print_letters(argv[i], len);
    }
}

void print_letters(char arg[], int len)
{
    int i = 0;

    for(i = 0; i < len; i++) {
        char ch = arg[i];
        if(isalpha(ch) || isblank(ch)) {
            printf("'%c' == %d ", ch, ch);
        }
    }

    printf("\n");
}

int main(int argc, char *argv[])
{
    print_arguments(argc, argv);
    return 0;
}