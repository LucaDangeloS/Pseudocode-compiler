#include "utils.h"

char* boolToString(int i, int includeQuotes) {
    char* str = malloc(sizeof(char)*10);
    if (includeQuotes) {
        sprintf(str, "\"%s\"", i ? "TRUE" : "FALSE");
    } else {
        sprintf(str, "%s", i ? "TRUE" : "FALSE");
    }
    return str;
}

char* intToString(int i, int includeQuotes) {
    char* str = malloc(sizeof(int)*10);
    if (includeQuotes) {
        sprintf(str, "\"%d\"", i);
    } else {
        sprintf(str, "%d", i);
    }
    return str;
}

char* floatToString(float f, int includeQuotes) {
    char* str = malloc(sizeof(char)*10);
    if (includeQuotes) {
        sprintf(str, "\"%f\"", f);
    } else {
        sprintf(str, "%f", f);
    }
    return str;
}

char* charToString(char c, int includeQuotes) {
    char* str = malloc(sizeof(char)*2+2);
    switch (includeQuotes){
    case 1:
        sprintf(str, "\"%c\"", c);
        break;
    case 2:
        sprintf(str, "\'%c\'", c);
        break;
    default:
        sprintf(str, "%c", c);
    }
    return str;
}

char* argTypeToString(ARG_T type) {
    switch (type){
    case STRING_ARG:
        return "STRING";
    case CHAR_ARG:
        return "CHAR";
    case INT_ARG:
        return "INT";
    case FLOAT_ARG:
        return "FLOAT";
    case LOGIC_ARG:
        return "LOGIC";
    default:
        return "void";
    }
}

char* mapArgTypeToString(ARG_T type) {
    switch (type){
    case STRING_ARG:
        return "char*";
    case CHAR_ARG:
        return "char";
    case INT_ARG:
        return "int";
    case FLOAT_ARG:
        return "float";
    case LOGIC_ARG:
        return "int";
    default:
        return "void";
    }
}

char *printHeaders()
{
    char *headers = (char *)malloc(100);
    sprintf(headers,"#include <stdio.h>\n\
#include <stdlib.h>\n\
#include <string.h>\n\
#include <math.h>\n\n");
    return headers;
}

char* initMainSegment() {
    char* main = (char*) malloc(40);
    sprintf(main, 
    "int main(int argc, char *argv[]) {"
    );
    return main;
}

char* processSymbolForPrint(symbol_t sym) {
    char* str = malloc(20);

    switch (sym.arg_type) {
        case LOGIC_ARG:
            strcpy(str, sym.arg_name);
            strcat(str, " ? \"TRUE\" : \"FALSE\"");
            return str;
        case STRING_ARG:
            strcpy(str, "\"%s\\n\", ");
            break;
        case CHAR_ARG:
            strcpy(str, "\"%c\\n\", ");
            break;
        case INT_ARG:
            strcpy(str, "\"%d\\n\", ");
            break;
        case FLOAT_ARG:
            strcpy(str, "\"%f\\n\", ");
            break;
    }
    strcat(str, sym.arg_name);

    return str;
}

char* processSymbolForRead(symbol_t sym, int not_include_ampersand) {
    char* str = malloc(20);

        switch (sym.arg_type) {
            case LOGIC_ARG:
                strcpy(str, sym.arg_name);
                strcat(str, " ? \"TRUE\" : \"FALSE\"");
                return str;
            case STRING_ARG:
                strcpy(str, "\"%s\", ");
                break;
            case CHAR_ARG:
                strcpy(str, "\" %c\", ");
                break;
            case INT_ARG:
                strcpy(str, "\"%d\", ");
                break;
            case FLOAT_ARG:
                strcpy(str, "\"%f\", ");
                break;
        }
        strcat(str, not_include_ampersand ? "" : "&");
        strcat(str, sym.arg_name);

        return str;
}

char* concat(char *s1, char *s2)
{
    int s1len = strlen(s1);
    int s2len = strlen(s2);
    int size = s1len + s2len + 1;
    char *s = calloc(size, sizeof(char));

    for (int i = 0; i < s1len; i++) {
        s[i] = s1[i];
    }
    for (int i = 0; i < s2len; i++) {
        s[i + s1len] = s2[i];
    }
    s[size - 1] = '\0';
    return s;
}

// You must free the result if result is non-NULL.
char* str_replace(char *orig, char *rep, char *with) {
    char *result; // the return string
    char *ins;    // the next insert point
    char *tmp;    // varies
    int len_rep;  // length of rep (the string to remove)
    int len_with; // length of with (the string to replace rep with)
    int len_front; // distance between rep and end of last rep
    int count;    // number of replacements

    // sanity checks and initialization
    if (!orig || !rep)
        return NULL;
    len_rep = strlen(rep);
    if (len_rep == 0)
        return NULL; // empty rep causes infinite loop during count
    if (!with)
        with = "";
    len_with = strlen(with);

    // count the number of replacements needed
    ins = orig;
    for (count = 0; tmp = strstr(ins, rep); ++count) {
        ins = tmp + len_rep;
    }

    tmp = result = malloc(strlen(orig) + (len_with - len_rep) * count + 1);

    if (!result)
        return NULL;

    // first time through the loop, all the variable are set correctly
    // from here on,
    //    tmp points to the end of the result string
    //    ins points to the next occurrence of rep in orig
    //    orig points to the remainder of orig after "end of rep"
    while (count--) {
        ins = strstr(orig, rep);
        len_front = ins - orig;
        tmp = strncpy(tmp, orig, len_front) + len_front;
        tmp = strcpy(tmp, with) + len_with;
        orig += len_front + len_rep; // move to next "end of rep"
    }
    strcpy(tmp, orig);
    return result;
}

int checkOcurrences(char *s,char c) {
    static int i=0,count=0;
    if(!s[i])
    {
    	return count;
    }
    else
    {
        if(s[i]==c)
    	{
  			count++;
		}
		i++;
		checkOcurrences(s, c);
	}
}

char** parseAssignation(char* str) {
    // Parse the assignation from format i<- x to create a list of tokens
    // [0] = i
    // [1] = x
    char** tokens = malloc(sizeof(char*)*2);
    char* token = strtok(str, "=");
    int i = 0;
    while (token != NULL) {
        tokens[i] = token;
        token = strtok(NULL, "=");
        i++;
    }
    return tokens;
}
char *trimWhitespace(char *str){
    char *end;

    // Trim leading space
    while (isspace((unsigned char)*str))
        str++;

    if (*str == 0) // All spaces?
        return str;

    // Trim trailing space
    end = str + strlen(str) - 1;
    while (end > str && isspace((unsigned char)*end))
        end--;

    // Write new null terminator character
    end[1] = '\0';

    return str;
}

ARG_T infereTypeIntFloatChar(char* str) {
    char fst = str[0];
    if (fst <= '9' && fst >= '0') {
        if (checkOcurrences(str, '.') == 1) {
            return FLOAT_ARG;
        } else {
            return INT_ARG;
        }
    } else {
        return CHAR_ARG;
    }
}