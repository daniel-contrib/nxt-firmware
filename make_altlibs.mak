###############################################################################
#
# LIBC determines which set of C standard libraries are linked with the object (.o) files to create the .elf.
# 
# LIBC_NEWLIB: Link with Newlib (default for arm-none-eabi).
#   -lc --> /usr/lib/arm-none-eabi/lib/thumb/nofp/libc.a
#   -lm --> /usr/lib/arm-none-eabi/lib/thumb/nofp/libm.a
# 
# LIBC_NANO: Link with Newlib-Nano (provided with Newlib).
#   -lc --> /usr/lib/arm-none-eabi/lib/thumb/nofp/libc_nano.a
#   -lm --> /usr/lib/arm-none-eabi/lib/thumb/nofp/libm.a
#
# LIBC_PICO: Link with Picolibc (https://github.com/picolibc/picolibc/).
#   -lc --> ./lib/picolibc/arm-none-eabi/lib/thumb/nofp/libc.a
#   -lm --> ./lib/picolibc/arm-none-eabi/lib/thumb/nofp/libm.a
#
# Free memory remaining on NXT after fwflash:
#   LIBC_NEWLIB:   99024 bytes
#   LIBC_NANO:    125188 bytes
#   LIBC_PICO:    129504 bytes (local custom build)
#   LIBC_PICO:    128744 bytes (release build)
#
LIBC_NEWLIB = newlib
LIBC_NANO = nano
LIBC_PICO = pico

# Choose a LIBC:
LIBC ?= $(LIBC_PICO)

# Output file:
TARGET ?= nxt_firmware_$(LIBC)

# Set to 'y' to enable embedded debugger.
ARMDEBUG ?= n

###############################################################################

# Paths
BASE = .
SRCDIR = $(BASE)/src
LIBDIR = $(BASE)/lib
DBGDIR = $(BASE)/armdebug/Debugger
CPUINCDIR = $(BASE)/include
STARTUPDIR = $(BASE)/startup
3RDPARTYDIR = $(BASE)/3rdparty
OBJDIR = $(BASE)/build

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
# CPU starts in 32-bit ARM mode (Cstartup.S) and then switches to THUMB mode.
ARM_C_SOURCES =     
ARM_ASM_SOURCES =   Cstartup.S
THUMB_C_SOURCES =   c_button.c c_cmd.c c_comm.c c_display.c c_input.c c_ioctrl.c \
                    c_loader.c c_lowspeed.c c_output.c c_sound.c c_ui.c \
                    d_bt.c d_button.c d_display.c d_hispeed.c d_input.c \
                    d_ioctrl.c d_loader.c d_lowspeed.c d_output.c d_sound.c \
                    d_timer.c d_usb.c \
                    m_sched.c \
                    Cstartup_SAM7.c
THUMB_ASM_SOURCES =

# Search for source files (.c, .S) in these paths.
vpath %.c $(SRCDIR)
vpath %.c $(STARTUPDIR)
vpath %.S $(STARTUPDIR)

# List of directories to search for #included files. (-I flags are added later)
INCLUDE_PATHS = $(CPUINCDIR)

# List of library names (lib*.a, lib*.so) to link. (-l flags are added later.)
#   c       Link "libc.a" which is provided by Newlib (or Picolibc). Which libc is chosen by the LIBC variable above.
#   m       Link "libm.a" which is provided by Newlib (or Picolibc). Which libm is chosen by the LIBC variable above.
#   gcc     Link "libgcc.a" which is typically required for gcc to work when using -nostdlib.
#   nosys   Link "libnosys.a" which is provided by Newlib. Nosys library contains set of default syscall stubs. Majority of the stubs just returns failure.
#           Some of these syscalls are overridden with custom definitions. See ./lib directory.
LIB_NAMES = c m gcc nosys

# List of directories to search when linking library files. (-L flags are added later)
LIB_PATHS = $(LIBDIR)

# Linker script describes the memory layout of the resulting executable (-T flag is added later)
LDSCRIPT = $(LIBDIR)/nxt.ld

# NXT main processor is the Atmel AT91SAM7S256.
#  - 256kB Flash
#  - 64 kB RAM
#  - No hardware floating point unit
#  - Little-endian (default for all ARM processors)
# According to Wikipedia:
#  - AT91SAM7 family uses ARM7TDMI cores.
#  - AT91SAM7S family adds support for USB and other peripherals.
#  - ARM7TDMI (ARM7 + 16 bit Thumb + JTAG Debug + fast Multiplier + enhanced ICE) processors implement the ARMv4T instruction set.
# Compiler flags:
#  -mcpu=...          Sets both the -march and -mtune options according to the specific processor.
#  -mthumb-interwork  Generate code that supports calling between the ARM and Thumb instruction sets. Without this option, on pre-v5 architectures, the two instruction sets cannot be reliably used inside one program.
ARCHFLAGS = -mcpu=arm7tdmi
THUMBINTERWORK = -mthumb-interwork

