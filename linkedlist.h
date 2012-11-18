// Functions and structures for manipulating linked lists

#ifndef LINKEDLIST_H
#define LINKEDLIST_H

typedef struct node {
    void* data;
    struct node* next;
} node;

node* list_create(void* data);

node* list_append(node* n, void* data);

void list_foreach(node* n, void(*func)(void*));

node* list_search(node* n, int(*func)(void*, void*), void* target);

#endif
