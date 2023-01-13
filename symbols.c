#include "symbols.h"

void printSymbolsTable(symbol_table_t* table) {
    symbol_table_t* current = table;
    while (current != NULL) {
        printf("Symbol: %s\n", current->symbol->arg_name);
        current = current->next;
    }
    printf("--------\n");
}   

symbol_table_t* createSymbolTable() {
    symbol_table_t* table = malloc(sizeof(symbol_table_t));
    table->symbol = NULL;
    table->next = NULL;
    return table;
}

symbol_table_t* copySymbolTable(symbol_table_t* table) {
    symbol_table_t* new_table = createSymbolTable();
    symbol_table_t* current = table;
    while (current != NULL) {
        addSymbol(new_table, current->symbol);
        current = current->next;
    }
    return new_table;
}

symbol_t* createSymbol(ARG_T type, char* name, int line) {
    symbol_t* symbol = malloc(sizeof(symbol_t) + 30);
    symbol->arg_type = type;
    symbol->arg_name = name;
    symbol->line = line;
    return symbol;
}

void addSymbol(symbol_table_t* table, symbol_t* symbol) {
    while (table->next != NULL) {
        table = table->next;
    }
    if (table->symbol == NULL) {
        table->symbol = symbol;
        return;
    }
    table->next = malloc(sizeof(symbol_table_t));
    table->next->symbol = symbol;
    table->next->next = NULL;
}

symbol_t* getSymbol(symbol_table_t* table, char* name) {
    if (table == NULL || table->symbol == NULL) {
        return NULL;
    }

    while (table->next != NULL) {
        if (strcmp(table->symbol->arg_name, name) == 0) {
            return table->symbol;
        }
        table = table->next;
    }
    if (strcmp(table->symbol->arg_name, name) == 0) {
        return table->symbol;
    }
    return NULL;
}

void removeSymbol(symbol_table_t* table, char* name) {
    // Check if the symbol table is empty
    if (table == NULL) {
        return;
    }

    symbol_table_t* prev = NULL;
    symbol_table_t* tmp = NULL;
    symbol_table_t* curr = table;
    symbol_table_t* lastMatched = NULL;

    // Iterate through the symbol table
    while (curr != NULL) {
        // Check if the current element has the matching name
        if (strcmp(curr->symbol->arg_name, name) == 0) {
            // Save a reference to the last matched element
            lastMatched = curr;
            prev = tmp;
        }
        tmp = curr;
        curr = curr->next;
    }

    // Remove the last matched element
    if (lastMatched != NULL) {
        if (lastMatched->next == NULL) {
            prev->next = NULL;
        } else {
            lastMatched->symbol = lastMatched->next->symbol;
            tmp = lastMatched->next;
            lastMatched->next = lastMatched->next->next;
            free(tmp);
       }
    }
}


void removeSymbolTable(symbol_table_t* table) {
    symbol_table_t* curr = table;
    symbol_table_t* next;

    while (curr != NULL) {
        next = curr->next;
        free(curr);
        curr = next;
    }
}
