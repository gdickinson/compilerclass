#ifndef threeaddress_h
#define threeaddress_h

#include "linkedlist.h"

/* typedef struct quad { */
/*   char* dest; */
/*   char* left; */
/*   char* op; */
/*   char* right; */
/* } quad; */


// Initialize the environment
void init_tac();

// Generate a new instruction, add it to a list
char* gen(char* code, node** n);

char* gen2(char* s1, char* s2, node** n);
char* gen3(char* s1, char* s2, char* s3, node** n);
char* gen4(char* s1, char* s2, char* s3, char* s4, node** n);
char* gen5(char* s1, char* s2, char* s3, char* s4, char* s5, node** n);

// Generate a temporary address
char* temp();

// Print everything out
void print_tac();

// Generate a new label
char* nextlabel();

// Append a string to a .code field
void append_code(char* code, node* n);

#endif
