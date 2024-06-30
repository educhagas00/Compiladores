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

"=="        { yylval.label = "=="; return TK_EQ; }
"!="        { yylval.label = "!="; return TK_NE; }
"<"         { yylval.label = "<"; return TK_LT; }
">"         { yylval.label = ">"; return TK_GT; }
"<="        { yylval.label = "<="; return TK_LE; }
">="        { yylval.label = ">="; return TK_GE; }


"(int)"     { yylval.label = "(int)"; return TK_CAST_I; }
"(float)"   { yylval.label = "(float)"; return TK_CAST_F; }

[(){}[\];,]	{ return *yytext; }

[+\-*/]		{ return *yytext; }

"="		    { return '='; }

"&&"        { return TK_AND; }
"||"        { return TK_OR; }
"!"         { return TK_NOT; }
"++"        { return TK_MAIS_MAIS; }
"--"        { return TK_MENOS_MENOS; }

"if"        { yylval.label == "if"; return TK_IF; }
"else if"   { yylval.label == "else if"; return TK_ELIF; }
"else"      { yylval.label == "else"; return TK_ELSE; }
"while"     { yylval.label == "while"; return TK_WHILE; }

{NUM}		{ yylval.label = yytext; return TK_NUM; }
{BOOL}      { yylval.label = yytext; return TK_BOOL; }
{FLOAT}     { yylval.label = yytext; return TK_FLOAT; }
{CHAR}      { yylval.label = yytext; return TK_CHAR; }
{ID}		{ yylval.label = yytext; return TK_ID; }


.			{ *yytext; }

%%
