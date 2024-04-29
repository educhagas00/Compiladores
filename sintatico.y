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
	CHAR = 2,
	BOOL = 3
};

std::string tipoParaString(TipoVariavel tipo) {
	
    switch (tipo) {
        case INT:
            return "int";
        case FLOAT:
            return "float";
        case CHAR:
            return "char";
		case BOOL:
			return "bool";
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
void addTabela(TABELA_SIMBOLOS simbolo, TipoVariavel tipo, string nome);
%}


%token TK_MAIN
%token TK_NUM TK_ID TK_FLOAT TK_CHAR TK_BOOL TK_RELOP
%token TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_CHAR TK_TIPO_BOOL
%token TK_FIM TK_ERROR
%token TK_EQ TK_NE TK_LT TK_GT TK_LE TK_GE TK_AND TK_OR TK_NOT

%start S

%left '+'

%%

S 			: TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				string codigo = "/*Compilador OASIS*/\n"
								"#include <iostream>\n"
								"#include <string.h>\n"
								"#include <stdio.h>\n"
								"#define bool int\n"
								"#define False 0\n"
								"#define True 1\n"
								"int main(void) {\n";
				for (auto it = tabelaSimbolos.begin(); it != tabelaSimbolos.end(); it++) {
					codigo += "\t" + tipoParaString(it->tipoVariavel) + " " + it->nomeVariavel + ";\n";
				}
				codigo += "\n" + $5.traducao;
								
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
				TABELA_SIMBOLOS simbolo;
				addTabela(simbolo, $1.tipo, $2.label);

				// cout << tipoParaString($1.tipo) << endl;
				// cout << $2.label << endl;
				
				// $$.traducao = "\t" + $1.label + " " + $2.label + ";\n";
			}
			| TK_ID '=' E ';'
			{
				$$.traducao = $1.traducao + $3.traducao + "\t" + $1.label + " = " + $3.label + ";\n";
			}
			;

