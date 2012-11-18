#include "linkedlist.h"
#include <stdlib.h>


node* list_create(void* data) {
    node* n;
    if (! (n = malloc(sizeof(node)))) {
        return NULL;
    }
    n->data = data;
    n->next = NULL;
    return n;
}

node* list_append(node* n, void* data) {
}

node* list_foreach(node* n, int(*func)(void*)) {
}

node* list_find(node* n, int(*func)(void*)) {
}
