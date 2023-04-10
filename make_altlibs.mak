###############################################################################
#
#	TARGET determines which set of C standard libraries are linked with the object (.o) files to create the .elf.
# 
#	TARGET_NEWLIB:	Link with Newlib (default for arm-none-eabi).
#	  -lc	-->	/usr/lib/arm-none-eabi/lib/thumb/nofp/libc.a
#	  -lm	-->	/usr/lib/arm-none-eabi/lib/thumb/nofp/libm.a
#		
#	TARGET_NANO:	Link with Newlib-Nano (provided alongside newlib).
#	  -lc	-->	/usr/lib/arm-none-eabi/lib/thumb/nofp/libc_nano.a
#	  -lm	-->	/usr/lib/arm-none-eabi/lib/thumb/nofp/libm.a
#
#	TARGET_PICO:	Link with Picolibc (See 3rdparty/picolibc).
#	  -lc	-->	./3rdparty/picolibc/arm-none-eabi/lib/thumb/nofp/libc.a
#	  -lm	--> ./3rdparty/picolibc/arm-none-eabi/lib/thumb/nofp/libm.a
#
#	Free memory remaining on NXT after fwflash:
#	  TARGET_NEWLIB:	 99024 bytes
#	  TARGET_NANO:		125188 bytes
#	  TARGET_PICO:		128744 bytes
#
TARGET_NEWLIB = nxt_firmware_newlib
TARGET_NANO = nxt_firmware_nano
TARGET_PICO = nxt_firmware_pico

# Choose a target:
TARGET = $(TARGET_PICO)

# Set to 'y' to enable embedded debugger.
ARMDEBUG = n

###############################################################################

# Set paths
BASE = .
SRCDIR = $(BASE)/src
LIBDIR = $(BASE)/lib
DBGDIR = $(BASE)/armdebug/Debugger
CPUINCDIR = $(BASE)/include
STARTUPDIR = $(BASE)/startup
3RDPARTYDIR = $(BASE)/3rdparty
OBJDIR = $(BASE)/build

# Search for source files (.c, .S) in these paths.
vpath %.c $(SRCDIR)
vpath %.c $(LIBDIR)
vpath %.c $(STARTUPDIR)
vpath %.S $(STARTUPDIR)

# Toolchain prefix; needs to be changed if not on the PATH.
CROSS_COMPILE = arm-none-eabi-

# Build Tools
CC = $(CROSS_COMPILE)gcc
OBJDUMP = $(CROSS_COMPILE)objdump
OBJCOPY = $(CROSS_COMPILE)objcopy

# Optional program (from libnxt) which flashes the firmware to an NXT.
FWFLASH = fwflash

# THUMB is an alternate mode for 32-bit ARM processors in which instructions are only 16-bit.
# This results in a much smaller binary and therefore less flash/RAM usage.
# CPU must start in 32-bit ARM mode (Cstartup.S) and then switch to THUMB mode.
# NOTE: sources in ./lib are appended separately, depending on TARGET.
ARM_C_SOURCES =
ARM_ASM_SOURCES = Cstartup.S
THUMB_C_SOURCES = c_button.c c_cmd.c c_comm.c c_display.c c_input.c c_ioctrl.c \
		          c_loader.c c_lowspeed.c c_output.c c_sound.c c_ui.c \
                  d_bt.c d_button.c d_display.c d_hispeed.c d_input.c \
                  d_ioctrl.c d_loader.c d_lowspeed.c d_output.c d_sound.c \
                  d_timer.c d_usb.c \
                  m_sched.c \
                  Cstartup_SAM7.c
THUMB_ASM_SOURCES =

# Add some additional sources if compiling with ARMDEBUG=y
ifeq ($(ARMDEBUG),y)
    ARM_ASM_SOURCES += abort_handler.S undef_handler.S debug_hexutils.S \
                       debug_stub.S debug_comm.S debug_opcodes.S \
                       debug_runlooptasks.S
    vpath %.S $(DBGDIR)
    DEFINES += -DARMDEBUG
    INCLUDES += -I$(DBGDIR)
