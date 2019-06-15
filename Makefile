make:
	flex flex.fl
	yacc -v yacc.y
	cc -o run y.tab.c

clean:
	rm y.tab.c lex.yy.c y.output run out.json
