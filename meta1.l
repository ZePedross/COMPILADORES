%{
    /* place here any C variables and definitions */
    #include <stdio.h>
    #include <ctype.h>
    #include <string.h>

    int row = 1;
    int column = 1;
    int semicolon = 0;

    char string[1024];

    void toUpper(char *s) {
        while (*s) {
            *s = toupper(*s);
            s++;
        }
    }

    void check_semicolon() {
        if (semicolon == 1) {
            printf("SEMICOLON\n");
            row++;
            column = 1;
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
%X COMMENT
%X COMMENT2
%%

"/*"                            { BEGIN(COMMENT); column += yyleng; } /* indica que vai comçar um comentário*/
<COMMENT>.                      { column += yyleng; }
<COMMENT>\n                     { row++; column = 1; }
<COMMENT><<EOF>>                { printf("Line <%d>, column <%d>: unterminated comment\n",row,column); BEGIN(INITIAL);}
<COMMENT>"*/"                   { BEGIN(INITIAL);column += yyleng; } /* indica que o comentário terminou */

"//"                            { BEGIN(COMMENT2); column += yyleng; }
<COMMENT2>.                     { column += yyleng; }
<COMMENT2>"\n"                  { column++; BEGIN(INITIAL); row++; column = 1;}

"\""                            { BEGIN(STRING); strcpy(string,"\""); column += yyleng; }
<STRING>\n                      { printf("Line <%d>, column <%d>: unterminated string\n",row,column); BEGIN(INITIAL);}
<STRING>[a-zA-Z0-9]             { strcat(string, yytext); column += yyleng; }
<STRING>\\n                     { strcat(string,"\\n"); row++; column = 1; }
<STRING>\\[tfr]                 { strcat(string,yytext); column += yyleng; }
<STRING>\\.                     { printf("Line <%d>, column <%d>: invalid escape sequence <%s>\n",row,column,yytext); column += yyleng; }
<STRING>"\""                    { BEGIN(INITIAL); printf("STRLIT(%s\")\n",string); column += yyleng; }


{KW}                            { toUpper(yytext); printf("%s\n", yytext); column += yyleng; semicolon = 0;}
{ignore}+                       { if (*yytext == '\n') { check_semicolon() ;row++; column = 1; } else {column += yyleng;} semicolon = 0;}
[-|+]?({digit})*"."{digit}+([eE][+|-]?{digit}+)?     { printf("DECIMAL(%s)\n", yytext); column += yyleng; semicolon = 1;} 
"-"                             { printf("MINUS\n"); column += yyleng; semicolon = 0;}
"+"                             { printf("PLUS\n"); column += yyleng; semicolon = 0;}
"*"                             { printf("STAR\n"); column += yyleng; semicolon = 0;}
"/"                             { printf("DIV\n"); column += yyleng; semicolon = 0;} 
"%"                             { printf("MOD\n"); column += yyleng; semicolon = 0;} 
","                             { printf("COMMA\n");column += yyleng; semicolon = 0;}
";"                             { printf("SEMICOLON\n"); column += yyleng; semicolon = 0;}
"_"                             { printf("BLANKID\n"); column += yyleng; semicolon = 0;}
"||"                            { printf("OR\n"); column += yyleng; semicolon = 0;}
"&&"                            { printf("AND\n"); column += yyleng; semicolon = 0;}
"=="                            { printf("EQ\n"); column += yyleng; semicolon = 0;}
"="                             { printf("ASSIGN\n"); column += yyleng; semicolon = 0;}
"!="                            { printf("NE\n"); column += yyleng; semicolon = 0;}
"!"                             { printf("NOT\n"); column += yyleng; semicolon = 0;}
">="                            { printf("GE\n"); column += yyleng; semicolon = 0;}
"<="                            { printf("LE\n"); column += yyleng; semicolon = 0;}
">"                             { printf("GT\n"); column += yyleng; semicolon = 0;}
"<"                             { printf("LT\n"); column += yyleng; semicolon = 0;}
"("                             { printf("LPAR\n"); column += yyleng; semicolon = 0;}
")"                             { printf("RPAR\n"); column += yyleng; semicolon = 1;}
"["                             { printf("LSQ\n"); column += yyleng; semicolon = 0;}
"]"                             { printf("RSQ\n"); column += yyleng; semicolon = 1;}
"{"                             { printf("LBRACE\n"); column += yyleng; semicolon = 0;}
"}"                             { printf("RBRACE\n"); column += yyleng; semicolon = 1;}
"package"                       { printf("PACKAGE\n"); column += yyleng; semicolon = 0;}
"return"                        { printf("RETURN\n"); column += yyleng; semicolon = 1;}
"else"                          { printf("ELSE\n"); column += yyleng; semicolon = 0;}
"for"                           { printf("FOR\n"); column += yyleng; semicolon = 0;}
"if"                            { printf("IF\n"); column += yyleng; semicolon = 0;}
"var"                           { printf("VAR\n"); column += yyleng; semicolon = 0;}
"int"                           { printf("INT\n"); column += yyleng; semicolon = 0;}
"float32"                       { printf("FLOAT32\n"); column += yyleng; semicolon = 0;}
"bool"                          { printf("BOOL\n"); column += yyleng; semicolon = 0;}
"string"                        { printf("STRING\n"); column += yyleng; semicolon = 0;}
"fmt.Println"                   { printf("PRINT\n"); column += yyleng; semicolon = 0;}
"strconv.Atoi"                  { printf("PARSEINT\n"); column += yyleng; semicolon = 0;}
"func"                          { printf("FUNC\n"); column += yyleng; semicolon = 0;}
"os.Args"                       { printf("CMDARGS\n"); column += yyleng; semicolon = 0;}
0.*[xX]({digit}|{hex_letter})+  { printf("HEXADECIMAL(%s)\n", yytext); column += yyleng; semicolon = 1;}
0.*[xX]([[g-zG-Z])*             { printf("Line <%i>, column <%i>: invalid hexadecimal constant <%s>\n", row,column,yytext); column += yyleng; }
0{digit_octal}+                 { printf("OCTAL(%s)\n", yytext); column += yyleng; semicolon = 1; }
0([8|9]|{letter})+              { printf("Line <%i>, column <%i>: invalid octal constant <%s>\n", row,column,yytext); column += yyleng; semicolon = 1;}
{digit}+                        { printf("NATURAL(%s)\n", yytext); column += yyleng; semicolon = 1; }
{letter}({letter}|{digit}|"_")* { printf("IDENTIFIER(%s)\n", yytext); column += yyleng; semicolon = 1;}
<<EOF>>                         { check_semicolon(); return 0; }
.                               { printf("Line <%i>, column <%i>: illegal character <%s>\n", row,column,yytext);column += yyleng; }

%%
extern int yylex();
int main() {
    yylex();    /* run the lexical analysis automaton */
    return 0;
}
int yywrap() {  /* called on EOF, return 1 to terminate */
    return 1;
}