E 			: E '+' E
			{
				// cout << "Tipo soma 1: " << tipoParaString($1.tipo) << endl;
				// cout << "Tipo soma 2: " << tipoParaString($3.tipo) << endl;

				if ($1.tipo != $3.tipo) {
					
					if($1.tipo == INT && $3.tipo == FLOAT) {
						TABELA_SIMBOLOS c;
						string cast = gentempcode();
						addTabela(c, FLOAT, cast);

						TABELA_SIMBOLOS l;
						$$.label = gentempcode();
						addTabela(l, FLOAT, $$.label);

						$$.traducao = $1.traducao + $3.traducao + "\t" + cast + " = (float) " + $1.label + ";\n" + "\t" + $$.label +
					    " = " + cast + " + " + $3.label + ";\n";
					}
					
					else if ($1.tipo == FLOAT && $3.tipo == INT) {
						TABELA_SIMBOLOS c;
						string cast = gentempcode();
						addTabela(c, FLOAT, cast);
						
						TABELA_SIMBOLOS l;
						$$.label = gentempcode();
						addTabela(l, FLOAT, $$.label);
						
						$$.traducao = $1.traducao + $3.traducao + "\t" + cast + " = (float) " + $3.label + ";\n" + "\t" + $$.label +
						" = " + $1.label + " + " + cast + ";\n";
					}
				}

				else if ($1.tipo == $3.tipo) {
					$$.label = gentempcode();
					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					 " = " + $1.label +  " + "  + $3.label + ";\n";
					TABELA_SIMBOLOS s;
					addTabela(s, $1.tipo, $$.label);
				}

				else {
					yyerror("Invalid operation.");
				}
			}

			| E '-' E
			{
				if ($1.tipo != $3.tipo) {
					
					if($1.tipo == INT && $3.tipo == FLOAT) {
						TABELA_SIMBOLOS c;
						string cast = gentempcode();
						addTabela(c, FLOAT, cast);

						TABELA_SIMBOLOS l;
						$$.label = gentempcode();
						addTabela(l, FLOAT, $$.label);

						$$.traducao = $1.traducao + $3.traducao + "\t" + cast + " = (float) " + $1.label + ";\n" + "\t" + $$.label +
					    " = " + cast + " - " + $3.label + ";\n";
					}
					
					else if ($1.tipo == FLOAT && $3.tipo == INT) {
						TABELA_SIMBOLOS c;
						string cast = gentempcode();
						addTabela(c, FLOAT, cast);
						
						TABELA_SIMBOLOS l;
						$$.label = gentempcode();
						addTabela(l, FLOAT, $$.label);
						
						$$.traducao = $1.traducao + $3.traducao + "\t" + cast + " = (float) " + $3.label + ";\n" + "\t" + $$.label +
						" = " + $1.label + " - " + cast + ";\n";
					}
				}

				else if ($1.tipo == $3.tipo) {
					$$.label = gentempcode();
					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					 " = " + $1.label +  " - "  + $3.label + ";\n";
					TABELA_SIMBOLOS s;
					addTabela(s, $1.tipo, $$.label);
				}

				else {
					yyerror("Invalid operation.");
				}
			}
			| E '*' E
			{
				if ($1.tipo != $3.tipo) {
					
					if($1.tipo == INT && $3.tipo == FLOAT) {
						TABELA_SIMBOLOS c;
						string cast = gentempcode();
						addTabela(c, FLOAT, cast);

						TABELA_SIMBOLOS l;
						$$.label = gentempcode();
						addTabela(l, FLOAT, $$.label);

						$$.traducao = $1.traducao + $3.traducao + "\t" + cast + " = (float) " + $1.label + ";\n" + "\t" + $$.label +
					    " = " + cast + " * " + $3.label + ";\n";
					}
					
					else if ($1.tipo == FLOAT && $3.tipo == INT) {
						TABELA_SIMBOLOS c;
						string cast = gentempcode();
						addTabela(c, FLOAT, cast);
						
						TABELA_SIMBOLOS l;
						$$.label = gentempcode();
						addTabela(l, FLOAT, $$.label);
						
						$$.traducao = $1.traducao + $3.traducao + "\t" + cast + " = (float) " + $3.label + ";\n" + "\t" + $$.label +
						" = " + $1.label + " * " + cast + ";\n";
					}
				}

				else if ($1.tipo == $3.tipo) {
					$$.label = gentempcode();
					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					 " = " + $1.label +  " * "  + $3.label + ";\n";
					TABELA_SIMBOLOS s;
					addTabela(s, $1.tipo, $$.label);
				}

				else {
					yyerror("Invalid operation.");
				}
			}
			| E '/' E
			{
				if ($1.tipo != $3.tipo) {
					
					if($1.tipo == INT && $3.tipo == FLOAT) {
						TABELA_SIMBOLOS c;
						string cast = gentempcode();
						addTabela(c, FLOAT, cast);

						TABELA_SIMBOLOS l;
						$$.label = gentempcode();
						addTabela(l, FLOAT, $$.label);

						$$.traducao = $1.traducao + $3.traducao + "\t" + cast + " = (float) " + $1.label + ";\n" + "\t" + $$.label +
					    " = " + cast + " / " + $3.label + ";\n";
					}
					
					else if ($1.tipo == FLOAT && $3.tipo == INT) {
						TABELA_SIMBOLOS c;
						string cast = gentempcode();
						addTabela(c, FLOAT, cast);
						
						TABELA_SIMBOLOS l;
						$$.label = gentempcode();
						addTabela(l, FLOAT, $$.label);
						
						$$.traducao = $1.traducao + $3.traducao + "\t" + cast + " = (float) " + $3.label + ";\n" + "\t" + $$.label +
						" = " + $1.label + " / " + cast + ";\n";
					}
				}

				else if ($1.tipo == $3.tipo) {
					$$.label = gentempcode();
					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					 " = " + $1.label +  " / "  + $3.label + ";\n";
					TABELA_SIMBOLOS s;
					addTabela(s, $1.tipo, $$.label);
				}

				else {
					yyerror("Invalid operation.");
				}
			}

			| E TK_EQ E
			{
				if ($1.tipo != $3.tipo) {
					
					if($1.tipo == INT && $3.tipo == FLOAT) {
						TABELA_SIMBOLOS c;
						string cast = gentempcode();
						addTabela(c, FLOAT, cast);

						TABELA_SIMBOLOS l;
						$$.label = gentempcode();
						addTabela(l, FLOAT, $$.label);

						$$.traducao = $1.traducao + $3.traducao + "\t" + cast + " = (float) " + $1.label + ";\n" + "\t" + $$.label +
					    " = " + cast + " == " + $3.label + ";\n";
					}
					
					else if ($1.tipo == FLOAT && $3.tipo == INT) {
						TABELA_SIMBOLOS c;
						string cast = gentempcode();
						addTabela(c, FLOAT, cast);
						
						TABELA_SIMBOLOS l;
						$$.label = gentempcode();
						addTabela(l, FLOAT, $$.label);
						
						$$.traducao = $1.traducao + $3.traducao + "\t" + cast + " = (float) " + $3.label + ";\n" + "\t" + $$.label +
						" = " + $1.label + " == " + cast + ";\n";
					}
				}

				else if ($1.tipo == $3.tipo) {
					$$.label = gentempcode();
					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					 " = " + $1.label +  " == "  + $3.label + ";\n";
					TABELA_SIMBOLOS s;
					addTabela(s, $1.tipo, $$.label);
				}

				else {
					yyerror("Invalid operation.");
				}
			}
			| E TK_NE E
			{
					if ($1.tipo != $3.tipo) {
					
					if($1.tipo == INT && $3.tipo == FLOAT) {
						TABELA_SIMBOLOS c;
						string cast = gentempcode();
						addTabela(c, FLOAT, cast);

						TABELA_SIMBOLOS l;
						$$.label = gentempcode();
						addTabela(l, FLOAT, $$.label);

						$$.traducao = $1.traducao + $3.traducao + "\t" + cast + " = (float) " + $1.label + ";\n" + "\t" + $$.label +
					    " = " + cast + " != " + $3.label + ";\n";
					}
					
					else if ($1.tipo == FLOAT && $3.tipo == INT) {
						TABELA_SIMBOLOS c;
						string cast = gentempcode();
						addTabela(c, FLOAT, cast);
						
						TABELA_SIMBOLOS l;
						$$.label = gentempcode();
						addTabela(l, FLOAT, $$.label);
						
						$$.traducao = $1.traducao + $3.traducao + "\t" + cast + " = (float) " + $3.label + ";\n" + "\t" + $$.label +
						" = " + $1.label + " != " + cast + ";\n";
					}
				}

				else if ($1.tipo == $3.tipo) {
					$$.label = gentempcode();
					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					 " = " + $1.label +  " != "  + $3.label + ";\n";
					TABELA_SIMBOLOS s;
					addTabela(s, $1.tipo, $$.label);
				}

				else {
					yyerror("Invalid operation.");
				}

			}
			| E TK_LT E
			{
					if ($1.tipo != $3.tipo) {
					
					if($1.tipo == INT && $3.tipo == FLOAT) {
						TABELA_SIMBOLOS c;
						string cast = gentempcode();
						addTabela(c, FLOAT, cast);

						TABELA_SIMBOLOS l;
						$$.label = gentempcode();
						addTabela(l, FLOAT, $$.label);

						$$.traducao = $1.traducao + $3.traducao + "\t" + cast + " = (float) " + $1.label + ";\n" + "\t" + $$.label +
					    " = " + cast + " < " + $3.label + ";\n";
					}
					
					else if ($1.tipo == FLOAT && $3.tipo == INT) {
						TABELA_SIMBOLOS c;
						string cast = gentempcode();
						addTabela(c, FLOAT, cast);
						
						TABELA_SIMBOLOS l;
						$$.label = gentempcode();
						addTabela(l, FLOAT, $$.label);
						
						$$.traducao = $1.traducao + $3.traducao + "\t" + cast + " = (float) " + $3.label + ";\n" + "\t" + $$.label +
						" = " + $1.label + " < " + cast + ";\n";
					}
				}

				else if ($1.tipo == $3.tipo) {
					$$.label = gentempcode();
					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					 " = " + $1.label +  " < "  + $3.label + ";\n";
					TABELA_SIMBOLOS s;
					addTabela(s, $1.tipo, $$.label);
				}

				else {
					yyerror("Invalid operation.");
				}

			}
			| E TK_GT E
			{
					if ($1.tipo != $3.tipo) {
					
					if($1.tipo == INT && $3.tipo == FLOAT) {
						TABELA_SIMBOLOS c;
						string cast = gentempcode();
						addTabela(c, FLOAT, cast);

						TABELA_SIMBOLOS l;
						$$.label = gentempcode();
						addTabela(l, FLOAT, $$.label);

						$$.traducao = $1.traducao + $3.traducao + "\t" + cast + " = (float) " + $1.label + ";\n" + "\t" + $$.label +
					    " = " + cast + " > " + $3.label + ";\n";
					}
					
					else if ($1.tipo == FLOAT && $3.tipo == INT) {
						TABELA_SIMBOLOS c;
						string cast = gentempcode();
						addTabela(c, FLOAT, cast);
						
						TABELA_SIMBOLOS l;
						$$.label = gentempcode();
						addTabela(l, FLOAT, $$.label);
						
						$$.traducao = $1.traducao + $3.traducao + "\t" + cast + " = (float) " + $3.label + ";\n" + "\t" + $$.label +
						" = " + $1.label + " > " + cast + ";\n";
					}
				}

				else if ($1.tipo == $3.tipo) {
					$$.label = gentempcode();
					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					 " = " + $1.label +  " > "  + $3.label + ";\n";
					TABELA_SIMBOLOS s;
					addTabela(s, $1.tipo, $$.label);
				}

				else {
					yyerror("Invalid operation.");
				}

			}
			| E TK_LE E
			{
					if ($1.tipo != $3.tipo) {
					
					if($1.tipo == INT && $3.tipo == FLOAT) {
						TABELA_SIMBOLOS c;
						string cast = gentempcode();
						addTabela(c, FLOAT, cast);

						TABELA_SIMBOLOS l;
						$$.label = gentempcode();
						addTabela(l, FLOAT, $$.label);

						$$.traducao = $1.traducao + $3.traducao + "\t" + cast + " = (float) " + $1.label + ";\n" + "\t" + $$.label +
					    " = " + cast + " <= " + $3.label + ";\n";
					}
					
					else if ($1.tipo == FLOAT && $3.tipo == INT) {
						TABELA_SIMBOLOS c;
						string cast = gentempcode();
						addTabela(c, FLOAT, cast);
						
						TABELA_SIMBOLOS l;
						$$.label = gentempcode();
						addTabela(l, FLOAT, $$.label);
						
						$$.traducao = $1.traducao + $3.traducao + "\t" + cast + " = (float) " + $3.label + ";\n" + "\t" + $$.label +
						" = " + $1.label + " <= " + cast + ";\n";
					}
				}

				else if ($1.tipo == $3.tipo) {
					$$.label = gentempcode();
					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					 " = " + $1.label +  " <= "  + $3.label + ";\n";
					TABELA_SIMBOLOS s;
					addTabela(s, $1.tipo, $$.label);
				}

				else {
					yyerror("Invalid operation.");
				}

			}
			| E TK_GE E
			{
					if ($1.tipo != $3.tipo) {
					
					if($1.tipo == INT && $3.tipo == FLOAT) {
						TABELA_SIMBOLOS c;
						string cast = gentempcode();
						addTabela(c, FLOAT, cast);

						TABELA_SIMBOLOS l;
						$$.label = gentempcode();
						addTabela(l, FLOAT, $$.label);

						$$.traducao = $1.traducao + $3.traducao + "\t" + cast + " = (float) " + $1.label + ";\n" + "\t" + $$.label +
					    " = " + cast + " >= " + $3.label + ";\n";
					}
					
					else if ($1.tipo == FLOAT && $3.tipo == INT) {
						TABELA_SIMBOLOS c;
						string cast = gentempcode();
						addTabela(c, FLOAT, cast);
						
						TABELA_SIMBOLOS l;
						$$.label = gentempcode();
						addTabela(l, FLOAT, $$.label);
						
						$$.traducao = $1.traducao + $3.traducao + "\t" + cast + " = (float) " + $3.label + ";\n" + "\t" + $$.label +
						" = " + $1.label + " >= " + cast + ";\n";
					}
				}

				else if ($1.tipo == $3.tipo) {
					$$.label = gentempcode();
					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					 " = " + $1.label +  " >= "  + $3.label + ";\n";
					TABELA_SIMBOLOS s;
					addTabela(s, $1.tipo, $$.label);
				}

				else {
					yyerror("Invalid operation.");
				}
        
			| E TK_AND E
			{
				if ($1.tipo != BOOL || $3.tipo != BOOL)
				{
					yyerror("Invalid Operation. Please, reconsider using bool.");
				}
				else
				{
					$$.label = gentempcode();
					$$.traducao = $1.traducao + $3.traducao + "\t" + 
					$$.label + " = " + $1.label + " && " + $3.label + ";\n";
					TABELA_SIMBOLOS s;
					addTabela(s, $1.tipo, $$.label);
				}
			}
			| E TK_OR E
			{
				if ($1.tipo != BOOL || $3.tipo != BOOL)
				{
					yyerror("Invalid Operation. Please, reconsider using bool.");
				}
				else
				{
					$$.label = gentempcode();
					$$.traducao = $1.traducao + $3.traducao + "\t" + 
					$$.label + " = " + $1.label + " || " + $3.label + ";\n";
					TABELA_SIMBOLOS s;
					addTabela(s, $1.tipo, $$.label);
				}
			}
			| TK_NOT E 
			{
				if($2.tipo != BOOL)
				{
					yyerror("Invalid Operation. Please, reconsider using bool.");
				}
				else
				{
					$$.label = gentempcode();
					$$.traducao = $2.traducao + "\t" + $$.label +
					" = !" + $2.label + ";\n"; 
					TABELA_SIMBOLOS s;
					addTabela(s, $1.tipo, $$.label);
				}
			}
			| TK_NUM
			{
				$$.tipo = INT;
				$$.label = gentempcode();

				TABELA_SIMBOLOS simbolo;
				addTabela(simbolo, $$.tipo, $$.label);

				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_ID
			{
				bool found = false;
				TABELA_SIMBOLOS variavel;

				// cout << "IDDDDDDDDDDDDDDDDDDD" << endl;

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

				TABELA_SIMBOLOS simbolo;
				addTabela(simbolo, $$.tipo, $$.label);

				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_FLOAT
			{
				$$.tipo = FLOAT;
				$$.label = gentempcode();

				TABELA_SIMBOLOS simbolo;
				addTabela(simbolo, $$.tipo, $$.label);

				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| '\'' TK_CHAR '\''
			{
				$$.label = gentempcode();
				// cout << "OIIIIIIIIIIIIIIIIIIIIIIIIIIII" << endl;
				if ($1.label.length() > 1) {
					yyerror("Is not char");
				}

				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			|	TK_BOOL
			{
				$$.tipo = BOOL;
				$$.label = gentempcode();

				TABELA_SIMBOLOS simbolo;
				addTabela(simbolo, $$.tipo, $$.label);
				
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
			| TK_TIPO_BOOL
			{
				$1.tipo = BOOL;
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

void addTabela(TABELA_SIMBOLOS simbolo, TipoVariavel tipo, string nome) {
	simbolo.tipoVariavel = tipo;
	simbolo.nomeVariavel = nome;

	tabelaSimbolos.push_back(simbolo);
}