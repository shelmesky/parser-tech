all:
	flex -o caculator.lex.c caculator.l
	bison -d caculator.y
