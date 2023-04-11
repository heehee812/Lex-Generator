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
float    [+/-]?(([[:digit:]]+\.[[:digit:]]*)|(\.[[:digit:]]+))
operator    ([+][+]?)|([-][-]?)|([|][|]?)|([&][&]?)|([=][=]?)|([!][=]?)|([<][=]?)|([>][=]?)|[*%\/]
punctuation    [:\;,\.\[\]\(\)\{\}]
%x    CMNT
%x    PRAGTOKEN
%x    PRAGSOURCE

%%
\n    { ++num_lines; printf("%d:%s\n", num_lines, command); memset(command, 0, sizeof(command));}
{ws}    { strcpy(command+strlen(command), yytext); }
{keyword}    { printf("#key:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{macro}    { printf("#macro:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{identifier}    { printf("#id:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{char}    { printf("#char:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{string}    { printf("#string:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{integer}    { printf("#integer:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{float}    { printf("#float:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{operator}    { printf("#op:%s\n", yytext); strcpy(command+strlen(command), yytext); }
{punctuation}    { printf("#punc:%s\n", yytext); strcpy(command+strlen(command), yytext); }
"//".*    { strcpy(command+strlen(command), yytext); }
"/*"    { BEGIN CMNT; strcpy(command+strlen(command), yytext); }
<CMNT>.    { strcpy(command+strlen(command), yytext); }
<CMNT>\n    { ++num_lines; printf("%d:%s\n", num_lines, command); memset(command, 0, sizeof(command)); }
<CMNT>"*/"    { BEGIN INITIAL; strcpy(command+strlen(command), yytext); }
"#pragma"[ \t]+("source"|"token")[ \t]+"on"[ \t]*    { strcpy(command+strlen(command), yytext); }
"#pragma"[ \t]+"source"[ \t]+"off"[ \t]*    { BEGIN PRAGSOURCE; }    
<PRAGSOURCE>\n|{ws}    ;
<PRAGSOURCE>{keyword}    { printf("#key:%s\n", yytext); }
<PRAGSOURCE>{macro}    { printf("#macro:%s\n", yytext); }
<PRAGSOURCE>{identifier}    { printf("#id:%s\n", yytext); }
<PRAGSOURCE>{char}    { printf("#char:%s\n", yytext); }
<PRAGSOURCE>{string}    { printf("#string:%s\n", yytext); }
<PRAGSOURCE>{integer}    { printf("#integer:%s\n", yytext); }
<PRAGSOURCE>{float}    { printf("#float:%s\n", yytext); }
<PRAGSOURCE>{operator}    { printf("#op:%s\n", yytext); }
<PRAGSOURCE>{punctuation}    { printf("#punc:%s\n", yytext); }
<PRAGSOURCE>"#pragma"[ \t]+"source"[ \t]+"on"[ \t]*    { BEGIN INITIAL; strcpy(command+strlen(command), yytext); }
"#pragma"[ \t]+"token"[ \t]+"off"[ \t]*    { BEGIN PRAGTOKEN; strcpy(command+strlen(command), yytext); }
<PRAGTOKEN>{ws}|{keyword}|{macro}|{identifier}|{char}|{string}|{integer}|{float}|{operator}|{punctuation}    { strcpy(command+strlen(command), yytext); }
<PRAGTOKEN>\n    { ++num_lines; printf("%d:%s\n", num_lines, command); memset(command, 0, sizeof(command)); }
<PRAGTOKEN>"#pragma"[ \t]+"source"|[ \t]+"on"[ \t]*    { strcpy(command+strlen(command), yytext); }
<PRAGTOKEN>"#pragma"[ \t]+"source"[ \t]+"off"[ \t]*\n    { memset(command, 0, sizeof(command)); }
<PRAGTOKEN>"#pragma"[ \t]+"token"[ \t]+"on"[ \t]*    { BEGIN INITIAL; strcpy(command+strlen(command), yytext); }
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