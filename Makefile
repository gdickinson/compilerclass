CC	= clang -g -Wall
LEX     = flex
YACC    = bison -y -d
#RM	= rm

semantic_analyzer: symtab.o parser.tab.o linkedlist.o tac.o lex.yy.c
	$(CC) -o $@ $?

lex.yy.c: parser.tab.h

%.o: %.c
	$(CC) -c $<

%.yy.c: %.l
	$(LEX) -o $@ $<

%.tab.c: %.y
	$(YACC) -o $@ $<

%.tab.h: %.tab.c
	@touch $@

clean:
	rm *.tab.h *.tab.c *.o parser.output semantic_analyzer *.yy.c
