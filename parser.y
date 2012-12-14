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
#include "tac.h"
#include "semrec.h"

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

char* last_id;

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
  semrec_t semr;
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
%token <sval> INTEGER
%token <sval> STRING
%token <sym> ID


// Some nonterminals have types so we can manipulate the symbol table
%type <semr> type
%type <semr> result_type
%type <semr> factor
%type <semr> variable
%type <semr> expression
%type <semr> simple_expression
%type <semr> function_reference
%type <semr> term
%type <sval> mul_op
%type <sval> add_op
%type <sval> constant
%type <sval> sign
%type <sval> relational_op
%type <semr> component_selection
%type <semr> statement
%type <semr> structured_statement
%type <semr> simple_statement
%type <semr> assignment_statement
%type <semr> function_declaration
%type <semr> block_or_forward
%type <semr> block
%type <semr> compound_statement
%type <semr> subprogram_declarations
%type <semr> program
%type <semr> statement_sequence
%type <semr> expression_list
%type <semr> actual_parameter_list
%type <semr> procedure_declaration


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
                {   $2->type = lookup("PROGRAM", symtab_root);
                    $$.code = $7.code;
                    list_merge($$.code, $8.code);
                    print_tac($$.code);
                }
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
                { $1->type = $3.type;}
        ;

