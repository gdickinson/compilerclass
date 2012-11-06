# Components for NYU Parser Project
## Guy Dickinson <gdickinson@nyu.edu>

## Files:
* lex.l : Flex specification
* parser.y : Parser specification
* symtab.[c|h] : Utility functions (with header) for manipulating a simple symbol table
* Makefile : A Makefile (of course).

## Compiling the project:

  $ ./make

  Should be all that's required. This is tested on a Mac OS X system as well as the
CIMS systems. If something goes wrong or you want to recompile, there's a

  $ ./make clean

Running the project:

  ./parser <input file>

Will parse an input file, print out the relevant matched production rules to
STDIN, and upon reaching EOF, print out the symbol table.

If no file name is specified, the parser will read from STDIN, making

  cat <somefile> | ./parser

possible, to comply with general POSIX good practice.

## Other notes:
* Symbols are inserted into the symbol table by the lexer, not the parser, and all
identifiers are inserted, regardless of their context. The parser then inserts type
information as it becomes available.  The obvious consequence of this, at least as
far as the test programs provided are concerned, is that there aresymbols with no
bound types (or any other information, for that matter). For example, in
lexical2.pas, `integer`, `boolean`, and `readint` are never defined anywhere, but
the file is syntactically valid. These appear in the symbol table with a type of
(null).
* The return types of functions are ignored, but can easily be added
* The types of function arguments are not ignored. They appear in the symbol table
as well.
* The symbol table is global, its namespace is flat, and there is no checking for
pre-existing symbols. They will simply be overwritten if redefined. It is, frankly,
quick and dirty, but suffices for the test inputs.
