#ifndef SYMBOLS_H
#define SYMBOLS_H
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

typedef enum { INT_ARG, STRING_ARG, CHAR_ARG, FLOAT_ARG, LOGIC_ARG, PROCEDURE_T } ARG_T;

typedef struct {
    ARG_T arg_type;
    int line;
    char* arg_name;
} symbol_t;

typedef struct symbol_table {
    symbol_t* symbol;
    struct symbol_table* next;
} symbol_table_t;

symbol_table_t* createSymbolTable();
symbol_table_t* copySymbolTable(symbol_table_t* table);
symbol_t* createSymbol(ARG_T type, char* name, int line);
symbol_table_t* getNext(symbol_table_t* table);
void addSymbol(symbol_table_t* table, symbol_t* symbol);
void removeSymbol(symbol_table_t* table, char* name);
symbol_t* getSymbol(symbol_table_t* table, char* name);
void removeSymbolTable(symbol_table_t* table);

#endif