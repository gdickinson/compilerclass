#include <stdlib.h>
#include "linkedlist.h"
#include "tac.h"

#ifndef semrec_h
#define semrec_h

typedef struct semrec_t {
  int ival; // Literal integer value
  char* sval; // Literal string value
  char* tru;
  char* fls;
  symbol* type;
  char* addr;
  node* code;
} semrec_t;

void append_code(node* n, quad* q);

#endif