type:
                ID {$$.type = $1->type;}
        |       ARRAY OF type {$$.type = lookup("ARRAY", symtab_root);}
        |       ARRAY LBKT constant DOUBLEDOT constant RBKT OF type {$$.type = lookup("ARRAY", symtab_root);}
        |       RECORD field_list END {$$.type = lookup("RECORD", symtab_root);}
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
                { process_saved_symbols(saved_symbols, $3.type);
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
                variable_declarations compound_statement { $$ = $2; }
        |       compound_statement { $$ = $1; }
        ;

procedure_declaration:
                PROCEDURE ID LPAR formal_parameters RPAR SEMIC block_or_forward
                {
                    $2->type = lookup("PROCEDURE", symtab_root);
                    reset_saved_symbols(saved_symbols);
                    gen2($2->label, ":", &($$.code));
                    list_merge($$.code, $7.code);
                    gen("return", &($$.code));

                }
        ;

block_or_forward:
                block { $$ = $1; }
         |      FORWARD { }
         ;

function_declaration:
                FUNCTION
                ID
                {
                    current_scope = create_scope(current_scope);
                }
                LPAR
                formal_parameters RPAR COLON result_type SEMIC
                { $2->type = $8.type;

                  $2->label = nextlabel();}
                block_or_forward
                {
                reset_saved_symbols(saved_symbols);
                current_scope = current_scope->parent;
                gen2($2->label, ":", &($$.code));
                list_merge($$.code, $11.code);
                gen2("funreturn", $2->name, &($$.code));
                }
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
                { process_saved_symbols(saved_symbols, $3.type); }
        ;

compound_statement:
                BEGN
                {current_scope = create_scope(current_scope);}
                statement_sequence
                {current_scope = current_scope->parent;}
                END
                { $$ = $3; }
        ;

statement_sequence:
                statement SEMIC statement_sequence
                {
                   $$.code = $1.code;
                   list_merge($$.code, $3.code); // Dupes???
               }
        |       statement  { $$ = $1; } // XXX: Produces duplicates ?
        ;

statement:
                simple_statement {}
        |       structured_statement
        {
            //$1.next = nextlabel();
            //printf("statement: %s\n%s: ", $1.code, $1.next);
        }
        ;

simple_statement:
                assignment_statement
        |       procedure_statement
        |       // Epsilon
        ;

assignment_statement:
                variable ASSIGN expression
                {
                   if (typecheck($1.type, $3.type, current_scope) ) {
                        printf("WARNING: Incompatible type assignment %s, %s at line %d\n", $1.type->name, $3.type->name, yylineno);
                    }

                    // TAC
                   $$.code = $3.code;
                   char* c;
                   asprintf(&c, "%s = %s", $1.addr, $3.addr);
                   gen(c, &($$.code));
                }
        ;

component_selection:
                DOT ID component_selection
                {
                    //$$.addr = temp();
                    //char* v;
                    //asprintf(&v, "%s.%s", last_id, $3.addr);
                    //                    last_id = strdup($$.addr);
                    //gen($$.addr, v, NULL, NULL);
                    //todo
                }
        |       LBKT expression RBKT component_selection {}
        |       {}// Epsilon
        ;

structured_statement: //TODO
                compound_statement
        |       IF expression THEN statement
                {
                    $2.tru = nextlabel();
                    $2.fls = $$.next;
                    $4.next = $$.next;
                    $$.code = malloc(512);
                    //printf("$$.next is %s\n", $$.next);
                    //sprintf($$.code, "structured: %s\n%s: %s\n", $2.code, $2.fls, $4.code);
                }

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
expression COMMA expression_list {$$.code = $1.code; list_merge($$.code, $3.code); }
                |       expression
                {
                    $$.addr = temp();
                    $$.code = $1.code;
                    gen3($$.addr, "=", $1.addr, &$$.code);
                    gen2("param", $$.addr, &$$.code);
                }
        ;

result_type:
                ID { $$.type = $1->type; }
        ;


constant:
                INTEGER { $$ = $1; }
        |       sign INTEGER { $$ = malloc(strlen($2)+2); sprintf($$, "%s%s", $1, $2); }
        ;

expression:
                simple_expression { $$ = $1; }
        |       simple_expression relational_op simple_expression
                {
                    //$$.addr = temp();
                    //gen($$.addr, $1.addr, $2, $3.addr);
                    //printf("In exp\n");
                    //$$.code = "if derp > herp goto someplace\n";
                    //printf("$$.tru is %s\n", $$.tru);
                }
        ;

relational_op:
                LESSTHAN { $$ = "<"; }
        |       GREATERTHAN { $$ = ">"; }
        |       LEQ { $$ = "<="; }
        |       GEQ { $$ = ">="; }
        |       DIAMOND { $$ = "<>"; }
        |       EQUALS { $$ = "="; }
        ;

simple_expression:
                term { $$ = $1; }

        |       sign term
        {
            $$.addr = temp();
            $$.code = $2.code;
            char* c;
            asprintf(&c, "%s = %s%s", $$.addr, $1, $2.addr);
            gen4($$.addr, "=", $1, $2.addr, &($$.code));
        }

        |       simple_expression add_op term
        {
            $$.addr = temp();
            $$.code = $1.code;
            list_append($1.code, $3.code);
            gen5($$.addr, "=", $1.addr, $2, $3.addr, &($$.code));
        }
        ;

add_op:
                PLUS { $$ = "+"; }
        |       MINUS {$$ = "-";}
        |       OR { $$ = "or";}
        ;

term:
                factor {$$.addr = $1.addr; }
        |       factor mul_op term
        {
            $$.addr = temp();
            $$.code = $1.code;
            list_merge($$.code, $3.code);
            gen5($$.addr, "=", $1.addr, $2, $3.addr, &($$.code));
        }
        ;

mul_op:
                MULTIPLY {$$ = "*";}
        |       DIV {$$ = "/";}
        |       MOD {$$ = "%";}
        |       AND {$$ = "and";}
        ;

factor:
                INTEGER { $$.type = lookup("integer", symtab_root); $$.addr = strdup($1);}
        |       STRING { $$.type = lookup("string", symtab_root); $$.addr = strdup($1);}
        |       variable { $$.type = $1.type; $$.addr = $1.addr; $$.code = $1.code;}
        |       function_reference { $$.type = $1.type; $$.code = $1.code;}
        |       NOT factor { $$.type = $2.type; $$.addr = $2.addr; $$.code = $2.code;}
        |       LPAR expression RPAR { $$.type = $2.type; $$.addr = $2.addr; $$.code = $2.code;}
        ;

function_reference:
                ID LPAR actual_parameter_list RPAR
                {
                    if (!$1->type) {
                        printf("WARNING: function %s referenced without declaration at line %d\n", $1->name, yylineno);
                        $1->type = lookup("UNKNOWN", symtab_root);
                        }
                    $$.type = $1->type;
                    $$.addr = temp();
                    $$.code = $3.code;
                    gen4($$.addr, "=", "funcall", $1->label, &($$.code));
                }
        ;

variable:

        ID
        component_selection
                {
                    if (!$1->type) {
                        printf("WARNING: %s referenced without declaration at line %d\n", $1->name, yylineno);
                        $1->type = lookup("UNKNOWN", symtab_root);
                    }
                    $$.addr = $1->name;
                    $$.type = $1->type;
                }
        ;

identifier_list:
                identifier_list COMMA ID {insert_saved_symbol($3, saved_symbols);}
        |       ID {insert_saved_symbol($1, saved_symbols);}
        ;

sign:
                PLUS { $$ = "+"; }
        |       MINUS { $$ = "-"; }
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
    init_tac();
    // Create the root scope
    symtab_root = create_scope(NULL);

    // Add root primitive types
    add_symbol_to_scope(symtab_root, create_root_type("PROGRAM"));
    add_symbol_to_scope(symtab_root, create_root_type("ARRAY"));
    add_symbol_to_scope(symtab_root, create_root_type("RECORD"));
    add_symbol_to_scope(symtab_root, create_root_type("PROCEDURE"));

    // Shim to allow for continued parsing after an undeclared reference
    add_symbol_to_scope(symtab_root, create_root_type("UNKNOWN"));

    add_symbol_to_scope(symtab_root, create_root_type("integer"));
    add_symbol_to_scope(symtab_root, create_root_type("string"));
    add_symbol_to_scope(symtab_root, create_root_type("boolean"));

    add_symbol_to_scope(symtab_root, create_symbol_with_type("true", lookup("boolean", symtab_root)));
    add_symbol_to_scope(symtab_root, create_symbol_with_type("false", lookup("boolean", symtab_root)));

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

    // Free globals
    free(symtab_root);
    free(saved_symbols);
}

void yyerror(const char *s) {
    printf("Error: %s (line %d)\n", s, yylineno);
}
