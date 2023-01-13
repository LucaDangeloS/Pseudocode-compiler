%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h> 
#include "utils.h"
#define TAB "\n    "

extern int yylineno;
extern int yylex();
void yyerror (char const *);
 
char* initMainSegment();
char* methodSignatures;

symbol_table_t* active_symbol_table;
symbol_table_t* global_symbol_table;
int warn_about_vars = 1;
int stop_on_error = 0;
int auto_create_vars = 0;

int missed_last_var = 0;
int flip_control_auto_create_vars = 0;
int processing_procedure = 0;
char* last_var_name;
%}

%union {
	char* valStr;
	int valInt;
	float valFloat;
	char valChar;
	int valBool;
	symbol_t* valSymbol;
}


/* variables and assignation */
%token <valStr> ASSIGN SYMBOL
%type <valStr> assignation symbol symbol_declaration
/* basic flux control */
/* While loop */
%token <valStr> WHILE DO END_WHILE
/* Conditional flow */
%token <valStr> IF THEN ELSE END_IF
/* For loop */
%token <valStr> FROM TO END_FROM
/* Switch*/
%token <valStr> CASE DEFAULT END_CASE
%type <valStr> switch_value switch_case_body case_value
/* functions */
%token <valStr> PROCEDURE FUNCTION START RETURN END_PROCEDURE END_FUNCTION 
%type <valStr> function_call func_call_params arg args func_declarations procedure_def_params procedure_def_args
%type <valStr> ret_sttm procedure_call declaration func_def_params def_args func_body
/* data types definitions */
%token <valStr> INT_T REAL_T STRING_T LOGIC_T CHAR_T

/* data types */
%token <valInt> INT
%token <valFloat> REAL
%token <valStr> STRING
%token <valChar> CHAR
%token <valBool> LOGIC
%type <valInt> base_type
%type <valStr> atomic numeric_atomic numeric_expression wrapped_conditional
/* basic math */
%token <valStr> PLUS MINUS MULT DIV MOD POW

/* basic logic */
%token <valStr> EQ NEQ GT LT GTEQ LTEQ AND OR NOT
%type <valStr> conditional

/* basic I/O */
%token <valStr> PRINT READ
%type <valStr> print_func print_args print_arg read_func
/* misc */
%token <valStr> COMMENT COMMA COLON LPAREN RPAREN
%type <valStr> S1 S2 base_term 

%type <valSymbol> print_function_call

%start S
%nonassoc LT LTEQ GT GTEQ EQ NEQ AND OR
%left PLUS MINUS
%left MULT DIV MOD POW
%right NOT
%%

S : S1 {
	
	char* headers = printHeaders();
	char* finalStr;
	
	finalStr = malloc(strlen(headers) + strlen(methodSignatures) + strlen($1) + 100);
	sprintf(finalStr, "%s%s%s", headers, methodSignatures, $1);
	
	printf("%s", finalStr);
}


S1 : S2 func_declarations {
		char* str = malloc(strlen($1) + strlen($2) + 2);
		char* mainSegment = malloc(strlen($1) + 20);
		char returnSt[25];
		sprintf(returnSt, "\n%sreturn 0;}\n", TAB);	
		$1 = str_replace($1, "\n", TAB);
		sprintf(mainSegment, "%s%s%s", initMainSegment(), $1, returnSt);
		sprintf(str, "%s%s", $2, mainSegment);
		$$ = str;
	}
	| func_declarations S2 {
		char* str = malloc(strlen($1) + strlen($2) + 2);
		char* mainSegment = malloc(strlen($2) + 20);
		char returnSt[25];
		sprintf(returnSt, "\n%sreturn 0;\n}", TAB);	
		$2 = str_replace($2, "\n", TAB);
		sprintf(mainSegment, "%s%s%s", initMainSegment(), $2, returnSt);
		sprintf(str, "%s\n%s\n", $1, mainSegment);
		$$ = str;
	}
	| S2 {
		char* str = malloc(strlen($1) + 2);
		char* mainSegment = malloc(strlen($1) + 20);
		char returnSt[25];
		sprintf(returnSt, "\n%sreturn 0;\n}", TAB);	
		$1 = str_replace($1, "\n", TAB);
		sprintf(mainSegment, "%s%s%s\n", initMainSegment(), $1, returnSt);
		$$ = mainSegment;
	}
	| func_declarations {
		char* str = malloc(strlen($1) + 2);
		char* mainSegment = malloc(20);
		char returnSt[25];
		sprintf(returnSt, "\n%sreturn 0;\n}", TAB);	
		sprintf(mainSegment, "%s%s", initMainSegment(), returnSt);
		sprintf(str, "%s\n%s\n", $1, mainSegment);
		$$ = str;
	}
