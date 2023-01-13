%{
#include "symbols.h"
#include "main.tab.h"

extern int checkOcurrences(char *str, char c);
%}

/* basic definitions */
digit   [0-9]
letter  [a-zA-Z]
tilde_letter [ÁÀáàÉÈéèÍÌíìÓÒóòÚÙúùÑñ]
white_space [ \t]
sex [\n]
quote ["]
simple_quote [']
colon ":"
semicolon [;]
word [0-9a-zA-Z_]*
unrestrictive_word ({word}|{white_space}|{EQ}|{NEQ}|{COMMA}|"!"|"?"|":"|"."|","|"'"|"-")*

/* variables and assignation */
SYMBOL          {letter}+{word}
ASSIGN          "<-"

/* basic flux control */
WHILE           (?i:WHILE)
DO              (?i:DO)
END_WHILE       (?i:END_WHILE)
IF              (?i:IF)
THEN            (?i:THEN)
ELSE            (?i:ELSE)
END_IF          (?i:END_IF)
FROM            (?i:FROM)
TO              (?i:TO)
END_FROM         (?i:END_FROM)
RETURN          (?i:RETURN)
CASE            (?i:CASE)
END_CASE        (?i:END_CASE)
DEFAULT         (?i:DEFAULT)

/* functions */
PROCEDURE       (?i:PROCEDURE)
FUNCTION        (?i:FUNCTION)
START           (?i:START)
END_PROCEDURE   (?i:END_PROCEDURE)
END_FUNCTION    (?i:END_FUNCTION)

/* data types definitions */
INT_T           (?i:INTEGER)
REAL_T          (?i:REAL)
STRING_T        (?i:STRING)
LOGIC_T         (?i:BOOL)
CHAR_T          (?i:CHAR)

/* data types */
INT             {MINUS}{0,1}{digit}+
REAL            {MINUS}{0,1}{digit}+\.{digit}+
STRING          {quote}{unrestrictive_word}{quote}
LOGIC           (?i:TRUE)|(?i:FALSE)
CHAR            {simple_quote}{letter}{simple_quote}

/* basic math */
PLUS    "+"
MINUS   "-"
MULT    "*"
DIV     "/"
MOD     (?i:MOD)
POW     "^"

/* basic logic */
EQ      "="
NEQ     "<>"
GT      ">"
LT      "<"
GTEQ    ">="
LTEQ    "<="
AND    (?i:AND)
OR     (?i:OR)
NOT    (?i:NOT)

/* basic I/O */
PRINT   (?i:PRINT)
READ    (?i:READ)

/* misc */
COMMENT (\/\*)({unrestrictive_word}|{white_space})*(\*\/)
LPAREN [\(]
RPAREN [\)]
COMMA  [,]

%%
{DO}            { return DO;}
{WHILE}         { return WHILE;}
{END_WHILE}     { return END_WHILE;}
{IF}            { return IF;}
{THEN}          { return THEN;}
{ELSE}          { return ELSE;}
{END_IF}        { return END_IF;}
{FROM}          { return FROM;}
{TO}            { return TO;}
{END_FROM}       { return END_FROM;}
{CASE}          { return CASE;}
{END_CASE}      { return END_CASE;}
{DEFAULT}       { return DEFAULT;}
{RETURN}        { return RETURN;}
{PROCEDURE}     { return PROCEDURE;}
{FUNCTION}      { return FUNCTION;}
{START}         { return START;}
{END_PROCEDURE} { return END_PROCEDURE;}
{END_FUNCTION}  { return END_FUNCTION;}
{INT_T}         { return INT_T;}
{REAL_T}        { return REAL_T;}
{STRING_T}      { return STRING_T;}
{LOGIC_T}       { return LOGIC_T;}
{CHAR_T}        { return CHAR_T;}
{PRINT}         { return PRINT;}
{READ}          { return READ;}
{ASSIGN}        { return ASSIGN;}
{PLUS}          { return PLUS;}
{COMMENT}       { yylval.valStr = strdup(yytext); return COMMENT;}
{MULT}          { return MULT;}
{DIV}           { return DIV;}
{MOD}           { return MOD;}
{POW}           { return POW;}
{EQ}            { return EQ;}
{NEQ}           { return NEQ;}
{GT}            { return GT;}
{LT}            { return LT;}
{GTEQ}          { return GTEQ;}
{LTEQ}          { return LTEQ;}
{AND}           { return AND;}
{OR}            { return OR;}
{NOT}           { return NOT;}
{CHAR}          { yylval.valChar = yytext[1]; return CHAR;}
{LOGIC}         { yylval.valBool = (strcasecmp(yytext, "TRUE") == 0); return LOGIC;}
{SYMBOL}        { yylval.valStr = strdup(yytext); return SYMBOL;}
{INT}           { yylval.valInt = atoi(yytext); return INT;}
{REAL}          { yylval.valFloat = atof(yytext); return REAL;}
{MINUS}         { return MINUS;}
{STRING}        { yytext[strlen(yytext)-1] = '\0'; yylval.valStr = strdup(yytext+1); return STRING;}
{colon}         { return COLON;}
{LPAREN}        { return LPAREN;}
{RPAREN}        { return RPAREN;}
{COMMA}         { return COMMA;}
{tilde_letter}  {}
\n              { yylineno++; }
.               {}
%%

// {CHARACTER}     {yylval.valChar = yytext[1]; return CHARACTER;}
// {COMMENT}       {return COMMENT;}