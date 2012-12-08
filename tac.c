#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "tac.h"

int current_temp;
node* quads;

void init_tac() {
  current_temp = 0;
}

quad* gen(char* dest, char* left, char* op, char* right) {
  quad* q;
  q = (quad*) malloc(sizeof(quad));
  strcpy(q->dest, dest);
  strcpy(q->left, left);
  strcpy(q->op, op);
  strcpy(q->right, right);
  list_append(quads, q);
  return q;
}

char* temp() {
  // Safety first
  char* s = malloc(snprintf(NULL, 0, "t%d", current_temp) + 1);
  sprintf(s, "t%d", ++current_temp);
  return s;
}

// TODO
void print_tac() {
}