;

func_declarations : 
	declaration {
		$$ = $1;
	}
	| func_declarations declaration {
		char* str = malloc(strlen($1) + strlen($2) + 2);
		sprintf(str, "%s%s", $1, $2);
		$$ = str;
	}

declaration : 
	PROCEDURE SYMBOL {
		symbol_t* procedure_sym = createSymbol(PROCEDURE_T, $2, yylineno);
		addSymbol(active_symbol_table, procedure_sym);
		active_symbol_table = createSymbolTable();
		addSymbol(active_symbol_table, procedure_sym);
		processing_procedure = 1;
	} procedure_def_params START S2 END_PROCEDURE {
		char* str = malloc(strlen($2) + strlen($4) + strlen($6) + 10);
		$4 = str_replace($4, "\n", "");
		$4 = str_replace($4, ";", "");
		$6 = str_replace($6, "\n", TAB);
		sprintf(str, "\nvoid %s%s {%s\n%sreturn;\n}", $2, $4, $6, TAB);
		removeSymbolTable(active_symbol_table);
		active_symbol_table = global_symbol_table;
		processing_procedure = 0;
		$$ = str;
	}
	| base_type FUNCTION SYMBOL {
		symbol_t* procedure_sym = createSymbol($1, $3, yylineno);
		addSymbol(active_symbol_table, procedure_sym);
		active_symbol_table = createSymbolTable();
		addSymbol(active_symbol_table, procedure_sym);
	} func_def_params START func_body END_FUNCTION {
		char* str = malloc(sizeof($1) + strlen($3) + strlen($5) + strlen($7) + 10);
		$5 = str_replace($5, "\n", "");
		$5 = str_replace($5, ";", "");
		$7 = str_replace($7, "\n", TAB);
		sprintf(str, "\n%s %s%s {%s}", mapArgTypeToString($1), $3, $5, $7);
		removeSymbolTable(active_symbol_table);
		active_symbol_table = global_symbol_table;
		$$ = str;
	}
	;

func_body : S2 ret_sttm {
		char* str = malloc(strlen($1) + strlen($2) + 1);
		$1 = str_replace($1, "\n", TAB);
		sprintf(str, "%s%s", $1, $2);
		$$ = str;
	}
	| ret_sttm {
		$$ = $1;
	}
	;

ret_sttm : RETURN atomic {
		char* str = malloc(strlen($2) + 10);
		$2 = str_replace($2, ";", "");
		$2 = str_replace($2, "\n", "");
		sprintf(str, "%sreturn %s;\n", TAB, $2);
		$$ = str;
	}
	;

S2 : COMMENT {
		$$ = $1;
	}
	| S2 COMMENT {
		char* str = malloc(strlen($1) + strlen($2) + 20);
		sprintf(str, "%s\n%s", $1, $2);
		$$ = str;
	}
	| base_term {
		$$ = $1;
	}
	| S2 base_term {
		char* str = malloc(strlen($1) + strlen($2) + 10);
		sprintf(str, "%s%s", $1, $2);
		$$ = str;
	}
	;

