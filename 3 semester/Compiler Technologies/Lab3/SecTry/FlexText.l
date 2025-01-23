%{
#include <stdio.h>
int lineno = 1;
int column = 1;
%}

%option noyywrap

ECH      echo
SMCOL    ;
COND     [0-9]

NEXT     \n|\t|\r\n
LIT      \".*\"

%%
{NEXT}    { if (yytext[0] == '\n') { lineno++; column = 1; } else { column += yyleng; } printf("0 %d %d\n", lineno, column); }
[ ]       { column += yyleng; printf("1 %d %d\n", lineno, column); }
"<?"      { column += yyleng; printf("2 %d %d\n", lineno, column); }
"?>"      { column += yyleng; printf("3 %d %d\n", lineno, column); }
php       { column += yyleng; printf("4 %d %d\n", lineno, column); }
[(]       { column += yyleng; printf("5 %d %d\n", lineno, column); }
[)]       { column += yyleng; printf("6 %d %d\n", lineno, column); }
[{]       { column += yyleng; printf("7 %d %d\n", lineno, column); }
[}]       { column += yyleng; printf("8 %d %d\n", lineno, column); }
{ECH}     { column += yyleng; printf("9 %d %d\n", lineno, column); }
if        { column += yyleng; printf("10 %d %d\n", lineno, column); }
{COND}    { column += yyleng; printf("11 %d %d\n", lineno, column); }
else      { column += yyleng; printf("12 %d %d\n", lineno, column); }
while     { column += yyleng; printf("13 %d %d\n", lineno, column); }
{LIT}     { column += yyleng; printf("14 %d %d\n", lineno, column); }
{SMCOL}   { column += yyleng; printf("15 %d %d\n", lineno, column); }
%%

int main(int argc, char **argv) {
    yylex();
    return 0;
}
