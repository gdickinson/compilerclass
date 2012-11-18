#include "linkedlist.h"

/*
  Symbol Table Manipulation
*/

#ifndef SYMTAB_H
#define SYMTAB_H

typedef struct symbol {
    char* name;
    char* type;
} symbol;

typedef struct scope {
    struct scope* parent;
    node* symbol_list;
} scope;

// Returns a pointer to an entry in the table if it exists,
// adds a new one if it doesn't.
symbol* lookup(char* id, scope* scope);

int find_symbol(void* testsymbol, void* targetname);

void add_symbol_to_scope(scope* s, symbol* symbol);

scope* create_scope(scope* parent);

symbol* create_symbol(char* name);

symbol* create_symbol_with_type(char* name, char* type);

#endif
