#include <stdio.h>

int main(int argc, char *argv[])
{
    // create two arrays we care about
    int ages[] = {23, 43, 12, 89, 2};
    char *names[] = {
        "Alan", "Frank",
        "Mary", "John", "Lisa"
    };

    // safely get the size of ages
    int count = sizeof(ages) / sizeof(int);
    int i = 0;

    int *cur_age = ages;
    char **cur_name = names;

    // second way using pointers
    for(i = 0; i < count; i++) {
        printf("%s is %d years old.\n",
                *(cur_name+i), *(cur_age+i));
        printf("cur_name+i is at %p, cur_age+i is at %p\n",
                (cur_name+i), (cur_age+i));
    }

    printf("%p is the address of cur_name now\n",cur_name);
    printf("%p is the address of cur_age now\n",cur_age);

    return 0;
}