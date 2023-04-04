###############################################################################
####                            VARIABLES                                  ####
###############################################################################

# Set paths
BASE = .
SRCDIR = $(BASE)/src
LIBDIR = $(BASE)/lib
DBGDIR = $(BASE)/armdebug/Debugger
CPUINCDIR = $(BASE)/include
STARTUPDIR = $(BASE)/startup

# Gets the date&time into BUILD_DATE.
# BUILD_DATE compiler define is required by "BtTest.inc".
# Added to DEFINES list further down.
DATE_FMT = +%Y-%m-%dT%H:%M
ifndef SOURCE_DATE_EPOCH
    SOURCE_DATE_EPOCH = $(shell git log -1 --pretty=%ct)
endif
BUILD_DATE ?= $(shell LC_ALL=C date -u -d "@$(SOURCE_DATE_EPOCH)" "$(DATE_FMT)" 2>/dev/null \
	      || LC_ALL=C date -u -r "$(SOURCE_DATE_EPOCH)" "$(DATE_FMT)" 2>/dev/null \
	      || LC_ALL=C date -u "$(DATE_FMT)")

# Name of output binary
TARGET = nxt_firmware_nosys

# Set to 'y' to enable embedded debugger.
ARMDEBUG = n

# THUMB is an alternate mode for 32-bit ARM processors in which instructions are only 16-bit.
# This results in a much smaller binary and therefore less flash/RAM usage.
# CPU must start in 32-bit ARM mode (Cstartup.S) and then switch to THUMB mode.
ARM_SOURCES =
THUMB_SOURCES = c_button.c c_cmd.c c_comm.c c_display.c c_input.c c_ioctrl.c \
		c_loader.c c_lowspeed.c c_output.c c_sound.c c_ui.c \
		d_bt.c d_button.c d_display.c d_hispeed.c d_input.c \
		d_ioctrl.c d_loader.c d_lowspeed.c d_output.c d_sound.c \
		d_timer.c d_usb.c \
		m_sched.c \
		abort.c errno.c sbrk.c strtod.c sscanf.c \
		Cstartup_SAM7.c

ASM_ARM_SOURCE = Cstartup.S
ASM_THUMB_SOURCE =

# vpath: search for source files (.c, .S) in these paths.
vpath %.c $(SRCDIR)
vpath %.c $(LIBDIR)
vpath %.c $(STARTUPDIR)
vpath %.S $(STARTUPDIR)

# Compiler include flag (-I). When #include "..." is used, look in this directory in addition to the src paths.
INCLUDES = -I$(CPUINCDIR)

# NXT main processor is the Atmel AT91SAM7S256.
#	- 256kB Flash
#	- 64 kB RAM
#   - No hardware floating point unit
#	- Little-endian (default for all ARM processors)
# According to Wikipedia:
#	- AT91SAM7 family uses ARM7TDMI cores.
#	- AT91SAM7S family adds support for USB and other peripherals. SAM7S 64-pin chips are compatible with SAM4S, SAM4N SAM3S, SAM3N families.
#   - ARM7TDMI (ARM7 + 16 bit Thumb + JTAG Debug + fast Multiplier + enhanced ICE) processors implement the ARMv4T instruction set.
# This is appended to the compiler/assembler's -mcpu=...  flag.
MCU = arm7tdmi

# Compiler defines
STARTOFUSERFLASH_DEFINES = -DSTARTOFUSERFLASH_FROM_LINKER=1
VERSION_DEFINES = -D'BUILD_DATE="$(BUILD_DATE)"'
DEFINES = -DPROTOTYPE_PCB_4 -DNEW_MENU -DROM_RUN -DVECTORS_IN_RAM \
	  $(STARTOFUSERFLASH_DEFINES) $(VERSION_DEFINES)

# Compiler optimization flags:
#	-Os						Optimize for size. -Os enables all -O2 optimizations that do not typically increase code size.
#							It also performs further optimizations designed to reduce code size. 
#	-fno-strict-aliasing	Strict aliasing is an assumption, made by the C (or C++) compiler, that
#							dereferencing pointers to objects of different types will never refer to the same memory location (i.e. alias each other.)
#							This may break some low-level code which manipulates memory directly.
#	-ffunction-sections		
#	-fdata-sections			Place each function or data item into its own section in the output file if the target supports arbitrary sections.
#							The name of the function or the name of the data item determines the section's name in the output file. 
OPTIMIZE = -Os -fno-strict-aliasing \
	   -ffunction-sections -fdata-sections

# More compiler flags
#	-Wall
#	-W
#	-Wundef
#	-Wno-unused
#	-Wno-format
#	-mthumb-interwork		Generate code that supports calling between the ARM and Thumb instruction sets. Without this option, on pre-v5 architectures, the two instruction sets cannot be reliably used inside one program.
WARNINGS = -Wall -W -Wundef -Wno-unused -Wno-format
THUMB_INTERWORK = -mthumb-interwork

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

