%{
#include <iostream>
#include <string>
#include <sstream>    

#define YYSTYPE atributos // n sei pq mas pediu pra definir 
    
using namespace std;

int var_temp_qnt;

struct atributos // distinguir entre o tipo de texto que eu vou receber e retornar.
{
	string l;
	string t; // nas palavras do braida: "meu codigo gerado ate aquele momento."
};

int yylex(void);
void yyerror(string); // fala quando tem erro
string gentempcode(); // ainda n sei

%}
//definindo tokens

%token TK_NUM TK_ID
%token TK_MAIN
%token TK_TIPO_INT  

//nao terminal que ira iniciar a producao
%start START

%%

START       : TK_TIPO_INT TK_MAIN '(' ')' BLOCO
            {
                string codigo = "\n Compilador OASIS \n\n"
                                "#include <stdio.h>\n"
                                "int main(void) {\n";

				codigo += $5.t;
								
				codigo += 	"\treturn 0;"
							"\n}";

				cout << codigo << endl;                                        
            }
            ;

BLOCO       : '{' COMANDOS '}'
            {
                $$.t = $2.t;
            }
            ;

COMANDOS    : COMANDO COMANDOS
            {
                $$.t = $1.t + $2.t;
            }
            |
            {
                $$.t = "";
            }
            ;

COMANDO     : E ';'
            {
                $$ = $1;
            }
            ;

E 			: E '+' E
			{
				$$.l = gentempcode();
				$$.t = $1.t + $3.t + "\t" + 
                $$.l + " = " + $1.l + " + " + $3.l + ";\n";
			}
            | E '-' E
            {
                $$.l = gentempcode();
                $$.t = $1.t + $3.t + "\t" + 
                $$.l + " = " + $1.l + " - " + $3.l + ";\n";
            }
            | TK_ID '=' E 
            {
                $$.t = $1.t + $3.t +
                 "\t" + $1.l + " = " + $3.l + ";\n";
            }
            | TK_ID
            {
                $$.l = gentempcode();
                $$.t = "\t" + $$.l + " = " + $1.l + ";\n";
            }
            | TK_NUM
            {
                $$.l = gentempcode();
                $$.t = "\t" + $$.l + " = " + $1.l + ";\n";
            }
			;

%%

#include "lex.yy.c"

int yyparse();

string gentempcode()
{
	var_temp_qnt++;
	return "t" + to_string(var_temp_qnt);
}

int main(int argc, char* argv[])
{
    var_temp_qnt = 0;

    yyparse();

	return 0;
}

void yyerror(string MSG)
{
	cout << MSG << endl;
	exit (0);
}				