base_term : function_call {
		$$ = $1;
	}
	| procedure_call {
		$$ = $1;
	}
	| assignation {
		$$ = $1;
	}
	| symbol_declaration {
		$$ = $1;
	}
	| ret_sttm {
		$$ = $1;
	}
	| IF wrapped_conditional THEN S2 ELSE S2 END_IF {
		char* str = malloc(strlen($2) + strlen($4) + checkOcurrences($4, '\n') + strlen($6) + checkOcurrences($6, '\n') + 100);
		$4 = str_replace($4, "\n", TAB);
		$6 = str_replace($6, "\n", TAB);
		sprintf(str, "\nif (%s) {%s\n} else {%s\n}", $2, $4, $6);
		$$ = str;
	}
	| IF wrapped_conditional THEN S2 END_IF {
		char* str = malloc(strlen($2) + strlen($4) + checkOcurrences($4, '\n') + 20);
		// prepend \n to $4
		$4 = str_replace($4, "\n", TAB);
		sprintf(str, "\nif (%s) {%s\n}", $2, $4);
		$$ = str;
	}
	| WHILE wrapped_conditional DO S2 END_WHILE {
		char* str = malloc(strlen($2) + strlen($4) + checkOcurrences($4, '\n') + 30);
		$4 = str_replace($4, "\n", TAB);
		sprintf(str, "\nwhile (%s) {%s\n}", $2, $4);
		$$ = str;
	}
	| DO S2 WHILE wrapped_conditional END_WHILE {
		char* str = malloc(strlen($2) + strlen($4) + checkOcurrences($2, '\n') + 30);
		$2 = str_replace($2, "\n", TAB);
		sprintf(str, "\ndo {%s\n} while (%s);", $2, $4);
		$$ = str;
	}
	| FROM {
		warn_about_vars = 0;
		if (auto_create_vars) {
			auto_create_vars = 0;
			flip_control_auto_create_vars = 1;
		}
	} assignation TO numeric_expression DO {
		if (flip_control_auto_create_vars) {
			auto_create_vars = 1;
			flip_control_auto_create_vars = 0;
		}
		warn_about_vars = 1;

		// Remove line breaks
		$3 = str_replace($3, "\n", "");
		$5 = str_replace($5, "\n", "");
		
		// Parse assignation to build the for loop and look up the variable name
		char* tmp = $5;
		char** tokenizedAssignation = parseAssignation($3);
		char* varName = tokenizedAssignation[0];
		last_var_name = varName;
		trimWhitespace(varName);
		symbol_t* sym = getSymbol(active_symbol_table, varName);

		int declaredPreviously = (sym != NULL);

		if (!declaredPreviously) {
			sym = createSymbol(INT_ARG, varName, yylineno);
		}
		addSymbol(active_symbol_table, sym);
		//append data type to variable assignation
		char* newAssignation = malloc(strlen($3)*2 + 10);
		sprintf(newAssignation, "%s %s =%s", declaredPreviously ? "" : \
			mapArgTypeToString(sym->arg_type), varName, tokenizedAssignation[1]);
		$3 = newAssignation;

	} S2 END_FROM {
		char* str = malloc(strlen($3) + strlen($5) + strlen($8) + checkOcurrences($8, '\n') + 100);
		$8 = str_replace($8, "\n", TAB);
		sprintf(str, "\nfor (%s %s < %s; %s++) {%s\n}", $3, last_var_name, $5, last_var_name, $8);
		removeSymbol(active_symbol_table, last_var_name);
		$$ = str;
	}
	| CASE switch_value switch_case_body END_CASE {
		char* str = malloc(strlen($2) + strlen($3) + checkOcurrences($3, '\n') + 100);
		$3 = str_replace($3, "\n", TAB);
		sprintf(str, "\nswitch (%s) {%s\n}", $2, $3);
		$$ = str;
	}
	;

switch_value: 
	INT COLON {
		$$ = intToString($1, 0);
	}
	| CHAR COLON {
		$$ = charToString($1, 2);
	}
	| symbol COLON {
		$$ = $1;
	}
	;

case_value : 
	INT COLON {
		$$ = intToString($1, 0);
	}
	| CHAR COLON {
		$$ = charToString($1, 2);
	}

switch_case_body: 
	case_value S2  {
		char* str = malloc(strlen($2) + 25);
		$2 = str_replace($2, "\n", TAB);

		sprintf(str, "\ncase %s: \n{\n%s%sbreak;\n}", $1, $2,TAB);
		$$ = str;
  }
  | case_value S2 switch_case_body {
		char* str = malloc(strlen($2) + strlen($3) + 25);
		$2 = str_replace($2, "\n", TAB);

		sprintf(str, "\ncase %s: {%s%sbreak;\n} %s", $1, $2,TAB, $3);
		$$ = str;
  }
  | DEFAULT COLON S2 {
		char* str = malloc(strlen($3) + 25);
		$3 = str_replace($3, "\n", TAB);
		sprintf(str, "\ndefault: {%s%sbreak;\n}", $3,TAB);
		$$ = str;
  }

