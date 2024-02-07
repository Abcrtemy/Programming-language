%{
#include "main.tab.h"
#include "string.h"

void yyerror(char *msg);
%}


DEVICE		[A-Z]+
ACTION		on|off

%%
turn			{yylval.tur = strdup(yytext); return turn;}

{DEVICE}		{yylval.dev = strdup(yytext); return device;}
{ACTION}		{yylval.act = strdup(yytext); return action;}
if			{yylval.iff = strdup(yytext); return iffs;}
[{}]			{yylval.brak = strdup(yytext); return bracket;}
[1-4]			{yylval.tim = yytext[0]; return time;}
<<EOF>>			{return end;}
[ \t\n]			{;}

.			{yyerror("Invalid");}
%%

int yywrap(void) {
	return 1;
}
