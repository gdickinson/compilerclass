void append_code(node* n, quad* q) {
    if (n == NULL) {
        n = create_list(q);
    } else {
        list_append(n, q);
    }
}