# Compiler and assembler arguments
#	THUMB flag is set by certain rules.
#	-g 			Produce debugging information in the operating system’s native format (stored in the object files). GDB can work with this debugging information.
#	-mcpu		Sets both the -march and -mtune options according to the specific processor.
#	-MMD		Generate .d files alongside each .o file. See the RULES section below, in which all .d files are -included.
CFLAGS = -g -mcpu=$(MCU) $(THUMB) $(THUMB_INTERWORK) $(WARNINGS) $(OPTIMIZE)
ASFLAGS = -g -mcpu=$(MCU) $(THUMB) $(THUMB_INTERWORK)
CPPFLAGS = $(INCLUDES) $(DEFINES) -MMD

# Linker script; describes the memory layout of the resulting executable (.bin)
LDSCRIPT = $(LIBDIR)/nxt.ld

# Linker arguments
#	-nostdlib			Do not link any of the standard system libraries or startup files.
#	-T <script>			Specify a linker script
#	-Wl,				Pass comma-separated <options> on to the linker.
#		--gc-sections	Perform a post-compilation garbage collection of unused code and data.
#	-lc					Link "libc.a" which is provided by Newlib.
#	-lm					Link "libm.a" which is provided by Newlib.
#	-lgcc				Link "libgcc.a" which is typically required for gcc to work, even with -nostdlib
#	-lnosys				Link "libnosys.a" which is provided by Newlib. Nosys library contains set of default syscall stubs. Majority of the stubs just returns failure.
#						  NOTE: Some of these syscalls are overridden with custom definitions. See ./lib directory.
LDFLAGS = -nostdlib -T $(LDSCRIPT) -Wl,--gc-sections
LDLIBS = --specs=nosys.specs -lc -lm -lgcc -lnosys

# Add some additional files for the debugger if compiling with ARMDEBUG=y
ifeq ($(ARMDEBUG),y)
ASM_ARM_SOURCE += abort_handler.S undef_handler.S debug_hexutils.S \
                  debug_stub.S debug_comm.S debug_opcodes.S \
                  debug_runlooptasks.S
vpath %.S $(DBGDIR)
DEFINES += -DARMDEBUG
INCLUDES += -I$(DBGDIR)
endif

# Toolchain prefix; needs to be changed if the executables are not on the PATH.
CROSS_COMPILE = arm-none-eabi-

# GCC: ARM EABI compiler
CC = $(CROSS_COMPILE)gcc

# OBJDUMP: Program which prints info about object (.o) files.
OBJDUMP = $(CROSS_COMPILE)objdump

# OBJCOPY: Program which reads .o files and produces the final binary
OBJCOPY = $(CROSS_COMPILE)objcopy

# FWFLASH: Optional program (from libnxt) which flashes the firmware to an NXT
FWFLASH = fwflash

# OBJECTS: All the sources (.c, .S) will be compiled to objects (.o) with the same basename.
ARM_OBJECTS = $(ARM_SOURCES:%.c=%.o) $(ASM_ARM_SOURCE:%.S=%.o)
THUMB_OBJECTS = $(THUMB_SOURCES:%.c=%.o) $(THUMB_ARM_SOURCE:%.S=%.o)
OBJECTS = $(ARM_OBJECTS) $(THUMB_OBJECTS)


###############################################################################
####                              RULES                                    ####
###############################################################################

# RULES
#	Rules are formatted like:
#
#	TARGET : PREREQS
#		COMMANDS
#	
#	COMMANDS to make the TARGET are run when all PREREQS are satisfied.
#	  - TARGET is the name of the rule.
#			If TARGET is older than any of its PREREQs, it must be rebuilt.
#	  - PREREQS is a space-separated list of other targets which must be completed first.
#			If a PREREQ is a file, its modification time is checked.
#	  - COMMANDS (optional) are terminal commands which are run when all prereqs are satisfied.
#			Each line MUST start with a tab (not spaces!).
#	

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
#		%.o : %.s									# .o (object) files are automatically ASSEMBLEd from .s sources (if they exist).
#			$(AS) $(ASFLAGS)						
#
#		%.s : %.S									# .S sources are automatically PREPROCESSed into .s files.
#			$(CPP) $(CPPFLAGS) $^					
#
#		n : n.o										# Binary is automatically LINKed from .o files.
#			$(CC) $(LDFLAGS) n.o $(LOADLIBES) $(LDLIBS)
#

