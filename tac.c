#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <stdio.h>
#include "tac.h"
#include "linkedlist.h"

int current_temp;
// Counter for label generation
int current_label;

// Label to be attached to next instruction
int next_label;

//node* quads;

void init_tac() {
  current_temp = 0;
  current_label = 0;
  next_label = -1;
}

char* gen(char* code, node** n) {
    if (*n == NULL) {
        *n = list_create(code);
    } else {
        list_append(*n, code);
    }
    return code;
}

char* gen2(char* s1, char* s2, node** n) {
    char* c;
    asprintf(&c, "%s %s", s1, s2);
    gen(c, n);
    return c;
}

char* gen3(char* s1, char* s2, char* s3, node** n) {
    char* c;
    asprintf(&c, "%s %s %s", s1, s2, s3);
    gen(c, n);
    return c;
}

char* gen4(char* s1, char* s2, char* s3, char* s4, node** n) {
    char* c;
    asprintf(&c, "%s %s %s %s", s1, s2, s3, s4);
    gen(c, n);
    return c;
}

char* gen5(char* s1, char* s2, char* s3, char* s4, char* s5, node** n) {
    char* c;
    asprintf(&c, "%s %s %s %s %s", s1, s2, s3, s4, s5);
    gen(c, n);
    return c;
}

char* temp() {
  char* s = malloc(snprintf(NULL, 0, "t%d", current_temp) + 1);
  sprintf(s, "t%d", ++current_temp);
  return s;
}

void print_code(char* code) {
    printf("%s\n", code);
}

void print_node(void* v) {
    char* c = (char*) v;
    print_code(c);
}

void print_tac(node* n) {
    if (n == NULL) { printf("print_tac called on null\n"); }
    list_foreach(n, print_node);
}

char* nextlabel() {
    char b[10];
    sprintf(b, "L%d", ++current_label);
    return strdup(b);
}

void append_code(char* code, node* n) {
    if (n == NULL) {
        n = list_create(code);
    } else {
        list_append(n, code);
    }
}

void label(int l) {
    next_label = l;
}
