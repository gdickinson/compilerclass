/*
lexer.y
A parser specification for flex

Guy Dickinson <guy.dickinson@nyu.edu>
Fall, 2012
*/

%{
#include <stdio.h>
#include <stdlib.h>
%}

DIGIT     [0-9]
LETTER    [a-Z]
ID        [a-Z][a-Z0-9]*

%%


%%

int main(int argc, char** argv) {
  if (argc > 1)
  {
    FILE* file;
    file = fopen(argv[1], "r");

    if(!file) {
     fprintf(stderr, "Could not open %s \n", argv[1]);
     exit(1);
   }

   yyin = file;

 }
 yylex();
}