wrapped_conditional : LPAREN conditional RPAREN {
		$$ = $2;
	}
	;

atomic : CHAR {
		$$ = charToString($1, 2);
	}
	| numeric_expression {
		char* str = malloc(strlen($1) + 1);
		sprintf(str, "%s", $1);
		$$ = str;
	} 
	;

numeric_atomic : INT {
		$$ = intToString($1, 0);
	}
	| REAL {
		$$ = floatToString($1, 0);
	}
	| symbol {
		$$ = $1;
	}
	;


numeric_expression: numeric_atomic {
		$$ = $1;
	}
	| LPAREN numeric_expression RPAREN {
		char* str = malloc(strlen($2) + 3);
		sprintf(str, "(%s)", $2);
		$$ = str;
	}
	| numeric_expression PLUS numeric_expression {
		char* str = malloc(strlen($1) + strlen($3) + 4);
		sprintf(str, "%s + %s", $1, $3);
		$$ = str;
	}
	| numeric_expression MINUS numeric_expression {
		char* str = malloc(strlen($1) + strlen($3) + 4);
		sprintf(str, "%s - %s", $1, $3);
		$$ = str;
	}
	| numeric_expression MULT numeric_expression {
		char* str = malloc(strlen($1) + strlen($3) + 4);
		sprintf(str, "%s * %s", $1, $3);
		$$ = str;
	}
	| numeric_expression DIV numeric_expression {
		char* str = malloc(strlen($1) + strlen($3) + 4);
		sprintf(str, "%s / %s", $1, $3);
		$$ = str;
	}
	| numeric_expression POW numeric_expression {
		char* str = malloc(strlen($1) + strlen($3) + 10);
		sprintf(str, "pow(%s, %s)", $1, $3);
		$$ = str;
	}
	| numeric_expression MOD numeric_expression {
		char* str = malloc(strlen($1) + strlen($3) + 10);
		sprintf(str, "%s %% %s", $1, $3);
		$$ = str;
	}
	| function_call {
		$$ = $1;
	}
	;


// Symbols and assignations
symbol_declaration : SYMBOL COLON base_type {
		char* str = malloc(strlen($1) + 15);
		symbol_t* sym = createSymbol($3, $1, yylineno);
		symbol_t* sym2 = getSymbol(active_symbol_table, $1);
		if (warn_about_vars && sym2 != NULL) {
			char err[100];
			sprintf(err, "WARNING: Symbol '%s' in line %d has already been declared previously in line %d", $1, yylineno, sym2->line);
			yyerror(err);
		} else if (sym2 == NULL) {
			addSymbol(active_symbol_table, sym);
		}
		sprintf(str, "\n%s %s;", mapArgTypeToString($3), $1);
		$$ = str;
	}
	;

