/*
  Symbol Table Manipulation
*/

#ifndef SYMTAB_H
#define SYMTAB_H

#define MAX_SYMBOLS 100 // Pretty dumb, but it'll be okay for now

typedef struct symbol {
    char* name;
    char* type;
} symbol;

symbol* symtab;

// Returns a pointer to an entry in the table if it exists,
// adds a new one if it doesn't.
symbol* lookup(char* id, symbol* st);

#endif
