#include <stdio.h>

int main(int argc, char *argv[])
{
        int numbers[4] = {0};
        char name[4] = {'a'};

        numbers[0] = 'A';
        numbers[1] = 'B';
        numbers[2] = 'f';
        numbers[3] = 'z';
        printf("numbers: %d %c %d %c\n",numbers[0], numbers[1],numbers[2], numbers[3]);

        name[0] = 1;
        name[1] = 50;
        name[2] = 190;
        name[3] = 1000;
        printf("name each: %d %d %d %d\n",name[0], name[1],name[2], name[3]);
        printf("name: %s\n", name);

        char *name_p = name;
        printf("name_p: %s\n", name_p);

    return 0;
}