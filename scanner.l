%{

#include <stdio.h>
int num_lines = 0, nums_chars = 0 ;
char command[299];

%}

ws    [ \t]+
keyword    "for"|"do"|"while"|"break"|"continue"|"if"|"else"|"return"|"struct"|"switch"|"case"|"default"|"void"|"int"|"double"|"float"|"char"|"const"|"signed"|"unsigned"|"short"|"long"
macro    "NULL"|"__COUNTER__"|"__LINE__"|"INT_MAX"|"INT_MIN"|"CHAR_MAX"|"CHAR_MIN"|"MAX"|"MIN"
identifier    ([[:alpha:]]|\_)([[:alnum:]]|\_)*
char    '.'
string    \".*\"
integer    ([+/-]?[0-9]+)
minuszero    "-0."0*
float    [+/-]?(([[:digit:]]+\.[[:digit:]]*)|(\.[[:digit:]]+))
operator    ([+][+]?)|([-][-]?)|([|][|]?)|([&][&]?)|([=][=]?)|([!][=]?)|([<][=]?)|([>][=]?)|[*%]
punctuation    [:\;,\.\[\]\(\)\{\}]

%%
\n    { ++num_lines; printf("%d:%s\n", num_lines, command); memset(command, 0, sizeof(command));}
{ws}    { strcpy(command+strlen(command), yytext); }
{keyword}    { printf("#key:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{macro}    { printf("#macro:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{identifier}    { printf("#id:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{char}    { printf("#char:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{string}    { printf("#string:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{integer}    { if(yytext[0] == '-' && atoi(yytext) == 0) printf("#op:-\n#integer:0\n"); else printf("#integer:%d\n", atoi(yytext)); strcpy(command+strlen(command), yytext); }
{minuszero}    { printf("#op:-\n#float:%f\n", atof(yytext)); strcpy(command+strlen(command), yytext);}
{float}    { printf("#float:%f\n", atof(yytext)); strcpy(command+strlen(command), yytext); }
{operator}    { printf("#op:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{punctuation}    { printf("#punc:%s\n", yytext); strcpy(command+strlen(command), yytext); }
.    ;
%%

int main(int argc , char* argv[])
{
    ++argv;
    --argc ;
    if (0 < argc)
    {
        yyin = fopen(argv[0], "r");
    }
    else
    {
        yyin = stdin ;
    }
    yylex();
    printf("# of lines = %d, # of chars = %d\n", num_lines, nums_chars) ;
    return 0;
}