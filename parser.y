/*
  parser.y
  A parser specification for Bison
  Guy Dickinson <guy.dickinson@nyu.edu>

  Compiler Design, Fall 2012
  New York University
*/

%{

// PROLOGUE
#include <stdio.h>
#include <stdlib.h>

// References from flex. Always be hacking.
extern int yylex();
extern int yyparse();
//extern void yyerror(char *errmsg);
extern FILE *yyin;

void yyerror(const char *s);

%}
// DECLARATIONS

// VALUE TYPE UNION
%union {
  int ival;
  char* sval;
}

// Keywords
%token AND
%token ASSIGN
%token BEGN //BEGIN is a reserved word in flex-land
%token FORWARD
%token DIV
%token DO
%token ELSE
%token END
%token FOR
%token FUNCTION
%token IF
%token ARRAY
%token MOD
%token NOT
%token OF
%token OR
%token PROCEDURE
%token PROGRAM
%token RECORD
%token THEN
%token TO
%token TYPE
%token VAR
%token WHILE

// Special Characters
%token SEMIC
%token DOUBLEDOT
%token DOT
%token COMMA
%token COLON
%token LPAR
%token RPAR
%token LBKT
%token RBKT

// Operators
%token <sval> RELOP
%token <sval> BINOP

// Value Types
%token <ival> INTEGER
%token <sval> STRING
%token <sval> ID

%%

// GRAMMAR RULES
program:        PROGRAM ID SEMIC
/*                 [type_definitions] */
/*                 [variable_declarations] */
/*                 [subprogram_declarations] */
/*                 compund_statement */
/*                 {} */

/* type_definitions: */

/*         ; */

/* variable_declarations: */
/*         ; */

/* subprogram_declarations: */

/*         ; */

/* type_definition: */
/*         ; */

/* variable_declaration: */

/*         ; */

/* prodecure_declaration: */
/*         ; */


/* function_declaration: */
/*         ; */

/* formal_parameter_list: */

/*         ; */

/* block:           */
/*         ; */

/* compound_statement: */
/*                 BEGIN statement_sequence END */
/*         ; */

/* statement_sequence: */
/*                 statement [SEMIC statement] */
/*         ; */


%%

int main(int argc, char** argv) {
    printf("main() in parser called!");
    FILE *input;
    if (argc > 1) {
        input = fopen(argv[1], "r");
        if (!input) {
            printf("Could not open input file: %s\n", argv[1]);
            exit(-1);
        }
    } else {
        input = stdin;
    }
    yyin = input;
    do {
        yyparse();
    } while (!feof(yyin));

}

void yyerror(const char *s) {
    printf("Error: %s\n", s);
}
