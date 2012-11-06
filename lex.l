/*
lexer.y
A parser specification for flex

Guy Dickinson <guy.dickinson@nyu.edu>
Fall, 2012
*/

%{
#include <stdio.h>
#include <stdlib.h>
#include "symtab.h"
#include "parser.tab.h"
int line = 1;
extern symbol* symtab;

%}

%option noyywrap
%option yylineno

DIGIT     [0-9]
INTEGER   {DIGIT}*
LETTER    [a-zA-Z]
ID        {LETTER}({LETTER}|{DIGIT}|\_)*
WS        [ \t]

%x        COMMENT

%%

\{                          {BEGIN(COMMENT);}
<COMMENT>\}                 {BEGIN(INITIAL);}
<COMMENT>\n                 {line++;}
<COMMENT>.                  {}
{WS}*                       {}
\r                          {}
\n                          {line++;}


and                         {return AND;}
begin                       {return BEGN;}
forward                     {return FORWARD;}
div                         {return DIV;}
do                          {return DO;}
else                        {return ELSE;}
end                         {return END;}
for                         {return FOR;}
function                    {return FUNCTION;}
if                          {return IF;}
array                       {return ARRAY;}
mod                         {return MOD;}
not                         {return NOT;}
of                          {return OF;}
or                          {return OR;}
procedure                   {return PROCEDURE;}
program                     {return PROGRAM;}
record                      {return RECORD;}
then                        {return THEN;}
to                          {return TO;}
type                        {return TYPE;}
var                         {return VAR;}
while                       {return WHILE;}

\+                          {return PLUS;}
\-                          {return MINUS;}
\*                          {return MULTIPLY;}
\/                          {return DIVIDE;}
\<                          {return LESSTHAN;}
\>                          {return GREATERTHAN;}
\<\>                        {return DIAMOND;}
\<\=                        {return LEQ;}
\>\=                        {return GEQ;}
\=                          {return EQUALS;}

\;                          {return SEMIC;}
\.\.                        {return DOUBLEDOT;}
\.                          {return DOT;}
,                           {return COMMA;}
:=                          {return ASSIGN;}
:                           {return COLON;}
\(                          {return LPAR;}
\)                          {return RPAR;}
\[                          {return LBKT;}
\]                          {return RBKT;}

{INTEGER}                   {yylval.ival = atoi(yytext); return INTEGER;}
\".*\"                      {yylval.sval = yytext; return STRING;}
{ID}                        {yylval.sym = lookup(yytext, symtab);
                             return ID;}

.                           {printf("Parse error at line %d. Herp derp. \n", line); exit(-1);}

%%

/* int main(int argc, char** argv) { */
/*   FILE* file; */
/*   if (argc == { */
/*     file = fopen(argv[1], "r\n"); */

/*     if(!file) { */
/*      fprintf(stderr, "Could not open %s \n", argv[1]); */
/*      exit(1); */
/*   } */

/*    yyin = file; */

/*  } else { */
/*     yyin = stdin; */
/*   } */

/*   int res = 1; */
/*   while (res) { */
/*     res = yylex(); */
/*   } */
/* } */