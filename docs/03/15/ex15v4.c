#include <stdio.h>

int main(int agrc, char* argv[]){
    char **ptr = argv;
    int i = 0;
    while(i < agrc){
        printf("argv[%d] = %s\n", i, *ptr);
        ptr++;
        i++;
    }
    return 0;
}