#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int main(int argc, char *argv[]) {
    int VAR1;
    VAR1 = 0;
    while (VAR1 < 10) {
        VAR1 = VAR1 + 1;
        printf("%d\n", VAR1);
    }
    do {
        VAR1 = VAR1 + 1;
        printf("%d\n", VAR1);
    } while (VAR1 < 10);

    return 0;
}
