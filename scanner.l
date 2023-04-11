%{

#include <stdio.h>
int num_lines = 0, nums_chars = 0 ;
char command[299];

%}

ws    [ \t]+
keyword    "for"|"do"|"while"|"break"|"continue"|"if"|"else"|"return"|"struct"|"switch"|"case"|"default"|"void"|"int"|"double"|"float"|"char"|"const"|"signed"|"unsigned"|"short"|"long"

%%
\n { ++num_lines; printf("%d:%s\n", num_lines, command); }
{ws} { strcpy(command+strlen(command), yytext); }
{keyword} { printf("#key:%s\n", yytext); strcpy(command+strlen(command), yytext); }
. ;
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