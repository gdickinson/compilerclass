#ifndef threeaddress_h
#define threeaddress_h

#include "linkedlist.h"

typedef struct quad {
  char* dest;
  char* left;
  char* op;
  char* right;
} quad;

// Initialize the environment
void init_tac();

// Generate a new instruction and append it to the list of instructions
quad* gen(char* dest, char* left, char* op, char* right);

// Generate a temporary address
char* temp();

// Print everything out
void print_tac();

#endif
