%{

#include <stdio.h>
int num_lines = 0, nums_chars = 0 ;
char command[299];

%}

ws    [ /t]+

%%
{ws} ;
\n {++num_lines ;printf("%s\n", command);}
([[:alpha:]]|[ ])* {strcpy(command, yytext);}

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
