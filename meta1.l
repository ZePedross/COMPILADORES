%{
    /* place here any C variables and definitions */

    /*receba*/
    /*Ola*/
    
    #include <stdio.h>
    #include <ctype.h>

    int row = 1;
    int column = 1;

    void toUpper(char *s) {
        while (*s) {
            *s = toupper(*s);
            s++;
        }
    }



%}
digit   [0-9]
digit_octal [0-7]
hex_letter [a-fA-F]
letter [a-zA-Z]
KW break|default|interface|select|case|defer|go|map|struct|chan|goto|switch|const|fallthrough|range|type|continue|import|"++"|"--"
ignore " "|\t|\n


%X STRING
%%

"\""                            { BEGIN(STRING); printf("STRLIT(\""); column += yyleng; }
<STRING>[a-zA-Z0-9]             { printf("%s",yytext); column += yyleng; }
<STRING>\n                      { printf("\\n"); row++; column = 1; }
<STRING>\t                      { printf("\\t"); column += yyleng; }
<STRING>\f                      { printf("\\f"); column += yyleng; }
<STRING>\r                      { printf("\\r"); column += yyleng; }
<STRING>\\.                     { printf("Line %d, column %d: invalid escape sequence (%s)\n",row,column,yytext); column += yyleng; }
<STRING>"\""                    { BEGIN(INITIAL); printf("\")\n"); column += yyleng; }

{KW}                            { printf("%s\n", yytext); column += yyleng;}
{ignore}+                       { if (*yytext == '\n') { row++; column = 1; } else {column += yyleng;}}
[-|+]?({digit})*"."{digit}+([eE][+|-]?{digit}+)?     { printf("DECIMAL(%s)\n", yytext); column += yyleng; }
"-"                             { printf("MINUS\n"); column += yyleng;}
"+"                             { printf("PLUS\n"); column += yyleng;}
"*"                             { printf("STAR\n"); column += yyleng;}
"/"                             { printf("DIV\n"); column += yyleng;} 
"%"                             { printf("MOD\n"); column += yyleng;} 
","                             { printf("COMMA\n");column += yyleng;}
";"                             { printf("SEMICOLON\n"); column += yyleng;}
"_"                             { printf("BLANKID\n"); column += yyleng;}
"||"                            { printf("OR\n"); column += yyleng;}
"&&"                            { printf("AND\n"); column += yyleng;}
"=="                            { printf("EQ\n"); column += yyleng;}
"="                             { printf("ASSIGN\n"); column += yyleng;}
"!="                            { printf("NE\n"); column += yyleng;}
"!"                             { printf("NOT\n"); column += yyleng;}
">="                            { printf("GE\n"); column += yyleng;}
"<="                            { printf("LE\n"); column += yyleng;}
">"                             { printf("GT\n"); column += yyleng;}
"<"                             { printf("LT\n"); column += yyleng;}
"("                             { printf("LPAR\n"); column += yyleng;}
")"                             { printf("RPAR\n"); column += yyleng;}
"["                             { printf("LSQ\n"); column += yyleng;}
"]"                             { printf("RSQ\n"); column += yyleng;}
"{"                             { printf("LBRACE\n"); column += yyleng;}
"}"                             { printf("RBRACE\n"); column += yyleng;}
"package"                       { printf("PACKAGE\n"); column += yyleng;}
"return"                        { printf("RETURN\n"); column += yyleng;}
"else"                          { printf("ELSE\n"); column += yyleng;}
"for"                           { printf("FOR\n"); column += yyleng;}
"if"                            { printf("IF\n"); column += yyleng;}
"var"                           { printf("VAR\n"); column += yyleng;}
"int"                           { printf("INT\n"); column += yyleng;}
"float32"                       { printf("FLOAT32\n"); column += yyleng;}
"bool"                          { printf("BOOL\n"); column += yyleng;}
"string"                        { printf("STRING\n"); column += yyleng;}
"fmt.Println"                   { printf("PRINT\n"); column += yyleng;}
"strconv.Atoi"                  { printf("PARSEINT\n"); column += yyleng;}
"func"                          { printf("FUNC\n"); column += yyleng;}
"os.Args"                       { printf("CMDARGS\n"); column += yyleng;}
0{digit_octal}+                 { printf("OCTAL(%s)\n", yytext); column += yyleng; }
0([8|9]|{letter})+              { printf("Line (%i), column (%i): invalid octal constant (%s)\n", row,column,yytext); column += yyleng; }
0.*[xX]({digit}|{hex_letter})+  { printf("HEXADECIMAL(%s)\n", yytext); column += yyleng; }
{digit}+                        { printf("NATURAL(%s)\n", yytext); column += yyleng; }
{letter}({letter}|{digit}|"_")* { printf("IDENTIFIER(%s)\n", yytext); column += yyleng; }
.                               { printf("Line (%i), column (%i): illegal character (%s)\n", row,column,yytext);column += yyleng; }

%%
extern int yylex();
int main() {
    yylex();    /* run the lexical analysis automaton */
    return 0;
}
int yywrap() {  /* called on EOF, return 1 to terminate */
    return 1;
}