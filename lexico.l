%{
#include <string>

%}

DELIM [ \t\n]
WS {DELIM}+

DIGITO [0-9]
NUM {DIGITO}+
FLOAT {NUM}+("."{NUM}+)?

LETRA [A-Za-z_]

CHAR \'({LETRA}|{NUM})\'

ID {LETRA}({LETRA}|{NUM})*

%%

{WS}        {/* nenhuma ação e nenhum retorno */}

"\n"		{}

{DELIM} 	{}

"main"		{return TK_MAIN;}

"int"		{yylval.label = yytext; return TK_TIPO_INT;}

"float"     {yylval.label = yytext; return TK_TIPO_FLOAT;}

[(){}[\];,]	{ return *yytext; }

[+\-*/]		{ return *yytext; }

"="		    { return '='; }

{NUM}		{ yylval.label = yytext; return TK_NUM; }
{ID}		{ yylval.label = yytext; return TK_ID; }
{FLOAT}     { yylval.label = yytext; return TK_NUM; }

.			{ *yytext; }

%%
