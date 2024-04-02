%{
#include <string.h>
%}

ESPACO [ \t]
DIGITO [0-9]
LETRA  [A-Za-z]

DELIM {ESPACO}+
NUM {DIGITO}+
ID {LETRA}({LETRA}|{DIGITO})*


%%

"\n"        {}

{DELIM}     {}

"main"      { return TK_MAIN;}

"int"       { return TK_TIPO_INT;}

"="         { return '=';}

[(){}[\];,] { return *yytext;}

[+\-*/]     { return *yytext;}

{NUM}		{ yylval.l = yytext; return TK_NUM; }

{ID}		{ yylval.l = yytext; return TK_ID; }

.			{ *yytext; }

%%
//funcoes auxiliares 