endif

# Compiler include flag (-I). When #include "..." is used, look in this directory in addition to the src paths.
INCLUDES = -I$(CPUINCDIR)

# Linker script describes the memory layout of the resulting executable
LDSCRIPT = $(LIBDIR)/nxt.ld

# OBJECTS: All the sources (.c, .S) will be compiled to objects (.o) with the same basename.
# SRC_DEPENDS: All objects (.o) will have a corresponding .d file after the compilation step.
ARM_OBJECTS =   $(addprefix $(OBJDIR)/, $(ARM_C_SOURCES:%.c=%.o)   $(ARM_ASM_SOURCES:%.S=%.o)   )
THUMB_OBJECTS = $(addprefix $(OBJDIR)/, $(THUMB_C_SOURCES:%.c=%.o) $(THUMB_ASM_SOURCES:%.S=%.o) )
C_OBJECTS =     $(addprefix $(OBJDIR)/, $(ARM_C_SOURCES:%.c=%.o)   $(THUMB_C_SOURCES:%.c=%.o)   )
ASM_OBJECTS =   $(addprefix $(OBJDIR)/, $(ARM_ASM_SOURCES:%.S=%.o) $(THUMB_ASM_SOURCES:%.S=%.o) )
OBJECTS =       $(ARM_OBJECTS) $(THUMB_OBJECTS)
SRC_DEPENDS =   $(OBJECTS:%.o=%.d)

# Gets the date&time into BUILD_DATE variable, and sets LAST_BUILD_DATE from version.mak (if it exists).
DATE_FMT = +%Y-%m-%dT%H:%M
ifndef SOURCE_DATE_EPOCH
    SOURCE_DATE_EPOCH = $(shell git log -1 --pretty=%ct)
endif
BUILD_DATE ?= $(shell LC_ALL=C date -u -d "@$(SOURCE_DATE_EPOCH)" "$(DATE_FMT)" 2>/dev/null \
	               || LC_ALL=C date -u -r "$(SOURCE_DATE_EPOCH)" "$(DATE_FMT)" 2>/dev/null \
	               || LC_ALL=C date -u "$(DATE_FMT)" )
LAST_BUILD_DATE=none
-include version.mak


# NXT main processor is the Atmel AT91SAM7S256.
#	- 256kB Flash
#	- 64 kB RAM
#   - No hardware floating point unit
#	- Little-endian (default for all ARM processors)
# According to Wikipedia:
#	- AT91SAM7 family uses ARM7TDMI cores.
#	- AT91SAM7S family adds support for USB and other peripherals. SAM7S 64-pin chips are compatible with SAM4S, SAM4N SAM3S, SAM3N families.
#   - ARM7TDMI (ARM7 + 16 bit Thumb + JTAG Debug + fast Multiplier + enhanced ICE) processors implement the ARMv4T instruction set.
MCUFLAGS = -mcpu=arm7tdmi

# Compiler defines
STARTOFUSERFLASH_DEFINES = -DSTARTOFUSERFLASH_FROM_LINKER=1
VERSION_DEFINES = -D'BUILD_DATE="$(BUILD_DATE)"'
DEFINES = -DPROTOTYPE_PCB_4 -DNEW_MENU -DROM_RUN -DVECTORS_IN_RAM $(STARTOFUSERFLASH_DEFINES) $(VERSION_DEFINES)


# Compiler optimization flags:
#	-Os						Optimize for size. -Os enables all -O2 optimizations that do not typically increase code size.
#							It also performs further optimizations designed to reduce code size. 
#	-fno-strict-aliasing	Strict aliasing is an assumption, made by the C (or C++) compiler, that
#							dereferencing pointers to objects of different types will never refer to the same memory location (i.e. alias each other.)
#							This may break some low-level code which manipulates memory directly.
#	-ffunction-sections		
#	-fdata-sections			Place each function or data item into its own section in the output file.
#							The name of the function or data item determines the section's name in the output file. 
#   -flto					Enable link-time optimizations. May break compatibility with some libraries.
OPTIMIZE = -Os -fno-strict-aliasing \
	   -ffunction-sections -fdata-sections