assignation : symbol ASSIGN STRING {
		symbol_t* sym = getSymbol(active_symbol_table, $1);
		char* str = malloc(strlen($1) + strlen($3) + 20);
		int offset = 0;

		if (warn_about_vars && sym == NULL) {
			char err[100];
			sprintf(err, "ERROR in line %d: Cannot assign value to symbol '%s' that has not been declared before", yylineno, $1);
			yyerror(err);
			
			if (stop_on_error) {
				free(str);
				return 1;
			}
		}

		if (auto_create_vars && missed_last_var) {
			str = realloc(str, strlen($1) + strlen($3) * 2 + 70);
			sym = createSymbol(STRING_ARG, $1, yylineno);
			addSymbol(active_symbol_table, sym);
			sprintf(str, "\nchar* %s = malloc(strlen(\"%s\") + 1);", $1, $3);
		}
		missed_last_var = 0;

		if (warn_about_vars && sym != NULL && sym->arg_type != STRING_ARG) {
			char err[100];
			sprintf(err, "ERROR: Cannot assign string to symbol '%s' of type %s in line %d", $1, mapArgTypeToString(sym->arg_type), yylineno);
			yyerror(err);
		}

		offset = strlen(str);
		snprintf(str+offset, strlen($1) + strlen($3) + 20, "\nstrcpy(%s, \"%s\");", $1, $3);
		$$ = str;
	}
	| symbol ASSIGN LOGIC {
		symbol_t* sym = getSymbol(active_symbol_table, $1);
		char* str = malloc(strlen($1) + sizeof($3) + 8);
		int offset = 0;

		if (warn_about_vars && !auto_create_vars && sym == NULL && warn_about_vars) {
			char err[100];
			sprintf(err, "ERROR in line %d: Cannot assign value to symbol '%s' that has not been declared before", yylineno, $1);
			yyerror(err);
			if (stop_on_error) {
				free(str);
				return 1;
			}
		}

		if (auto_create_vars && missed_last_var) {
			str = realloc(str, strlen($1)*2 + sizeof($3) + 20);
			sym = createSymbol(LOGIC_ARG, $1, yylineno);
			addSymbol(active_symbol_table, sym);
			sprintf(str, "\nint %s;", $1);
		}
		missed_last_var = 0;

		if (warn_about_vars && sym != NULL && sym->arg_type != LOGIC_ARG) {
			char err[100];
			sprintf(err, "ERROR: Cannot assign bool to symbol '%s' of type %s in line %d", $1, mapArgTypeToString(sym->arg_type), yylineno);
			yyerror(err);
			if (stop_on_error) {
				free(str);
				return 1;
			}
		}

		offset = strlen(str);
		snprintf(str+offset, strlen($1) + sizeof($3) + 20, "\n%s%s = %d;", processing_procedure ? "*" : "", $1, $3);
		$$ = str;
	}
	| symbol ASSIGN atomic {
		symbol_t* sym = getSymbol(active_symbol_table, $1);
		char* str = malloc(strlen($1) + strlen($3) + 20);
		int offset = 0;

		if (!auto_create_vars && sym == NULL && warn_about_vars) {
			char err[100];
			sprintf(err, "ERROR in line %d: Cannot assign value to symbol '%s' that has not been declared before", yylineno, $1);
			yyerror(err);
			if (stop_on_error) {
				free(str);
				return 1;
			}
		}

		if (auto_create_vars && missed_last_var) {
			// get symbol type
			str = realloc(str, (strlen($1) + strlen($3) + 20) * 2);
			sym = getSymbol(active_symbol_table, $3);
			ARG_T arg_type;
			if (sym != NULL) {
				arg_type = sym->arg_type;
				switch (arg_type) {
					STRING_ARG:
						sprintf(str, "\nchar* %s = malloc(strlen(%s) + 1);", $1, $3);
						break;
					default:
						sprintf(str, "\n%s %s;", mapArgTypeToString(arg_type), $1);
				}
			} else {
				arg_type = infereTypeIntFloatChar($3);
				sprintf(str, "\n%s %s;", mapArgTypeToString(arg_type) , $1);
			}
			sym = createSymbol(arg_type, $1, yylineno);
			addSymbol(active_symbol_table, sym);
		}
		missed_last_var = 0;

		// Checking for errors here would be more difficult due to the lack of type information
		offset = strlen(str);
		snprintf(str+offset, strlen($1) + strlen($3) + 10, "\n%s%s = %s;", processing_procedure ? "*" : "", $1, $3);
		$$ = str;
	}
	;


symbol : SYMBOL {
		symbol_t *sym = getSymbol(active_symbol_table, $1);
		if (sym == NULL && warn_about_vars) {
			fprintf(stderr, "Warning: Symbol '%s' at line %d not defined previously\n", $1, yylineno);
			missed_last_var = 1;
		}
		$$ = $1;
	}
	;

// ----------------------------------
// Procedure calls 

procedure_call : print_func {
		$$ = $1;
	}
	| read_func {
		$$ = $1;
	}
	;

read_func :	READ LPAREN SYMBOL RPAREN {
		symbol_t *sym = getSymbol(active_symbol_table, $3);
		if (sym == NULL) {
			sym = createSymbol(STRING_ARG, $3, yylineno);
		}
		char* str = malloc(strlen($3) + 20);
		sprintf(str, "\nscanf(%s);", processSymbolForRead(*sym, processing_procedure));
		$$ = str;
	}
	;

print_func : PRINT LPAREN print_args RPAREN {
		$$ = $3;
	}
	;

