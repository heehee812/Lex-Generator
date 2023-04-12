%{

#include <stdio.h>
int num_lines = 0, nums_chars = 0 ;
char command[299];

%}

ws    [ \t]+
keyword    "for"|"do"|"while"|"break"|"continue"|"if"|"else"|"return"|"struct"|"switch"|"case"|"default"|"void"|"int"|"double"|"float"|"char"|"const"|"signed"|"unsigned"|"short"|"long"
macro    "NULL"|"__COUNTER__"|"__LINE__"|"INT_MAX"|"INT_MIN"|"CHAR_MAX"|"CHAR_MIN"|"MAX"|"MIN"
identifier    ([[:alpha:]]|\_)([[:alnum:]]|\_)*
char    ('.')|('([\\]([abefnrtv\\'\"\?]|([0-7][0-7]?[0-7]?)|(x[0-9A-Fa-f]+)|(u[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])|(U[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])))')
string    \"[^\"\\]*(\\.*)*\"
integer    ([+/-]?[0-9]+)
float    [+/-]?(([[:digit:]]+\.[[:digit:]]*)|(\.[[:digit:]]+))
operator    ([+][+]?)|([-][-]?)|([|][|]?)|([&][&]?)|([=][=]?)|([!][=]?)|([<][=]?)|([>][=]?)|[*%\/]
punctuation    [:\;,\.\[\]\(\)\{\}]
%x    CMNT
%x    CMNTEXP
%x    TOKENOFF
%x    SOURCEOFF
%x    SOURCETOKENOFF

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
"//"    {BEGIN CMNTEXP; strcpy(command+strlen(command), yytext); }
<CMNTEXP>\\+\n    { ++num_lines; strcpy(command+strlen(command), yytext); printf("%d:%s", num_lines, command); memset(command, 0, sizeof(command)); }
<CMNTEXP>\n    { BEGIN INITIAL; ++num_lines; printf("%d:%s\n", num_lines, command); memset(command, 0, sizeof(command)); }
<CMNTEXP>.    { strcpy(command+strlen(command), yytext); }
"/*"    { BEGIN CMNT; strcpy(command+strlen(command), yytext); }
<CMNT>.    { strcpy(command+strlen(command), yytext); }
<CMNT>\n    { ++num_lines; printf("%d:%s\n", num_lines, command); memset(command, 0, sizeof(command)); }
<CMNT>"*/"    { BEGIN INITIAL; strcpy(command+strlen(command), yytext); }
"#pragma"[ \t]+("source"|"token")[ \t]+"on"[ \t]*    { strcpy(command+strlen(command), yytext); }
"#pragma"[ \t]+"source"[ \t]+"off"[ \t]*    { BEGIN SOURCEOFF; memset(command, 0, sizeof(command)); }
<SOURCEOFF>\n    { ++num_lines; }
<SOURCEOFF>"#pragma"[ \t]+"token"[ \t]+"off"[ \t]*    { BEGIN SOURCETOKENOFF; memset(command, 0, sizeof(command)); }
<SOURCETOKENOFF>\n    { ++num_lines; }
<SOURCETOKENOFF>{ws}|{keyword}|{macro}|{identifier}|{char}|{string}|{integer}|{float}|{operator}|{punctuation}|("//".*)|("/*"[.|\n]*"*/")|("#pragma"[ \t]+("token"|"source")[ \t]+"off"[ \t]*)    ;
<SOURCETOKENOFF>"#pragma"[ \t]+"token"[ \t]+"on"[ \t]*    { BEGIN SOURCEOFF; }
<SOURCETOKENOFF>[ \t]*"#pragma"[ \t]+"source"[ \t]+"on"[ \t]*    { BEGIN TOKENOFF; strcpy(command+strlen(command), yytext); }
<SOURCEOFF>{ws}|("//".*)|("/*"[.|\n]*"*/")|("#pragma"[ \t]+"token"[ \t]+"on"[ \t]*)|("#pragma"[ \t]+"source"[ \t]+"off"[ \t]*)    ;
<SOURCEOFF>{keyword}    { printf("#key:%s\n", yytext); }
<SOURCEOFF>{macro}    { printf("#macro:%s\n", yytext); }
<SOURCEOFF>{identifier}    { printf("#id:%s\n", yytext); }
<SOURCEOFF>{char}    { printf("#char:%s\n", yytext); }
<SOURCEOFF>{string}    { printf("#string:%s\n", yytext); }
<SOURCEOFF>{integer}    { printf("#integer:%s\n", yytext); }
<SOURCEOFF>{float}    { printf("#float:%s\n", yytext); }
<SOURCEOFF>{operator}    { printf("#op:%s\n", yytext); }
<SOURCEOFF>{punctuation}    { printf("#punc:%s\n", yytext); }
<SOURCEOFF>[ \t]*"#pragma"[ \t]+"source"[ \t]+"on"[ \t]*    { BEGIN INITIAL; strcpy(command+strlen(command), yytext); }
"#pragma"[ \t]+"token"[ \t]+"off"[ \t]*    { BEGIN TOKENOFF; strcpy(command+strlen(command), yytext); }
<TOKENOFF>{ws}|{keyword}|{macro}|{identifier}|{char}|{string}|{integer}|{float}|{operator}|{punctuation}|("#pragma"[ \t]+"source"|[ \t]+"on"[ \t]*)|("#pragma"[ \t]+"token"|[ \t]+"off"[ \t]*)    { strcpy(command+strlen(command), yytext); }
<TOKENOFF>\n    { ++num_lines; printf("%d:%s\n", num_lines, command); memset(command, 0, sizeof(command)); }
<TOKENOFF>"#pragma"[ \t]+"source"[ \t]+"off"[ \t]*    { BEGIN SOURCETOKENOFF; memset(command, 0, sizeof(command)); }
<TOKENOFF>[ \t]*"#pragma"[ \t]+"token"[ \t]+"on"[ \t]*    { BEGIN INITIAL; strcpy(command+strlen(command), yytext); }
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