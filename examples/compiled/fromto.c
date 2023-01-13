#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int main(int argc, char *argv[]) {
    for (int i = 1; i < 10; i++) {
        printf("%d\n", i);
        int var;
    }
    /* Should warn that i is not defined */
    printf("%d\n", i);
    printf("%d\n", var);
    int x;
    for ( x = 1; x < 10; x++) {
        printf("%d\n", x);
    }
    /* Should be ok */
    printf("%d\n", x);

    return 0;
}
