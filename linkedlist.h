// Functions and structures for manipulating linked lists

#ifndef LINKEDLIST_H
#define LINKEDLIST_H

typedef struct node {
    void* data;
    struct node* next;
} node;

node* list_create(void* data);

node* list_append(node* n, void* data);

node* list_foreach(node* n, int(*func)(void*));

node* list_find(node* n, int(*func)(void*));

#endif
