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
    printf("Called find_symbol\n");
    symbol* s1 = (symbol*) testsymbol;
    char* id1 = s1->name;
    return (strcmp(id1, targetname));
}

symbol* lookup(char* id, scope* s) {

    scope* leaf = s;

    printf("called lookup\n");
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
    printf("id %s not found in symtab, creating new symbol\n", id);
    symbol* sym = create_symbol(id);
    add_symbol_to_scope(leaf, sym);
    return sym;
}

void add_symbol_to_scope(scope* s, symbol* symbol) {
    printf("Called add_symbol_to_scope\n");
    if (!s->symbol_list) {
        printf("Creating new linkedlist\n");
        s->symbol_list = list_create(symbol);
    } else {
        printf("Appending symbol to existing ll\n");
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
    return s;
}

symbol* create_symbol(char* name) {
    printf("called create_symbol for name %s\n", name);
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

/* int main(int argc, char** argv) { */
/*     symbol* m0 = create_symbol("a"); */
/*     symbol* m1 = create_symbol("b"); */
/*     symbol* m2 = create_symbol("c"); */

/*     scope* s0 = create_scope(NULL); */
/*     scope* s1 = create_scope(s0); */
/*     scope* s2 = create_scope(s0); */
/*     scope* s3 = create_scope(s2); */

/*     add_symbol_to_scope(s0, m0); */
/*     add_symbol_to_scope(s0, m1); */
/*     add_symbol_to_scope(s1, m0); */

/*     symbol* f0 = lookup("q", s3); */
/*     if (f0) { */
/*         printf("Found symbol %s\n", f0->name); */
/*     } else { */
/*         printf("Symbol not found\n"); */
/*     } */

/* } */
