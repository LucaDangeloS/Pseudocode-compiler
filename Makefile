SOURCE = main
LIB = lfl
UTILS = utils
SYMBOLS = symbols
EXAMPLES_FOLDER = examples/
COMPILED_OUTPUT = $(EXAMPLES_FOLDER)compiled/

TEST_FILE = menu

OUTPUT = $(TEST_FILE)
TEST = $(EXAMPLES_FOLDER)$(TEST_FILE).txt
TEST_FILES = $(wildcard $(EXAMPLES_FOLDER)*.txt)
ARGS = -a
# All final compiled .c output files will be under the compiled folder inside the examples folder

# Generates the final .c output file from the pseudocode
generate: compile run clean
# Generates, then compiles and runs the final .c output file
all: generate compile-output run-output
# Generates the final .c output file from the pseudocode for all the examples
test: compile-all-output

# Generate output binary program

compile:
	flex $(SOURCE).l
	bison -o $(SOURCE).tab.c $(SOURCE).y -yd -Wconflicts-sr
	gcc -o $(SOURCE) lex.yy.c $(SOURCE).tab.c $(UTILS).c $(SYMBOLS).c -$(LIB)

# Generate output .c file

run: compile
	./$(SOURCE) $(ARGS) $(TEST) $(COMPILED_OUTPUT)$(OUTPUT).c


# Test output .c file

compile-output: 
	gcc $(COMPILED_OUTPUT)$(OUTPUT).c -o $(COMPILED_OUTPUT)$(OUTPUT)

run-output: 
	$(COMPILED_OUTPUT)$(OUTPUT)

compile-all-output:
	# Run 'make generate' for all the examples in the examples folder
	mkdir -p $(COMPILED_OUTPUT)
	$(foreach file, $(TEST_FILES), make generate TEST=$(file) OUTPUT=$(notdir $(basename $(file))) ARGS=$(ARGS);)

# Debug

debug: debug-compile
	./$(SOURCE) $(ARGS) $(TEST)

debug-compile:
	flex -d $(SOURCE).l
	bison --verbose -d -t --o $(SOURCE).tab.c $(SOURCE).y -yd
	gcc -o $(SOURCE) lex.yy.c $(SOURCE).tab.c $(UTILS).c $(SYMBOLS).c -$(LIB) -g

debug-gdb: debug-compile
	gdb $(SOURCE)

# Clean

clean:
	rm -f lex.yy.c $(SOURCE).tab.c $(SOURCE).tab.h $(SOURCE).output

clean-compiled:
	rm -f $(COMPILED_OUTPUT)*.c

clean-all: clean clean-compiled
	rm -f $(SOURCE)