print_args : print_arg { 
		char* str = malloc(strlen($1) + 15);
		sprintf(str, "\nprintf(%s);", $1);
		$$ = str;
 	}
	| print_args COMMA print_arg {
		char* str = malloc(strlen($3) + 15);
		sprintf(str, "\nprintf(%s);", $3);
		strcat($1, str);
		$$ = $1;
	}
	;

print_arg : STRING {
		char* str = malloc(strlen($1) + 5);
		sprintf(str, "\"%s\\n\"", $1);
		$$ = str;
	}
	| INT 	{
		$$ = intToString($1, 1);
	}
	| REAL	{
		$$ = floatToString($1, 1);
	}
	| CHAR	{
		$$ = charToString($1, 1);
	}
	| LOGIC	{
		$$ = boolToString($1, 1);
	}
	| symbol {
		symbol_t *sym = getSymbol(active_symbol_table, $1);
		if (sym == NULL) {
			sym = createSymbol(INT_ARG, $1, yylineno);
		}
		$$ = processSymbolForPrint(*sym);
	}
	| print_function_call {
		char* str = malloc(strlen($1->arg_name) + 15);
	 	sprintf(str, "%s%s", processSymbolForPrint(*$1), yylval.valStr);	
		$$ = str;	
	}
	;

print_function_call : SYMBOL func_call_params {
		// Check if function exists
		symbol_t *sym = getSymbol(active_symbol_table, $1);
		if (sym == NULL) {
			char err[100];
			sprintf(err, "ERROR: Function '%s' not defined in line %d", $1, yylineno);
			yyerror(err);
			sym = createSymbol(INT_ARG, $1, yylineno);
			if (stop_on_error) {
				return 1;
			}
		}
		yylval.valStr = $2;
		$$ = sym;
	}
	;

procedure_def_params : LPAREN RPAREN {
		$$ = " ()";
	}
	| LPAREN procedure_def_args RPAREN {
		char* str = malloc(strlen($2) + 3);
		sprintf(str, " (%s)", $2);
		$$ = str;
	}
	;

procedure_def_args : symbol_declaration {
		$1 = str_replace($1, " ", "* ");
		$$ = $1;
	}
	| symbol_declaration COMMA procedure_def_args {
		char* str = malloc(strlen($1) + strlen($3) + 5);
		$1 = str_replace($1, " ", "* ");
		sprintf(str, "%s, %s", $1, $3);
		$$ = str;
	}
	;

// ----------------------------------
// Functions
function_call : SYMBOL func_call_params {
		// Check if function exists
		symbol_t *sym = getSymbol(active_symbol_table, $1);
		if (sym == NULL) {
			char err[100];
			sprintf(err, "ERROR: Function '%s' not defined in line %d", $1, yylineno);
			yyerror(err);
			if (stop_on_error) {
				return 1;
			}
		}
		char* str = malloc(strlen($1) + strlen($2) + 10);
		if (sym != NULL && sym->arg_type == PROCEDURE_T) {
			$2 = str_replace($2, " ", " &");
		}
		sprintf(str, "\n%s%s;", $1, $2);
		$$ = str;
	}
	;

func_def_params : LPAREN RPAREN {
		$$ = " ()";
	}
	| LPAREN def_args RPAREN {
		char* str = malloc(strlen($2) + 3);
		sprintf(str, " (%s)", $2);
		$$ = str;
	}
	;

def_args : symbol_declaration {
		$$ = $1;
	}
	| symbol_declaration COMMA def_args {
		char* str = malloc(strlen($1) + strlen($3) + 3);
		sprintf(str, "%s, %s", $1, $3);
		$$ = str;
	}
	;

func_call_params : LPAREN RPAREN {
		$$ = " ()";
	}
	| LPAREN args RPAREN {
		char* str = malloc(strlen($2) + 3);
		sprintf(str, "( %s)", $2);
		$$ = str;
	}
	;

args : arg {
		$$ = $1;
	}
	| arg COMMA args {
		char* str = malloc(strlen($1) + strlen($3) + 3);
		sprintf(str, "%s, %s", $1, $3);
		$$ = str;
	}
	;

arg : atomic {
		$$ = $1;
	}
	;
// ----------------------------------
// Control structures

