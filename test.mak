
# Special variables defined by GNU make:
#	AR			Archive-maintaining program; default 'ar'. Produces statically-linked libraries (.a).
#	AS			Program for assembling; default 'as'.
#   CC			Program for compiling C programs; default 'cc'.
#   CXX			Program for compiling C++ programs; default 'g++'.
#   CPP 		Program for running the C preprocessor, printing results to standard output; default "$(CC) -E".
#	ARFLAGS		Flags passed to the archive-maintaining program; default 'rv'.
#   ASFLAGS 	Flags passed to the assembler (when explicitly invoked on a '.s' or '.S' file).
#   CFLAGS		Flags passed to the compiler.
#   CPPFLAGS	Flags passed to the preprocessor and programs that use it (the C and Fortran compilers). 
#   CXXFLAGS	Flags passed to the c++ compiler.
#   LDFLAGS		Flags passed to compilers when they are supposed to invoke the linker, 'ld', such as -L.
#	LDLIBS		Libary flags or names given to compilers when they are supposed to invoke the linker, 'ld'.
#	LOADLIBES	Deprecated alternative to LDLIBS.

AS = AS
CC = CC
CXX = CXX
CPP = CPP
LINT = LINT
ARFLAGS = ARFLAGS
ASFLAGS = ASFLAGS
CFLAGS = CFLAGS
CPPFLAGS = CPPFLAGS
CXXFLAGS = CXXFLAGS
LDFLAGS = LDFLAGS
LDLIBS = LDLIBS
LOADLIBES = LOADLIBES


# IMPLICIT RULES
#   Make has a few hidden rules for processing common filetypes in standard ways.
# 	If a rule has a prereq for one of these filetypes, but no explicit rule exists to make that file,
#	an implicit rule is created automatically to handle it:
#
#		%.o : %.c									# .o (object) files are automatically COMPILEd from .c sources (if they exist).
#			$(CC) $(CPPFLAGS) $(CFLAGS) -c $^
#
#		%.o : %.cpp									# .o (object) files are automatically COMPILEd from .cpp (or .cc) sources (if they exist).
#			$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $^
#
#		%.o : %.s									# .o (object) files are automatically COMPILEd from .s sources (if they exist).
#			$(AS) $(ASFLAGS)						
#
#		%.s : %.S									# .S sources are automatically PREPROCESSed into .s files.
#			$(CPP) $(CPPFLAGS) $^					
#
#		n : n.o										# Binary is automatically LINKed from .o files.
#			$(CC) $(LDFLAGS) n.o $(LOADLIBES) $(LDLIBS)


# Common compiler arguments:
#	-B <dir>	Add directory to compiler search path.
#	-E			Preprocess only; do not compile, assemble, or link.
#	-S			Compile only; do not assemble or link.
#	-c			Compile and assemble; do not link.
#	-o <file>	Place output into this file.


# Default (first) rule: target "all" depends on prereq "bin"
all: 
	printf "LINK.c:       %s\n" "$(LINK.c)"
	printf "LINK.cpp:     %s\n" "$(LINK.cpp)"
	printf "LINK.o:       %s\n" "$(LINK.o)"
	printf "LINK.s:       %s\n" "$(LINK.s)"
	printf "LINK.S:       %s\n" "$(LINK.S)"
	printf "COMPILE.c:    %s\n" "$(COMPILE.c)"
	printf "COMPILE.cpp:  %s\n" "$(COMPILE.cpp)"
	printf "COMPILE.s:    %s\n" "$(COMPILE.s)"
	printf "COMPILE.S:    %s\n" "$(COMPILE.S)"
	printf "PREPROCESS.S: %s\n" "$(PREPROCESS.S)"
	printf "LINT.c:       %s\n" "$(LINT.c)"

# COMPILE.cpp
# COMPILE.mod
# COMPILE.F
# COMPILE.f
# COMPILE.m
# COMPILE.p
# COMPILE.cc
# COMPILE.def
# COMPILE.r
# COMPILE.C
# COMPILE.S
# COMPILE.c 
# COMPILE.s
# LINK.m
# LINK.o
# LINK.p
# LINK.cc
# LINK.r
# LINK.C
# LINK.S
# LINK.c
# LINK.s
# LINK.cpp
# LINK.F
# LINK.f
# LEX.l
# LEX.m
# LINT.c
# PREPROCESS.F
# PREPROCESS.r 
# PREPROCESS.S
# YACC.m
# YACC.y

