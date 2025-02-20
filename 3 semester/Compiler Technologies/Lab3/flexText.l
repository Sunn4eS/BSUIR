%option main

%{
#include <stdio.h>
int lineno = 1;
int column = 1;

%}

ECH    echo
SMCOL   ;
COND    [0-9]
NEXT    \n|\t|\r\n
LIT     \".*\"

%%
{NEXT}  {printf("0\n");}
[ ]     {printf("1\n");}
"<?"   {printf("2\n");}
"?>"    {printf("3\n");}
php     {printf("4\n");}
[(]     {printf("5\n");}
[)]     {printf("6\n");}
[{]     {printf("7\n");}
[}]     {printf("8\n");}
{ECH}   {printf("9\n");}
if      {printf("10\n");}
{COND}  {printf("11\n");}
else    {printf("12\n");}
while   {printf("13\n");}
{LIT}   {printf("14\n");}
{SMCOL} {printf("15\n");}

%%