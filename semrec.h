#ifndef semrec_h
#define semrec_h

typedef struct semrec_t {
  int ival; // Literal integer value
  char* sval; // Literal string value
  int tru;
  int fls;
  symbol* type;
  char* addr;
} semrec_t;

#endif
