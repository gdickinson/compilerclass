#include <string.h>
#include <stdio.h>
#include "symtab.h"

/*
  Functions to manipulate a symbol table, and to print it out at the end.
  Guy Dickinson <guy.dickinson@nyu.edu>
 */

symbol* lookup(char* id, symbol* st) {
    // This isn't very efficient, but since all our tests are small it doesn't
    // matter very much. In essence we just do a linear search of all the symbols
    // in the array until we find one whose name matches the given lexeme, or
    // we get to an empty cell. Worst case runtime is O(n) but since n is maximally
    // 200, meh.
    int i;
    for (i = 0; i < MAX_SYMBOLS; i++) {
        if (!st[i].name) {
            st[i].name = strdup(id);
            return &st[i];
        }
        if (st[i].name && !strcmp(st[i].name, id)) {
            return &st[i];
        }
    }
}

void print_table(symbol* st) {
    printf("\nSymbol Table:\n%-20s%-25s\n","Name", "Type");
    int i;
    for (i = 0; i < MAX_SYMBOLS; i++) {
        if (!st[i].name) {
            break;
        }
        printf("%-20s%-25s\n", st[i].name, st[i].type);
    }
}