# Compiler specs flags:
#	--specs=... .specs		Specs files contain "specs strings" which are commands that add/modify command-line arguments, set variables, etc.
SPECS = 

# Compiler warning flags:
#	-Wall
#	-W
#	-Wundef
#	-Wno-unused
#	-Wno-format
WARNINGS = -Wall -W -Wundef -Wno-unused -Wno-format

# Additional flags for TARGET = $(TARGET_NANO)
ifeq ($(TARGET),$(TARGET_NANO))
SPECS += --specs=nano.specs
OPTIMIZE += -flto
THUMB_C_SOURCES += abort.c errno.c sbrk.c strtod.c sscanf.c

# Additional flags for TARGET = $(TARGET_PICO)
else ifeq ($(TARGET),$(TARGET_PICO))
SPECS += --picolibc-prefix=$(3RDPARTYDIR)/picolibc_dist --specs=$(3RDPARTYDIR)/picolibc_dist/picolibc/picolibc.specs
DEFINES += -DPICOLIBC_FLOAT_PRINTF_SCANF 
OPTIMIZE += -flto
THUMB_C_SOURCES += sscanf.c
# The remaining functions in ./lib do not seem to offer memory savings when linking against picolibc.

# Additional flags for TARGET = $(TARGET_NEWLIB) (default option)
else
TARGET = $(TARGET_NEWLIB)
THUMB_C_SOURCES += abort.c errno.c sbrk.c strtod.c sscanf.c
endif

# Common gcc arguments:
#	-B <dir>	Add directory to compiler search path.
#	-E			Preprocess only; do not compile, assemble, or link.
#	-S			Compile only; do not assemble or link.
#	-c			Compile and assemble; do not link.
#	-o <file>	Place output into this file.

# Additional Flags:
#	-g 					Produce debugging information for GDB.
#	-mcpu				Sets both the -march and -mtune options according to the specific processor.
#	-thumb				Set by certain rules.
#	-mthumb-interwork	Generate code that supports calling between the ARM and Thumb instruction sets. Without this option, on pre-v5 architectures, the two instruction sets cannot be reliably used inside one program.
#	-MMD				Generate .d files alongside each .o file. See the RULES section below, in which all .d files are -included.
#	-nostdlib			Do not link any of the standard system libraries or startup files.
#	-T <script>			Specify a linker script
#	-Wl,				Pass comma-separated <options> on to the linker.
#		--gc-sections	Perform a post-compilation garbage collection of unused code and data.
#		--trace			Print all the files participating in the linking process.
#	-lc					Link "libc.a" which is provided by Newlib.
#	-lm					Link "libm.a" which is provided by Newlib.
#	-lgcc				Link "libgcc.a" which is typically required for gcc to work, even with -nostdlib.
#	   					 -->	/usr/lib/gcc/arm-none-eabi/9.2.1/thumb/nofp/libgcc.a (path depends on gcc version)
#	-lnosys				Link "libnosys.a" which is provided by Newlib. Nosys library contains set of default syscall stubs. Majority of the stubs just returns failure.
#	  					 -->	/usr/lib/arm-none-eabi/lib/thumb/nofp/libnosys.a
#						  NOTE: Some of these syscalls are overridden with custom definitions. See ./lib directory.
#
ASFLAGS = -g $(MCUFLAGS) $(THUMB) -mthumb-interwork
CFLAGS = -g $(MCUFLAGS) $(THUMB) -mthumb-interwork $(WARNINGS) $(OPTIMIZE)
CPPFLAGS = $(INCLUDES) $(DEFINES) -MMD $(SPECS) 
LDFLAGS = -nostdlib -T $(LDSCRIPT) -Wl,--gc-sections -Wl,--trace
LDLIBS = -lc -lm -lgcc -lnosys



