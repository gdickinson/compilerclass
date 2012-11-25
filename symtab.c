#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "symtab.h"

/*
  Functions to manipulate a symbol table, and to print it out at the end.
  Guy Dickinson <guy.dickinson@nyu.edu>
 */


// Predicate function to find a symbol in a linkedlist of symbols
int find_symbol(void* testsymbol, void* targetname) {
    symbol* s1 = (symbol*) testsymbol;
    char* id1 = s1->name;
    return (strcmp(id1, targetname));
}

symbol* lookup(char* id, scope* s) {
    scope* leaf = s;

    // Starting at the given scope, walk up the tree until we find a symbol.
    // If no symbol is found, we add a new symbol to the current scope and return it
    while(s != NULL) {
        node* n = list_search(s->symbol_list, find_symbol, id);
        if (n != NULL) {
            return n->data;
        }
        s = s->parent;
    }
    // If we got here, then we didn't find a symbol anywhere, so we'll add it in the given
    // scope.
    symbol* sym = create_symbol(id);
    add_symbol_to_scope(leaf, sym);
    return sym;
}

void add_symbol_to_scope(scope* s, symbol* symbol) {
    if (s == NULL) {
        return;
    }
    if (!s->symbol_list) {
        s->symbol_list = list_create(symbol);
    } else {
        list_append(s->symbol_list, symbol);
    }
}

// NOTE the resulting scope has no symbol list at this point.
scope* create_scope(scope* parent) {
    scope* s;
    if (! (s = malloc(sizeof(scope)))) {
        return NULL;
    }

    s->parent = parent;
    if (! parent) {
        return s;
    }

    if (parent->children == NULL) {
        parent->children = list_create(s);
    } else {
        list_append(parent->children, s);
    }
    s->children = NULL;
    return s;
}

symbol* create_symbol(char* name) {
    symbol *m;
    if (! (m = malloc(sizeof(symbol)))) {
        return NULL;
    }
    m->name = strdup(name);
    return m;
}

symbol* create_symbol_with_type(char* name, char* type) {
    symbol* m = create_symbol(name);
    m->type = type;
    return m;
}

void print_symbol(void* sym) {
    symbol* s = (symbol*) sym;
    printf("%s: %s\n", s->name, s->type);
}

void print_symbol_table(void* rootscope) {
    scope* castedscope = (scope*) rootscope;
    printf("Printing scope at %p (parent = %p):\n", castedscope, castedscope->parent);
    list_foreach(castedscope->symbol_list, print_symbol);
    printf("\n");
    list_foreach(castedscope->children, print_symbol_table);
}

int typecheck(char* type1, char* type2, scope* s) {
    // Total hack to allow for return values. This is dreadful and I am ashamed.
    if (strcmp (type1, "FUNCTION") == 0) {
        return 0;
    }
    symbol* sym = lookup(type1, s);
    if (sym) {
        return strcmp(sym->type, type2);
    }
    else { return -1; }
}
