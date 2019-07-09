all:
	flex -o caculator.lex.c caculator.l
	bison -v -d caculator.y
