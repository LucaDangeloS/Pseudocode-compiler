#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int main(int argc, char *argv[]) {
    printf("test string\n");
    printf("9");
    printf("9.000000");
    printf("TRUE");
    printf("FALSE");
    printf("1");
    printf("2");
    printf("3");
    printf("4");
    int symbol;
    scanf("%d", &symbol);
    char* another_symbol;
    strcpy(another_symbol, "test string");
    scanf("%s", &another_symbol);
    char* SYM2;
    scanf("%s", &SYM2);
    printf("%d\n", symbol);
    printf("%s\n", another_symbol);
    printf("%s\n", SYM2);

    return 0;
}
