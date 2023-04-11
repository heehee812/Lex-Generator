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
%x    CMNT
%x    PRAG

%%
\n    { ++num_lines; printf("%d:%s\n", num_lines, command); memset(command, 0, sizeof(command));}
{ws}    { strcpy(command+strlen(command), yytext); }
{keyword}    { printf("#key:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{macro}    { printf("#macro:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{identifier}    { printf("#id:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{char}    { printf("#char:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{string}    { printf("#string:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{integer}    { if(yytext[0] == '-' && atoi(yytext) == 0) printf("#op:-\n#integer:0\n"); else printf("#integer:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{minuszero}    { printf("#op:-\n#float:%f\n", atof(yytext)); strcpy(command+strlen(command), yytext);}
{float}    { printf("#float:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{operator}    { printf("#op:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{punctuation}    { printf("#punc:%s\n", yytext); strcpy(command+strlen(command), yytext); }
"/*"    { BEGIN CMNT; strcpy(command+strlen(command), yytext); }
<CMNT>.    { strcpy(command+strlen(command), yytext); }
<CMNT>\n    { ++num_lines; printf("%d:%s\n", num_lines, command); memset(command, 0, sizeof(command)); }
<CMNT>"*/"    { BEGIN INITIAL; strcpy(command+strlen(command), yytext); }
"#pragma"[ \t]+("source"|"token")[ \t]+"on"[ \t]*    { strcpy(command+strlen(command), yytext); printf("%d:%s\n", num_lines, command); }
"#pragma"[ \t]+"source"[ \t]+"off"[ \t]*    { memset(command, 0, sizeof(command)); }
"#pragma"[ \t]+"token"[ \t]+"off"[ \t]*    {BEGIN PRAG; strcpy(command+strlen(command), yytext); }
<PRAG>{ws}|{keyword}|{macro}|{identifier}|{char}|{string}|{integer}|{minuszero}|{float}|{operator}|{punctuation}    { strcpy(command+strlen(command), yytext); }
<PRAG>\n    { ++num_lines; printf("%d:%s\n", num_lines, command); memset(command, 0, sizeof(command)); }
<PRAG>"#pragma"[ \t]+"token"[ \t]+"on"[ \t]*    { BEGIN INITIAL; strcpy(command+strlen(command), yytext); }
.    { printf("error"); exit(1); }

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
    return 0;
}