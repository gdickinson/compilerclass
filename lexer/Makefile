CC	= gcc
LEX     = flex
YACC    = bison -y
YFLAGS 	= -d
#RM	= rm
objects = lexer.o lexer.c


lexer:		lexer.c
	gcc lexer.c -o lexer
lexer.c:
	flex -o lexer.c lexer.l
clean:
	rm *.c lexer