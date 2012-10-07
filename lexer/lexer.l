/*
lexer.y
A parser specification for flex

Guy Dickinson <guy.dickinson@nyu.edu>
Fall, 2012
*/

%{
#include <stdio.h>
#include <stdlib.h>

int line = 1;

%}

DIGIT     [0-9]
INTEGER   {DIGIT}*
LETTER    [a-zA-Z]
ID        {LETTER}({LETTER}|{DIGIT})*
WS        [ \t]
RELOP     (<|>|<=|>=|<>|=)
BINOP     [\+\-\*\/]

%x        COMMENT

%%

\{                          {BEGIN(COMMENT);}
<COMMENT>\}                 {BEGIN(INITIAL);}
<COMMENT>\n                 {line++;}
<COMMENT>.                  {}
{WS}*                       {}
\r                          {}
\n                          {line++;}


and                         {printf("AND \n"); return 1;}
begin                       {printf("BEGIN \n"); return 1;}
forward                     {printf("FORWARD \n"); return 1;}
div                         {printf("DIV \n"); return 1;}
do                          {printf("DO \n"); return 1;}
else                        {printf("ELSE \n"); return 1;}
end                         {printf("END \n"); return 1;}
for                         {printf("FOR \n"); return 1;}
function                    {printf("FUNCTION \n"); return 1;}
if                          {printf("IF \n"); return 1;}
array                       {printf("ARRAY \n"); return 1;}
mod                         {printf("MOD \n"); return 1;}
not                         {printf("NOT \n"); return 1;}
of                          {printf("OF \n"); return 1;}
or                          {printf("OR \n"); return 1;}
procedure                   {printf("PROCEDURE \n"); return 1;}
program                     {printf("PROGRAM \n"); return 1;}
record                      {printf("RECORD \n"); return 1;}
then                        {printf("THEN \n"); return 1;}
to                          {printf("TO \n"); return 1;}
type                        {printf("TYPE \n"); return 1;}
var                         {printf("VAR \n"); return 1;}
while                       {printf("WHILE \n"); return 1;}

{RELOP}                     {printf("RELOP: %s \n\n", yytext); return 1;}
{BINOP}                     {printf("BINOP: %s \n\n", yytext); return 1;}

\;                          {printf("SEMIC \n"); return 1;}
\.\.                        {printf("DOUBLEDOT \n"); return 1;}
\.                          {printf("DOT \n"); return 1;}
,                           {printf("COMMA \n"); return 1;}
:=                          {printf("ASSIGN \n"); return 1;}
:                           {printf("COLON \n"); return 1;}
\(                          {printf("LPAR \n"); return 1;}
\)                          {printf("RPAR \n"); return 1;}
\[                          {printf("LBKT \n"); return 1;}
\]                          {printf("RBKT \n"); return 1;}

{INTEGER}                   {printf("INTEGER: %d \n", atoi(yytext)); return 1;}
\".*\"                      {printf("STRING: %s \n", yytext); return 1;}
{ID}                        {printf("ID: %s \n", yytext); return 1;}

.                           {printf("Parse error at line %d. Herp derp. \n", line); exit(-1);}

%%

int main(int argc, char** argv) {
  FILE* file;
  if (argc == 2) {
    
    file = fopen(argv[1], "r\n");

    if(!file) {
     fprintf(stderr, "Could not open %s \n", argv[1]);
     exit(1);
  } 

   yyin = file;

 } else {
    yyin = stdin;
  }

  int res = 1;
  while (res) {
    res = yylex();
  }
}
