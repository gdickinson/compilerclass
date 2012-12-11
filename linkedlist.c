#include "linkedlist.h"
#include <stdlib.h>
#include <stdio.h>

node* list_create(void* data) {
    node* n;
    if (! (n = malloc(sizeof(node)))) {
        return NULL;
    }
    n->data = data;
    n->next = NULL;
    return n;
}

node* list_insert(node* n, void* data) {
    node* newnode;
    newnode = list_create(data);
    newnode->next = n->next;
    n->next = newnode;
    return newnode;
}

node* list_append(node* n, void* data) {
    if (n == NULL) {
        printf("creating new list because append called on null\n");
        n = list_create(data);
        return n;
    }

    while (n->next != NULL) {
        n = n->next;
    }
    return list_insert(n, data);
}

void list_foreach(node* n, void(*func)(void*)) {
    while (n != NULL) {
        func(n->data);
        n = n->next;
    }
}

node* list_search(node* n, int (*func)(void*, void*), void* target) {
    while (n != NULL) {
        if (func(n->data, target) == 0) {
            return n;
        }
        n = n->next;
    }
    return NULL;
}

