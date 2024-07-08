#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[])
{
    char *states[] = {
        "California", "Oregon",
        "Washington", "Texas"
    };
    int num_states = 4;

    // reverse
    int k = argc - 1;
    while(k >= 0){
        printf("arg %d: %s\n", k, argv[k]);
        k--;
    }
    
    // copy
    int m = 0;
    while (m < argc && m < num_states){
        states[m] = argv[m];
        m++;
    }
    int i = 0;  // watch for this
    while(i < num_states) {
        printf("state %d: %s\n", i, states[i]);
        i++;
    }

    printf("addr of argv = %ld\n", argv[1]);
    printf("addr of states = %ld\n", states[1]);

    return 0;
}