# Preprocessor definition flags:
DEFINES = -DPROTOTYPE_PCB_4 -DNEW_MENU -DROM_RUN -DVECTORS_IN_RAM \
          -DSTARTOFUSERFLASH_FROM_LINKER=1  \
          -D'BUILD_DATE="$(BUILD_DATE)"'

# Optimization flags:
#   -Os                   Optimize for size. -Os enables all -O2 optimizations that do not typically increase code size.
#                         It also performs further optimizations designed to reduce code size. 
#   -fno-strict-aliasing  Strict aliasing is an assumption, made by the C (or C++) compiler, that
#                         dereferencing pointers to objects of different types will never refer to the same memory location (i.e. alias each other.)
#                         Strict aliasing may break some low-level code which manipulates memory directly.
#   -ffunction-sections
#   -fdata-sections       Place each function or data item into its own section in the output file.
#                         The name of the function or data item determines the section's name in the output file. 
#   -flto                 Enable link-time optimizations. May break compatibility with some libraries.
OPTIMIZE = -Os -fno-strict-aliasing -ffunction-sections -fdata-sections

# Specs flags:
#   --specs=*.specs       Specs files contain commands that modify command-line arguments, set variables, etc.
SPECS = 

# Compiler warning flags:
WARNINGS = -Wall -W -Wundef -Wno-unused -Wno-format

# Additional flags for ARMDEBUG = y
ifeq ($(ARMDEBUG),y)
    DEFINES += -DARMDEBUG
    INCLUDE_PATHS += $(DBGDIR)
    ARM_ASM_SOURCES += abort_handler.S undef_handler.S debug_hexutils.S \
                       debug_stub.S debug_comm.S debug_opcodes.S \
                       debug_runlooptasks.S
    vpath %.S $(DBGDIR)
endif

# Additional flags for LIBC = LIBC_NANO
ifeq ($(LIBC),$(LIBC_NANO))
  SPECS += --specs=nano.specs
  OPTIMIZE += -flto
  THUMB_C_SOURCES += abort.c errno.c sbrk.c strtod.c sscanf.c
  vpath %.c $(LIBDIR)

# Additional flags for LIBC = LIBC_PICO
else ifeq ($(LIBC),$(LIBC_PICO))
  #SPECS += --picolibc-prefix=$(LIBDIR) --specs=$(LIBDIR)/picolibc/picolibc.specs
  #DEFINES += -DPICOLIBC_FLOAT_PRINTF_SCANF 
  INCLUDE_PATHS += $(LIBDIR)/picolibc/arm-none-eabi/include
  LIB_PATHS += $(LIBDIR)/picolibc/arm-none-eabi/lib/thumb/nofp
  OPTIMIZE += -flto
  THUMB_C_SOURCES += sscanf.c
  vpath %.c $(LIBDIR)

# Additional flags for LIBC = LIBC_NEWLIB (default option)
else
  LIBC = $(LIBC_NEWLIB)
  THUMB_C_SOURCES += abort.c errno.c sbrk.c strtod.c sscanf.c
  vpath %.c $(LIBDIR)
endif



###############################################################################

# Gets the git date&time into BUILD_DATE variable, and sets LAST_BUILD_DATE from version.mak (if it exists).
DATE_FMT = +%Y-%m-%dT%H:%M
ifndef SOURCE_DATE_EPOCH
    SOURCE_DATE_EPOCH = $(shell git log -1 --pretty=%ct)
endif
BUILD_DATE ?= $(shell LC_ALL=C date -u -d "@$(SOURCE_DATE_EPOCH)" "$(DATE_FMT)" 2>/dev/null \
                   || LC_ALL=C date -u -r "$(SOURCE_DATE_EPOCH)" "$(DATE_FMT)" 2>/dev/null \
                   || LC_ALL=C date -u "$(DATE_FMT)" )
LAST_BUILD_DATE=none
-include version.mak