# IMPLICIT COMMANDS
#	Make defines variables containing commands for common operations.
#	For c, cpp, o, s, S, the following commands are defined:
#
#	LINK produces an executable from the specified filetype.
#     $(LINK.c)       --> $(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS)
#     $(LINK.cpp)     --> $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(LDFLAGS)	# Same for '.cc' files.
#     $(LINK.o)       --> $(CC) $(LDFLAGS)
#     $(LINK.s)       --> $(CC) $(ASFLAGS) $(LDFLAGS)
#     $(LINK.S)       --> $(CC) $(ASFLAGS) $(CPPFLAGS) $(LDFLAGS)
#
#	COMPILE produces an object (.o) file from the specified filetype, but does not link.
#     $(COMPILE.c)    --> $(CC) $(CFLAGS) $(CPPFLAGS) -c
#     $(COMPILE.cpp)  --> $(CXX) $(CXXFLAGS) $(CPPFLAGS) -c		# Same for '.cc' files.
#     $(COMPILE.s)    --> $(AS) $(ASFLAGS) 
#     $(COMPILE.S)    --> $(CC) $(ASFLAGS) $(CPPFLAGS) -c
#
#	PREPROCESS runs the preprocessor on a .S assembly file to produce a .s assembly file.
#     $(PREPROCESS.S) --> $(CC) -E $(CPPFLAGS)
#
#	LINT runs a linter on a source file. Command-line linters are typically not installed by default.
#     $(LINT.c)       --> $(LINT) CPPFLAGS 

# SPECIAL VARIABLES
#	These variables are defined in the COMMANDS section of a rule:
#	  $@	is the name of the current target.
#	  $<	is the name of the first dependency
#	  $^	is the list of all dependencies (space-separated).

# Common gcc arguments:
#	-B <dir>	Add directory to compiler search path.
#	-E			Preprocess only; do not compile, assemble, or link.
#	-S			Compile only; do not assemble or link.
#	-c			Compile and assemble; do not link.
#	-o <file>	Place output into this file.


# Default (first) rule: target "all" depends on prereq "bin"
all: bin

# Rules for output files:
#	elf:	binary output of the linker. 
#	bin:	reformatted .elf which can be flashed to the NXT
#	sym:	info about the .elf
#	lst:	info about the .elf
# TARGET is "nxt_firmware" by default.
elf: $(TARGET).elf
bin: $(TARGET).bin
sym: $(TARGET).sym
lst: $(TARGET).lst

# TARGET.elf depends on all object (.o) files and also the linker script (.ld)
#	Set the -mthumb flag. 
#	Link the .o files into a .elf binary.
#	(Why are we using LINK.c instead of LINK.o here?)
$(TARGET).elf: THUMB = -mthumb
$(TARGET).elf: $(OBJECTS) $(LDSCRIPT)
	$(LINK.c) $(OBJECTS) $(LOADLIBES) $(LDLIBS) -o $@
# This command expands to:
#	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $(OBJECTS) $(LOADLIBES) $(LDLIBS) -o $@

# Implicit rules are used to compile the source files (.c, .s, .S) into object (.o) files.
#		%.o : %.c
#			$(CC) $(CPPFLAGS) $(CFLAGS) -c $^

# %.bin depends on %.elf
#	Pad %.elf to the size expected by the CPU, finally producing %.bin which can be flashed to the NXT.
%.bin: %.elf
	$(OBJCOPY) --pad-to=0x140000 --gap-fill=0xff -O binary $< $@

# %.sym depends on %.elf (.sym is not created unless user ran "make sym")
#	$<		Read from %.elf file.
#	-h		Display contents of the section headers
#	-t		Display contents of the symbol tables
#	> $@	Linux command syntax; write output to a file called $@ (substitutes to %.sym).
%.sym: %.elf
	$(OBJDUMP) -h -t $< > $@

# %.lst depends on %.elf (.lst is not created unless user ran "make lst")
#	$<		Read from %.elf file.
#	-S		Intermix source code with disassembly.
#	> $@	Linux command syntax; write output to a file called $@ (substitutes to %.lst).
%.lst: %.elf
	$(OBJDUMP) -S $< > $@

# Rule which matches any object (.o) file in the THUMB_OBJECTS list.
#	Add the -mthumb flag when processing.
$(THUMB_OBJECTS): THUMB = -mthumb

# During compilation, .d files are created for each .o file.
# Each .d contains a make rule for its object, with dependencies on everything #included by the source file.
# Since the COMMANDS section is empty for each of these rules, they do not override the implicit rule which builds .o files.
-include $(OBJECTS:%.o=%.d)



# BUILD_DATE define is required by "BtTest.inc".
#   ->  "BtTest.inc"    is #included in "Functions.inl"
#   ->  "Functions.inl" is #included in "c_ui.c"
#	->  "c_ui.c" compiles to "c_ui.o"
# Therefore whenever c_ui.o is built, version.mak should be updated with the BUILD_DATE
LAST_BUILD_DATE=none
-include version.mak
ifneq ($(LAST_BUILD_DATE),$(BUILD_DATE))
.PHONY: version.mak
version.mak:
	echo "LAST_BUILD_DATE = $(BUILD_DATE)" > $@
endif

c_ui.o: version.mak

# Optional rule (make program) which flashes the .bin firmware to the NXT
program: $(TARGET).bin
	$(FWFLASH) $(TARGET).bin

# Optional rule (make clean) which deletes all make-generated files.
clean:
	rm -f $(TARGET).elf $(TARGET).bin $(TARGET).sym $(TARGET).lst \
	$(OBJECTS) $(OBJECTS:%.o=%.d) version.mak
