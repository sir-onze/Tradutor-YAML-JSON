%{
#include <stdio.h>

void yyerror(char* s);
int yylex();
FILE* out;
char a[1024];
%}

%union{
    char* s;
    int i;
}

%token <s> COMMENT ATOM NEWLINE COLON HY
%type  <s> yaml array arrayelems arrayelem map mapnull object object1
%type  <s> object2


%%

yaml: yaml COMMENT                      {;}
    | yaml object                       {fprintf(out,"  %s\n",$2);}
    | yaml array                        {fprintf(out,"  %s\n",$2);}
    | yaml map                          {fprintf(out,"  %s\n",$2);}
    | yaml mapnull                      {fprintf(out,"  %s\n",$2);}
    | yaml NEWLINE
    | /*empty*/
    ;

object: mapnull object1                 {sprintf($$,"%s  {\n%s\n  }",$1,$2);}
      ;

object1: object1 object2                {sprintf($$,"%s\n%s",$1,$2);}
       | object2                        {sprintf($$,"%s",$1);}

object2: mapnull
       | array
       | map
       ;

map: ATOM COLON ATOM                    {sprintf($$,"%s: %s",$1,$3);}
   ;

mapnull: ATOM COLON NEWLINE             {sprintf($$,"%s: null",$1);}
       ;

array: ATOM COLON NEWLINE arrayelems    {sprintf($$,"%s: [%s]",$1,$4);}
     ;

arrayelems: arrayelems arrayelem        {sprintf($$,"%s, %s",$1,$2);}
          | arrayelem
          ;

arrayelem: HY ATOM NEWLINE      {$$ = $2;}
         ;

%%

#include "lex.yy.c"

void yyerror(char* s){
     fprintf(stderr, "%d: %s (%s)\n", yylineno, s, yytext);
}

int main(){
    out = fopen("out.json","w+");
    fprintf(out,"{\n");
    yyparse();
    fprintf(out,"}\n");
    fclose(out);
    return 0;
}