conditional : atomic NEQ atomic {
		char* str = malloc(strlen($1) + strlen($3) + 4);
		sprintf(str, "%s != %s", $1, $3);
		$$ = str;
	}
	| atomic EQ atomic {
		char* str = malloc(strlen($1) + strlen($3) + 4);
		sprintf(str, "%s == %s", $1, $3);
		$$ = str;
	}
	| atomic GT atomic {
		char* str = malloc(strlen($1) + strlen($3) + 4);
		sprintf(str, "%s > %s", $1, $3);
		$$ = str;
	}
	| atomic LT atomic {
		char* str = malloc(strlen($1) + strlen($3) + 4);
		sprintf(str, "%s < %s", $1, $3);
		$$ = str;
	}
	| atomic GTEQ atomic {
		char* str = malloc(strlen($1) + strlen($3) + 4);
		sprintf(str, "%s >= %s", $1, $3);
		$$ = str;
	}
	| atomic LTEQ atomic {
		char* str = malloc(strlen($1) + strlen($3) + 4);
		sprintf(str, "%s <= %s", $1, $3);
		$$ = str;
	}
	| atomic AND conditional {
		char* str = malloc(strlen($1) + strlen($3) + 4);
		sprintf(str, "%s && %s", $1, $3);
		$$ = str;
	}
	| atomic AND wrapped_conditional {
		char* str = malloc(strlen($1) + strlen($3) + 4);
		sprintf(str, "%s && (%s)", $1, $3);
		$$ = str;
	}
	| atomic OR conditional {
		char* str = malloc(strlen($1) + strlen($3) + 4);
		sprintf(str, "%s || %s", $1, $3);
		$$ = str;
	}
	| atomic OR wrapped_conditional {
		char* str = malloc(strlen($1) + strlen($3) + 4);
		sprintf(str, "%s || (%s)", $1, $3);
		$$ = str;
	}
	| atomic {
		$$ = $1;
	}
	| NOT conditional {
		char* str = malloc(strlen($2) + 4);
		sprintf(str, "!%s", $2);
		$$ = str;
	}
	;

// ----------------------------------

base_type : STRING_T {
		$$ = STRING_ARG;
	}
	| INT_T {
		$$ = INT_ARG;
	}
	| REAL_T {
		$$ = FLOAT_ARG;
	}
	| CHAR_T {
		$$ = CHAR_ARG;
	}
	| LOGIC_T {
		$$ = LOGIC_ARG;
	}
	;


%%
int main(int argc, char *argv[]) {
	/* Run flags */
	int show_help = 0;

	extern FILE *yyin;
	char* output;
	methodSignatures = malloc(64);
	strcpy(methodSignatures, "\0");
	global_symbol_table = createSymbolTable();
	active_symbol_table = global_symbol_table;

	/* Command line arguments parsing */
	int c;
	while ((c = getopt(argc, argv, "isah")) != -1) {
		switch (c) {
			case 'i':
				warn_about_vars = 0;
				break;
			case 's':
				stop_on_error = 1;
				break;
			case 'a':
				auto_create_vars = 1;
				break;
			case 'h':
				show_help = 1;
				break;
			default:
				break;
		}
	}

	if (show_help) {
		printf("Usage: %s [-isah] [input_file] [output_file]\n", argv[0]);
		printf("Options:\n");
		printf("  -i  Hide warnings for not declared variables\n");
		printf("  -s  Stop on error\n");
		printf("  -a  Auto declare variables, allows for more flexibility\n");
		printf("  -h  Show this help message\n");
		return 0;
	}

	switch (argc - optind) {
		case 0:
			yyin=stdin;
			yyparse();
			break;
		case 1:
			yyin = fopen(argv[optind], "r");
			if (yyin == NULL) {
				printf("ERROR: No se ha podido abrir el fichero.\n");
			}
			else {
				yyparse();
				fclose(yyin);
			}
			break;
		case 2:
			output = argv[optind + 1];
			freopen(output, "w+", stdout); 
			yyin = fopen(argv[optind], "r");
			if (yyin == NULL) {
				printf("ERROR: No se ha podido abrir el fichero.\n");
			}
			else {
				yyparse();
				fclose(yyin);
			}
			break;
		default: printf("ERROR: Demasiados argumentos.\nSintaxis: %s [-isah] [fichero_entrada]\n\n", argv[0]);
	}
	return 0;
}

void yyerror (char const *message) { fprintf (stderr, "%s\n", message);}


