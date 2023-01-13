#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int main(int argc, char *argv[]) {
    int v;
    v = 1;
    switch (v) {
        case 1: {
            v = v + 1;
            v = v + 1;
            printf("%d\n", v);
            break;
        } 
        case 2: {
            v = v * 2;
            break;
        } 
        default: {
            v = 5;
            break;
        }
    }
    printf("%d\n", v);

    return 0;
}
