%{
#include <string>

%}

DELIM [ \t\n]
WS {DELIM}+

DIGITO [0-9]
NUM {DIGITO}+
REAL {NUM}+("."{NUM}+)? 

LETRA [A-Za-z_]

CHAR \'({LETRA}|{NUM})\'

ID {LETRA}({LETRA}|{NUM})*

%%

{WS}        {/* nenhuma ação e nenhum retorno */}

"\n"		{}

{DELIM} 	{}

"main"		{return TK_MAIN;}

"int"		{return TK_TIPO_INT;}

[(){}[\];,]	{ return *yytext; }

[+\-*/]		{ return *yytext; }

"="		    { return '='; }

{NUM}		{ yylval.label = yytext; return TK_NUM; }
{ID}		{ yylval.label = yytext; return TK_ID; }

.			{ *yytext; }

%%