# Sources (.c, .S) will be compiled to objects (.o) with the same basename.
ARM_OBJECTS =   $(addprefix $(OBJDIR)/, $(ARM_C_SOURCES:%.c=%.o)   $(ARM_ASM_SOURCES:%.S=%.o)   )
THUMB_OBJECTS = $(addprefix $(OBJDIR)/, $(THUMB_C_SOURCES:%.c=%.o) $(THUMB_ASM_SOURCES:%.S=%.o) )
C_OBJECTS =     $(addprefix $(OBJDIR)/, $(ARM_C_SOURCES:%.c=%.o)   $(THUMB_C_SOURCES:%.c=%.o)   )
ASM_OBJECTS =   $(addprefix $(OBJDIR)/, $(ARM_ASM_SOURCES:%.S=%.o) $(THUMB_ASM_SOURCES:%.S=%.o) )
OBJECTS =       $(ARM_OBJECTS) $(THUMB_OBJECTS)

# Objects (.o) will have a corresponding .d file after the compilation step, containing additional makefile dependencies.
SRC_DEPENDS =   $(OBJECTS:%.o=%.d)

# Compiler #include paths (-I), linker library paths (-L), library names (-l)
INCPATH_FLAGS = $(addprefix -I, $(INCLUDE_PATHS) )
LIBPATH_FLAGS = $(addprefix -L, $(LIB_PATHS) )
LIBNAME_FLAGS = $(addprefix -l, $(LIB_NAMES) )

# Additional Flags:
#  ASFLAGS        Flags passed to the S assembler.
#  CFLAGS         Flags passed to the C compiler.
#  CPPFLAGS       Flags passed to the preprocessor.
#  LDFLAGS        Flags passed to the linker via the compiler.
#	 LDLIBS         Libary name flags passed to the linker via the compiler.
#  -g                 Produce debugging information for GDB.
#  -MMD               Generate .d files alongside each .o file. See the RULES section below, in which all .d files are -included.
#  -nostdlib          Do not link any of the standard system libraries or startup files.
#  -T <script>        Specify a linker script
#  -Wl,               Pass comma-separated <options> on to the linker.
#    --gc-sections      Perform a post-compilation garbage collection of unused code and data.
#    --trace            Print all the files participating in the linking process.
ASFLAGS = -g $(ARCHFLAGS) $(THUMB) $(THUMBINTERWORK)
CFLAGS = -g $(ARCHFLAGS) $(THUMB) $(THUMBINTERWORK) $(WARNINGS) $(OPTIMIZE)
CPPFLAGS = $(INCPATH_FLAGS) $(DEFINES) $(SPECS) -MMD
LDFLAGS = -nostdlib -T $(LDSCRIPT) $(LIBPATH_FLAGS) -Wl,--gc-sections -Wl,--trace
LDLIBS = $(LIBNAME_FLAGS)



###############################################################################

.PHONY: all
all: bin sym lst

# Output file types:
#   bin:  Reformatted .elf which can be flashed to the NXT
#   sym:  Symbols and section header info from the .elf
#   lst:  Disassembly info from the .elf
#   elf:  Linker output
.PHONY: bin sym lst elf
bin: $(TARGET).bin
sym: $(TARGET).sym
lst: $(TARGET).lst
elf: $(TARGET).elf

# .bin, .sym, .lst all depend on .elf.
#   OBJCOPY: Reformat .elf to the size expected by the CPU, finally producing a .bin which can be flashed to the NXT.
#   OBJDUMP: Print info about the .elf file:
#    -h       Display contents of the section headers
#    -t       Display contents of the symbol tables
#    -S       Intermix source code with disassembly.
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
#   Set the -mthumb flag during linking.
#   LINK.c: Link the .o files and .a libraries into a .elf binary. Command expands to:
#     $(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $(OBJECTS) $(LOADLIBES) $(LDLIBS) -o $@
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
# $(ARM_OBJECTS):   THUMB = 
$(THUMB_OBJECTS): THUMB = -mthumb

# .o depends on all #includes in its source file.
#   During compilation, .d files are created for each .o file (-MMD flag).
#   Each .d contains an empty make rule for its object, specifying dependencies on everything #included by the source file.
-include $(SRC_DEPENDS)


# Rules for compiling source files into object (.o) files:
$(C_OBJECTS): $(OBJDIR)/%.o: %.c
	@printf "\n\nCompiling source file: %s...\n" "$<"
	$(COMPILE.c) -o $@ $<

$(ASM_OBJECTS): $(OBJDIR)/%.o: %.S
	@printf "\n\nCompiling source file: %s...\n" "$<"
	$(COMPILE.S) -o $@ $<


# c_ui.o depends on BtTest.inc which needs BUILD_DATE.
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



