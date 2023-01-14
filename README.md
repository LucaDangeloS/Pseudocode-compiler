This is a pseudocode to C compiler. The pseudocode syntax is a more relaxed version of pascal pseudocode, with the following modifications:  

- No variable declaration section, essentially allowing for variable declarations anywhere.
- No Registers nor Arrays.
- No Break and Continue statements.
- Reserved words are case insensitive.
- Explicit pointers were removed.

There are also a set of rules, most are standard:

- Variable names must begin with a letter, and can contain underscores, numbers and letters (like in C).
- Functions and procedures must be defined all in bulk, before or after the 'main' segment.
- Function parameters are only passed by value, while in procedures are passed by reference.
- Functions/procedures are only visible within the scope of the main segment and other functions/procedures declared below them.


# Getting started

#### To compile the program run `make compile`, and then execute the output file passing the input as an argument file or through a pipeline.
---
#### You can compile all the examples provided with `make test`.
---
#### The generated compiler can be run with the following flags:
    -s : Stops execution when a variable error has been found.
    -i : Ignores warnings.
    -a : Uses the automated variable declaring feature (experimental).
    -h : Shows help.


# Basic Syntax:

### Types:

- Integer
- Real
- Char
- String
- Bool

### Declarations:
x: integer

### Assignations:
x <- 5


### Arithmetic operations:
-    x + y
-    x - y
-    x * y
-    x / y
-    x MOD y
-    x = y
-    x <> y
-    x < y
-    x > y
-    x AND y 
-    x OR y
-    x ^ y
-    NOT x


### Control structures:

- IF (<simple_expr>) THEN  
    \<expr>  
    [ELSE \<expr>]  
  END_IF

- WHILE (<simple_expr>) DO  
    \<expr>  
  END_WHILE  

- FROM \<assign> TO \<var> DO  
    \<expr>  
  END_FROM  

- DO  
  \<expr>     
  WHILE (<simple_expr>)  
  END_WHILE

- CASE \<var> OF  
    \<const> : \<expr>  
    [DEFAULT : \<expr>]  
  END_CASE


### Comments:
/* A comment. It's singleline, sadly. */

### Functions and procedures:

- \<type> FUNCTION \<func_name>(\<param_list>) START  
    \<expr>  
    RETURN \<simple_expr>  
  END_FUNCTION

- PROCEDURE \<proc_name>(\<param_list>) START  
    \<expr>  
  END_PROCEDURE
  

### Built-in functions:

- READ(\<var>)  
  Equivalent to scanf in C.

- WRITE(\<var1>, \<var2>, ...)  
  Note: Arguments are atomic.


**Note**: Added more parenthesis options, also adding 1 shift/reduce conflict. Too lazy to fix it and it shouldn't matter.
