#include <stdio.h>

void print_info_first(int cnt, int *ages, char *names[]);
void print_info_second(int cnt, int *ages, char *names[]);
void print_info_third(int cnt, int *ages, char *names[]);
void print_info_forth(int cnt, int *ages, char *names[], int *cur_age, char *cur_name[]);


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

    // first way using indexing
    print_info_first(count, ages, names);
    printf("---\n");

    // setup the pointers to the start of the arrays
    int *cur_age = ages;
    char **cur_name = names;

    // second way using pointers
    print_info_second(count, cur_age, cur_name);
    printf("---\n");

    // third way, pointers are just arrays
    print_info_third(count, cur_age, cur_name);
    printf("---\n");

    // fourth way with pointers in a stupid complex way
    print_info_forth(count, ages, names, cur_age, cur_name);
    return 0;
}

void print_info_first(int cnt, int *ages, char *names[]){
    int i = 0;
    for(i; i < cnt; i++){
        printf("%s has %d years alive.\n", names[i], ages[i]);
    }
}

void print_info_second(int cnt, int *ages, char *names[]){
    int i = 0;
    for(i; i < cnt; i++){
        printf("%s has %d years alive.\n", *(names+i), *(ages+i));
    }
}

void print_info_third(int cnt, int *ages, char *names[]){
    int i = 0;
    for(i; i < cnt; i++){
        printf("%s has %d years alive.\n", names[i], ages[i]);
    }
}

void print_info_forth(int cnt, int *ages, char *names[], int *cur_age, char *cur_name[]){
    for(cur_name = names, cur_age = ages;
            (cur_age - ages) < cnt;
            cur_name++, cur_age++)
    {
        printf("%s lived %d years so far.\n",
                *cur_name, *cur_age);
    }
}