###############################################################################

.PHONY: all
all: bin sym lst

# Output file types:
#	bin:	Reformatted .elf which can be flashed to the NXT
#	sym:	Symbols and section header info from the .elf
#	lst:	Disassembly info from the .elf
#	elf:	Linker output
.PHONY: bin sym lst elf
bin: $(TARGET).bin
sym: $(TARGET).sym
lst: $(TARGET).lst
elf: $(TARGET).elf

# .bin, .sym, .lst all depend on .elf.
#	OBJCOPY: Reformat .elf to the size expected by the CPU, finally producing a .bin which can be flashed to the NXT.
#	OBJDUMP: Print info about the .elf file:
#	 -h		Display contents of the section headers
#	 -t		Display contents of the symbol tables
#	 -S		Intermix source code with disassembly.
%.bin: %.elf
	@printf "\n\nCreating executable binary from ELF: %s...\n" "$@"
	$(OBJCOPY) --pad-to=0x140000 --gap-fill=0xff -O binary $< $@

%.sym: %.elf
	@printf "\n\nWriting info file: %s...\n" "$@"
	$(OBJDUMP) -h -t $< > $@

%.lst: %.elf
	@printf "\n\nWriting disassembly file %s...\n" "$@"
	$(OBJDUMP) -S $< > $@


# .elf depends on all object (.o) files and the linker script (.ld)
#	Set the -mthumb flag during linking.
#	LINK.c: Link the .o files and .a libraries into a .elf binary. Command expands to:
#		$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $(OBJECTS) $(LOADLIBES) $(LDLIBS) -o $@
%.elf: THUMB = -mthumb
%.elf: $(OBJECTS) $(LDSCRIPT)
	@printf "\n\nLinking objects into %s...\n" "$@"
	$(LINK.c) $(OBJECTS) $(LOADLIBES) $(LDLIBS) -o $@

# Make sure the OBJDIR exists before compiling any objects
$(OBJECTS): | $(OBJDIR)
$(OBJDIR):
	@printf "\n\nCreating object directory: %s" "$(OBJDIR)"
	mkdir -p "$(OBJDIR)"

# Use -mthumb flag when compiling THUMB objects.
$(THUMB_OBJECTS): THUMB = -mthumb

# .o depends on all #includes in its source file.
#   During compilation, .d files are created for each .o file (-MMD flag).
#   Each .d contains an empty make rule for its object, specifying dependencies on everything #included by the source file.
-include $(SRC_DEPENDS)


$(C_OBJECTS): $(OBJDIR)/%.o: %.c
	@printf "\n\nCompiling source file: %s...\n" "$<"
	$(COMPILE.c) -o $@ $<

$(ASM_OBJECTS): $(OBJDIR)/%.o: %.S
	@printf "\n\nCompiling source file: %s...\n" "$<"
	$(COMPILE.S) -o $@ $<


# c_ui.o depends on BtTest.inc depends on BUILD_DATE.
c_ui.o: version.mak


# version.mak should be updated with the LAST_BUILD_DATE.
ifneq ($(LAST_BUILD_DATE),$(BUILD_DATE))
.PHONY: version.mak
version.mak:
	echo "LAST_BUILD_DATE = $(BUILD_DATE)" > $@
endif


# Optional rule (make program) which flashes the .bin firmware to the NXT
.PHONY: program
program: $(TARGET).bin
	$(FWFLASH) $<


# Optional rule (make clean) which deletes all make-generated files.
.PHONY: clean
clean:
	@printf "\n\nCleaning build files for TARGET=%s...\n" "$(TARGET)"
	rm -f $(TARGET).bin $(TARGET).sym $(TARGET).lst $(TARGET).elf $(OBJECTS) $(SRC_DEPENDS) version.mak



