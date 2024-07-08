#include <stdio.h>

int main(int argc, char *argv[])
{
    int distance = 100;
    float power = 2.345f;
    double super_power = 56789.4532;
    char initial = 'A';
    char first_name[] = "Zed";
    char last_name[] = "Shaw";

    printf("You are %5d miles away.\n", distance);
    printf("You have %.2f levels of power.\n", power);

    printf("You are %o(oct) miles away.\n", distance);
    printf("You are %x(hex) miles away.\n", distance);

    char empty_str[] = "";
    printf("This is an empty string:%s \n",empty_str);
    printf("Empty string has %ld bytes\n",sizeof(empty_str));
    return 0;
}