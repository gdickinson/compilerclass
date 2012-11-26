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
#include <string.h>
#include "symtab.h"

#define MAX_SAVED_SYMBOLS 20

// References for stuff generated by flex
extern int yylex();
extern int yyparse();
extern int yylineno;
extern FILE *yyin;

void yyerror(const char *s);

typedef struct idlist {
    symbol *syms[MAX_SAVED_SYMBOLS];
    int cnt;
} idlist;

scope* symtab_root;
scope* current_scope;

idlist* saved_symbols;

void insert_saved_symbol(symbol* sym, idlist* list);
void reset_saved_symbols(idlist* list);
void process_saved_symbols(idlist* list, symbol* type);

%}
%verbose
%error-verbose

// VALUE TYPE UNION
%union {
  int ival;
  char* sval;
  symbol* sym;
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

// Operators -- defined individually because their semantics are context-sensitive
%token PLUS
%token MINUS
%token DIVIDE
%token MULTIPLY
%token LESSTHAN
%token GREATERTHAN
%token LEQ //    (<=)
%token GEQ //   (>=)
%token DIAMOND // (<>)
%token EQUALS

// Value Types
%token <ival> INTEGER
%token <sval> STRING
%token <sym> ID


// Some nonterminals have types so we can manipulate the symbol table
%type <sym> type
%type <sym> result_type
%type <sym> factor
%type <sym> variable
%type <sym> expression
%type <sym> simple_expression
%type <sym> function_reference
%type <sym> term

%%

// GRAMMAR RULES
program:
                PROGRAM ID SEMIC
                { current_scope = create_scope(current_scope); }
                type_definitions
                variable_declarations
                subprogram_declarations
                compound_statement
                DOT
                {   $2->type = lookup("PROGRAM", symtab_root);}
;

type_definitions:
                TYPE type_definitions_list
        |      //Epsilon
        ;

type_definitions_list:
                type_definitions_list type_definition
        |       type_definition
        ;

type_definition:
                ID EQUALS type SEMIC
                { $1->type = $3;}
        ;

type:
                ID {$$ = $1->type;}
        |       ARRAY OF type {$$ = lookup("ARRAY", symtab_root);}
        |       ARRAY LBKT constant DOUBLEDOT constant RBKT OF type {$$ = lookup("ARRAY", symtab_root);}
        |       RECORD field_list END {$$ = lookup("RECORD", symtab_root);}
        ;

field_list:
                identifier_list COLON type
        |       field_list SEMIC field_list
                {   reset_saved_symbols(saved_symbols); }
        ;


variable_declarations:
                VAR
                variable_declarations_list
        |       // Epsilon
        ;

variable_declarations_list:
                variable_declarations_list variable_declaration
        |       variable_declaration
        ;

variable_declaration:
                identifier_list COLON type SEMIC
                { process_saved_symbols(saved_symbols, $3);
                  reset_saved_symbols(saved_symbols); }
        ;

subprogram_declarations:
                subprogram_declaration_list
        |       // Epsilon
        ;


subprogram_declaration_list:
                subprogram_declaration_list subprogram_declaration
        |       subprogram_declaration
        ;

subprogram_declaration:
                procedure_declaration SEMIC
        |       function_declaration SEMIC
        ;

block:
                variable_declarations compound_statement
        |       compound_statement
        ;

procedure_declaration:
                PROCEDURE ID LPAR formal_parameters RPAR SEMIC block_or_forward
                {
                $2->type = lookup("PROCEDURE", symtab_root);
                reset_saved_symbols(saved_symbols); }
        ;

block_or_forward:
                block
         |      FORWARD
         ;

function_declaration:
                FUNCTION
                ID
                {current_scope = create_scope(current_scope);}
                LPAR
                formal_parameters RPAR COLON result_type SEMIC
                { $2->type = $8; }
                block_or_forward
                {
                reset_saved_symbols(saved_symbols);
                current_scope = current_scope->parent;}
        ;

formal_parameters:
                formal_parameter_list
        |       // Epsilon
        ;

formal_parameter_list:
                formal_parameter SEMIC formal_parameter_list
        |       formal_parameter
        ;

formal_parameter:
                identifier_list COLON type
                { process_saved_symbols(saved_symbols, $3); }
        ;

compound_statement:
                BEGN
                {current_scope = create_scope(current_scope);}
                statement_sequence
                {current_scope = current_scope->parent;}
                END
        ;

statement_sequence:
                statement_sequence SEMIC statement
        |       statement
        ;

statement:
                simple_statement
        |       structured_statement
        ;

simple_statement:
                assignment_statement
        |       procedure_statement
        |       // Epsilon
        ;

assignment_statement:
                variable ASSIGN expression
                {
                    if (typecheck($1, $3, current_scope) ) {
                        printf("Incompatible type assignment %s, %s at line %d\n", $1->name, $3->name, yylineno);
                    }
                }
        ;

component_selection:
                DOT ID
        |       LBKT expression RBKT component_selection
        |       // Epsilon
        ;

structured_statement:
                compound_statement
        |       IF expression THEN statement
        |       IF expression THEN statement ELSE statement
        |       WHILE expression DO statement
        |       FOR ID ASSIGN expression TO expression DO statement
        ;

procedure_statement:
                ID LPAR actual_parameter_list RPAR
        ;

actual_parameter_list:
                expression_list
        |       //Epsilon
        ;

expression_list:
                expression_list COMMA expression
        |       expression
        ;

result_type:
                ID
        ;


constant:
                INTEGER
        |       sign INTEGER
        ;

expression:
                simple_expression
        |       simple_expression relational_op simple_expression
        ;

relational_op:
                LESSTHAN
        |       GREATERTHAN
        |       LEQ
        |       GEQ
        |       DIAMOND
        |       EQUALS
        ;

simple_expression:
                term {$$ = $1;}
        |       sign term {$$ = $2;}
        |       simple_expression add_op term {$$ = $3;}
        ;

add_op:
                PLUS
        |       MINUS
        |       OR
        ;

term:
                factor {$$ = $1;}
        |       factor mul_op term {$$ = $1;}
        ;

mul_op:
                MULTIPLY
        |       DIV
        |       MOD
        |       AND
        ;

factor:
                INTEGER { $$ = lookup("integer", symtab_root); }
        |       STRING { $$ = lookup("string", symtab_root); }
        |       variable { $$ = $1->type;  }
        |       function_reference { $$ = $1; }
        |       NOT factor { $$ = $2; }
        |       LPAR expression RPAR { $$ = $2; }
        ;

function_reference:
                ID LPAR actual_parameter_list RPAR
                {
                    if (!$1->type) {
                        printf("WARNING: %s referenced without declaration at line %d\n", $1->name, yylineno);
                        exit(-1);
                        }
                        $$ = $1->type;
                }
        ;

variable:
                ID component_selection
                {
                    if (!$1->type) {
                        printf("WARNING: %s referenced without declaration at line %d\n", $1->name, yylineno);
                        exit(-1);
                    }
                    $$ = $1->type;
                }
        ;

identifier_list:
                identifier_list COMMA ID {insert_saved_symbol($3, saved_symbols);}
        |       ID {insert_saved_symbol($1, saved_symbols);}
        ;

sign:
                PLUS
        |       MINUS
        ;


%%

void insert_saved_symbol(symbol* sym, idlist* list) {
    if (sym->type != NULL) {
        printf("WARNING: Symbol %s multiply defined\n", sym->name);
    }
    list->syms[list->cnt] = sym;
    list->cnt++;
}

void reset_saved_symbols(idlist* list) {
    list->cnt = 0;
}

void process_saved_symbols(idlist* list, symbol* type) {
    int i;
    for (i = 0; i < list->cnt; i++) {
        list->syms[i]->type = type;
    }
}

int main(int argc, char** argv) {
    // Initialize globals
    // Create the root scope
    symtab_root = create_scope(NULL);

    // Add root primitive types
    add_symbol_to_scope(symtab_root, create_root_type("PROGRAM"));
    add_symbol_to_scope(symtab_root, create_root_type("ARRAY"));
    add_symbol_to_scope(symtab_root, create_root_type("RECORD"));
    add_symbol_to_scope(symtab_root, create_root_type("PROCEDURE"));

    add_symbol_to_scope(symtab_root, create_root_type("integer"));
    add_symbol_to_scope(symtab_root, create_root_type("string"));
    add_symbol_to_scope(symtab_root, create_root_type("boolean"));

    current_scope = symtab_root;

    // Create a scratch space for processing identifier lists.
    saved_symbols = malloc(sizeof(idlist));

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

    // Just for good measure and debugging, spit out the symbol table
    print_symbol_table(symtab_root);

    // Free globals
    free(symtab_root);
    free(saved_symbols);
}

void yyerror(const char *s) {
    printf("Error: %s (line %d)\n", s, yylineno);
}
