%{
#include <iostream>
#include <string>
#include <sstream>
#include <vector>

#define YYSTYPE atributos

using namespace std;

int var_temp_qnt;

enum TipoVariavel {

	INT = 0,
	FLOAT = 1,
	CHAR = 2
};

std::string tipoParaString(TipoVariavel tipo) {
	
    switch (tipo) {
        case INT:
            return "int";
        case FLOAT:
            return "float";
        case CHAR:
            return "char";
        default:
            return "unknown";
    }
}

struct atributos {

	string label;
	string traducao;
	enum TipoVariavel tipo;
};

typedef struct {

	string nomeVariavel;
	enum TipoVariavel tipoVariavel;
} TABELA_SIMBOLOS;

vector<TABELA_SIMBOLOS> tabelaSimbolos;

int yylex(void);
void yyerror(string);
string gentempcode();
%}


%token TK_MAIN
%token TK_NUM TK_ID TK_FLOAT TK_CHAR
%token TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_CHAR
%token TK_FIM TK_ERROR

%start S

%left '+'

%%

S 			: TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				string codigo = "/*Compilador OASIS*/\n"
								"#include <iostream>\n"
								"#include <string.h>\n"
								"#include <stdio.h>\n"
								"int main(void) {\n";
								
				codigo += $5.traducao;
								
				codigo += 	"\treturn 0;"
							"\n}";

				cout << codigo << endl;
			}
			;

BLOCO		: '{' COMANDOS '}'
			{
				$$.traducao = $2.traducao;
			}
			;

COMANDOS	: COMANDO COMANDOS
			{
				$$.traducao = $1.traducao + $2.traducao;
			}
			|
			{
				$$.traducao = "";
			}
			;

COMANDO 	: E ';'
			{
				$$ = $1;
			}
			| TYPE TK_ID ';'
			{
				TABELA_SIMBOLOS valor;

				valor.tipoVariavel = $1.tipo;
				valor.nomeVariavel = $2.label;

				cout << tipoParaString($1.tipo) << endl;
				cout << $2.label << endl;
				
				tabelaSimbolos.push_back(valor);
				$$.traducao = "\t" + $1.label + " " + $2.label + ";\n";
				
			}
			;

E 			: E '+' E
			{
				cout << tipoParaString($1.tipo) << endl;
				cout << tipoParaString($3.tipo) << endl;
				$$.label = gentempcode();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
					" = " + $1.label + " + " + $3.label + ";\n";
			}
			| E '-' E
			{
				$$.label = gentempcode();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
					" = " + $1.label + " - " + $3.label + ";\n";
			}
			| E '*' E
			{
				$$.label = gentempcode();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
					" = " + $1.label + " * " + $3.label + ";\n";
			}
			| E '/' E
			{
				$$.label = gentempcode();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
					" = " + $1.label + " / " + $3.label + ";\n";
			}
			| TK_ID '=' E
			{
				$$.traducao = $1.traducao + $3.traducao + "\t" + $1.label + " = " + $3.label + ";\n";
			}
			| TK_NUM
			{
				$$.tipo = INT;
				$$.label = gentempcode();
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_ID
			{
				bool found = false;
				TABELA_SIMBOLOS variavel;

				for(int i = 0; i < tabelaSimbolos.size(); i++) {
					if(tabelaSimbolos[i].nomeVariavel == $1.label) {
						variavel = tabelaSimbolos[i];
						found = true;
					}
				}

				if (!found) {
					yyerror("Variable is not declared.");
				}

				$$.tipo = variavel.tipoVariavel;
				$$.label = gentempcode();
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_FLOAT
			{
				$$.label = gentempcode();
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_CHAR
			{
				$$.label = gentempcode();
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			;

TYPE		: TK_TIPO_INT
			{
				$1.tipo = INT;
				$$ = $1;
			}
			| TK_TIPO_FLOAT
			{
				$1.tipo = FLOAT;
				$$ = $1;
			}
			| TK_TIPO_CHAR
			{
				$1.tipo = CHAR;
				$$ = $1;
			}
			;


%%

#include "lex.yy.c"

int yyparse();

string gentempcode() {

	var_temp_qnt++;
	return "t" + to_string(var_temp_qnt);
}

int main(int argc, char* argv[]) {

	var_temp_qnt = 0;

	yyparse();

	return 0;
}

void yyerror(string MSG) {
	
	cout << MSG << endl;
	exit (0);
}

