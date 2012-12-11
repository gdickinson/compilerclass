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
  quad* q = (quad*) malloc(sizeof(quad));
  if (dest != NULL) { q->dest = strdup(dest); }
  if (left != NULL) { q->left = strdup(left); }
  if (op != NULL) { q->op = strdup(op); }
  if (right != NULL) { q->right = strdup(right); }

  if (quads == NULL) {
    quads = list_create(q);
  } else {
    list_append(quads, q);
  }
  return q;
}

char* temp() {
  // Safety first
  char* s = malloc(snprintf(NULL, 0, "t%d", current_temp) + 1);
  sprintf(s, "t%d", ++current_temp);
  return s;
}

void print_code(void* v) {
    quad* q = (quad*) v;
    printf("%s = %s %s %s\n", q->dest, q->left, q->op, q->right);
}

void print_tac() {
    list_foreach(quads, &print_code);
}
