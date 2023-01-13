#include "symbols.h"

char* boolToString(int i, int includeQuotes);
char* intToString(int i, int includeQuotes);
char* floatToString(float f, int includeQuotes);
char* charToString(char c, int includeQuotes);
char* argTypeToString(ARG_T type);
char* mapArgTypeToString(ARG_T type);
ARG_T infereTypeIntFloatChar(char* str);

char* mapStringToArgType(char* str);

char** parseAssignation(char* str);
char* trimWhitespace(char *str);
char* concat(char *s1, char *s2);
char* str_replace(char *orig, char *rep, char *with);
int checkOcurrences(char *s,char c);

char* printHeaders();
char* initMainSegment();

char* processSymbolForPrint(symbol_t sym);
char* processSymbolForRead(symbol_t sym, int not_include_ampersand);

