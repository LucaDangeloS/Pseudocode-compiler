#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>


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
int fibonacciR (int n) {
        if (n == 0) {
                return 0;
            
        } else {
            if (n == 1) {
                    return 1;
                
            } else {
                    return fibonacciR( n - 1) + fibonacciR( n - 2);
                
            }
        }
        /* This will never be reached, theoretically. But it needs a return statement */
        return -1;
    }
int add (int x, int y) {
        return x + y;
    }
int modulus (int x, int y) {
        return x % y;
    }
int multiply (int x, int y) {
        return x * y;
    }
void get_numbers (int* num1, int* num2) {
    printf("Enter first number:\n");
    scanf("%d", num1);
    *num2 = 7;
    printf("Enter second number:\n");
    scanf("%d", num2);

    return;
}
int main(int argc, char *argv[]) {
    int num1;
    int num2;
    char selection;
    while (selection != 'e') {
        printf("Menu:\n");
        printf("a. Add two numbers\n");
        printf("m. Get the modulus of two numbers\n");
        printf("r. Get the sum of the first n fibonacci numbers recursively\n");
        printf("i. Get the sum of the first n fibonacci numbers iteratively\n");
        printf("e. Exit\n");
        scanf(" %c", &selection);
        switch (selection) {
            case 'a': {
                get_numbers( &num1, &num2);
                printf("Result: \n");
                printf("%d\n", add( num1, num2));
                break;
            } 
            case 'm': {
                get_numbers( &num1, &num2);
                printf("Result: \n");
                printf("%d\n", multiply( num1, num2));
                break;
            } 
            case 'i': {
                printf("Enter a number:\n");
                scanf("%d", &num1);
                printf("The sum of the first \n");
                printf("%d\n", num1);
                printf(" fibonacci numbers is \n");
                printf("%d\n", fibonacciI( num1));
                break;
            } 
            case 'r': {
                printf("Enter a number:\n");
                scanf("%d", &num1);
                printf("The sum of the first \n");
                printf("%d\n", num1);
                printf(" fibonacci numbers is \n");
                printf("%d\n", fibonacciR( num1));
                break;
            } 
            case 'e': {
                printf("Bye!\n");
                break;
            } 
            default: {
                printf("Invalid selection\n");
                break;
            }
        }
    }

    return 0;
}
