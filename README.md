# Components for NYU Parser Project
## Guy Dickinson <gdickinson@nyu.edu>

## Files:
* lex.l : Flex specification
* parser.y : Parser specification
* symtab.[c|h] : Utility functions (with header) for manipulating a simple symbol table
* linkedlist.[c|h]: Utility functions for manipulating linked lists, for space-efficient
  symbol lists
* Makefile : A Makefile (of course).

## Compiling the project:

    make

  Should be all that's required. This is tested on a Mac OS X system as well as the
CIMS systems. If something goes wrong or you want to recompile, there's a

    make clean

Running the project:

  ./semantic_analyzer <input file>

Will parse an input file, print out warnings when semantic errors are encountered, and upon
reaching EOF (providing that no fatal errors were encountered), print the symbol table, broken into
scopes, which is handy for debugging.

If no file name is specified, the parser will read from STDIN, making

  cat <somefile> | ./parser

possible, to comply with general POSIX good practice.

## Other notes:
* Some symbols are inserted into the global (root) symbol table to aid in parsing, and recovering
from errors. Specifically, there's a root type of PROGRAM to support the 'program' keyword, as well
as an UNKNOWN type which supports continued parsing after referencing an undeclared variable. This
has the interesting side-effect that the language actually supports implicit definitions, made
possible by insertion of symbols into the symbol table by the lexer, not the parser.
* We continue parsing right to the end, unless we encounter a fatal parsing or lexing error.
* Type checking is done by reducing everything to primitive types. Not the fastest, but the easiest
to implement.
