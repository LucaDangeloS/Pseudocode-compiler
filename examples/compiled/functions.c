#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>


int foo (int xf1) {
        if (xf1 > 10) {
            printf("test\n");
            /* It needs to have this spacing in the '-' */
                return foo( xf1 - 1);
            
        } else {
            printf("cono\n");
                return 0;
            
        }
        return 0;
    }
void bar (char** xf2) {
    strcpy(xf2, "hello");
    printf("%s\n", xf2);

    return;
}
int fibonacciI (int n) {
        int current;
        int next;
        current = 0;
        next = 1;
        for (int i = 0; i < n; i++) {
            int temp;
            temp = current + next;
            current = next;
            next = temp;
        }
        return current;
    }
int main(int argc, char *argv[]) {
    printf("10");

    return 0;
}
