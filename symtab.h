#include "linkedlist.h"

/*
  Symbol Table Manipulation
*/

#ifndef SYMTAB_H
#define SYMTAB_H

// Symbols contain two strings (a name and a type)
typedef struct symbol {
    char* name;
    struct symbol* type;
    char* label;
} symbol;

// Scopes contain a pointer to their parent (for efficient upward searching),
// a list of child scopes (for debugging only),
// and a list of symbols within that scope
typedef struct scope {
    struct scope* parent;
    node* children;
    node* symbol_list;
} scope;

// Returns a pointer to an entry in the table if it exists,
// adds a new one if it doesn't.
symbol* lookup(char* id, scope* scope);

int find_symbol(void* testsymbol, void* targetname);

void add_symbol_to_scope(scope* s, symbol* symbol);

// Allocates a partially-hydrated scope; at create time the linked-list of symbols is null.
scope* create_scope(scope* parent);

symbol* create_symbol(char* name);

// Convenience method which adds a fully-hydrated symbol to a scope, useful for manipulating
// the root scope before compilation begins.
symbol* create_symbol_with_type(char* name, symbol* type);

void print_symbol_table(void* rootscope);

// Dumbish typechecking. Checks to see if type2 resolves to type1 by walking up the scopes.
int typecheck(symbol* type1, symbol* type2, scope* s);

// Root types point to themselves
symbol* create_root_type(char* name);

#endif
