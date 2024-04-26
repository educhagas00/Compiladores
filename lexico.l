%{
#include <string>

%}

DELIM [ \t\n]
WS {DELIM}+

DIGITO [0-9]
NUM {DIGITO}+
FLOAT {NUM}+("."{NUM}+)?

NUMERO {[0-9]}+({[0-9]} | \'"_"\')*

LETRA [A-Za-z_]

CHAR \'({LETRA}|{NUM})\'

BOOL ("True"|"False")

ID {LETRA}({LETRA}|{NUM})*

%%

{WS}        {/* nenhuma ação e nenhum retorno */}

"\n"		{}

{DELIM} 	{}

"main"		{ return TK_MAIN; }

"int"		{ yylval.label = yytext; return TK_TIPO_INT; }

"float"     { yylval.label = yytext; return TK_TIPO_FLOAT; }

"char"      { yylval.label = yytext; return TK_TIPO_CHAR; }

"bool"      { yylval.label = yytext; return TK_TIPO_BOOL; }


[(){}[\];,]	{ return *yytext; }

[+\-*/]		{ return *yytext; }

"="		    { return '='; }


{NUM}		{ yylval.label = yytext; return TK_NUM; }
{BOOL}      { yylval.label = yytext; return TK_BOOL; }
{FLOAT}     { yylval.label = yytext; return TK_FLOAT; }
{CHAR}      { yylval.label = yytext; return TK_CHAR; }
{ID}		{ yylval.label = yytext; return TK_ID; }


.			{ *yytext; }

%%
