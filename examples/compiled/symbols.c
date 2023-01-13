#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int main(int argc, char *argv[]) {
    int x;
    int y;
    int z;
    char* str1;
    char* str2;
    x = 1;
    y = 2;
    z = x + y;
    z = pow(((x + 1) * y), z);
    strcpy(str1, "Hello");
    strcpy(str2, "World");
    /* This is surely gonna crash... */
    strcpy(z, "again?");
    /* Test for auto declaration of variables */
    int auto_var;
    auto_var = 1;
    char* auto_var_2 = malloc(strlen("Hello World") + 1);
    strcpy(auto_var_2, "Hello World");
    float auto_var_3;
    auto_var_3 = 3.141500;
    int auto_var_4;
    auto_var_4 = 1;
    char auto_var_5;
    auto_var_5 = 'c';
    char* auto_var_6;
    auto_var_6 = auto_var_2;
    int auto_var_7;
    auto_var_7 = auto_var;
    float auto_var_8;
    auto_var_8 = auto_var_3;
    printf("%d\n", z);

    return 0;
}
