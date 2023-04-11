#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"   # Directory containing this script
declare -a MESON_OPTS=()

###############################################################################

# Paths
ROOT_DIR="$SCRIPT_DIR/../.."
INSTALL_DIR="$SCRIPT_DIR/.."
BUILD_DIR="$ROOT_DIR/build/picolibc"
PICOLIB_REPO="$ROOT_DIR/3rdparty/picolibc"

# Target system
ARCH=arm-none-eabi
CPU=arm7tdmi
ENDIANNESS=little
CPU_FAMILY=arm
SYSTEM_TYPE=none

# Build tools
C_COMPILER="${ARCH}-gcc"

# Crossfile generator options
CROSS_FILE="$SCRIPT_DIR/picolibc-${CPU}.txt"
COMPILE_FLAGS="-g -mcpu=$CPU -mthumb -mthumb-interwork -Os -ffunction-sections -fdata-sections"
LINK_FLAGS=""


# GENERAL BUILD OPTIONS
# These options control some general build configuration values.
# 
#   MESON_OPTS+=("fast-strcmp=true")                # Always optimize strcmp for performance (to make Dhrystone happy)
#   MESON_OPTS+=("have-alias-attribute=auto")       # Compiler supports alias attribute (default autodetected)
#   MESON_OPTS+=("have-format-attribute=auto")      # Compiler supports format attribute (default autodetected)
#   MESON_OPTS+=("multilib=true")                   # Build every multilib configuration supported by the compiler
#   MESON_OPTS+=("multilib-list=")                  # If non-empty, the set of multilib configurations to compile for
#   MESON_OPTS+=("native-tests=false")              # Build tests against native libc (used to validate tests)
#   MESON_OPTS+=("picolib=true")                    # Include picolib bits for tls and sbrk support
#   MESON_OPTS+=("picocrt=true")                    # Build crt0.o (C startup function)
#   MESON_OPTS+=("picocrt-lib=true")                # Also wrap crt0.o into a library -lcrt0, which is easier to find via the library path
#   MESON_OPTS+=("semihost=true")                   # Build the semihost library (libsemihost.a)
#   MESON_OPTS+=("fake-semihost=false")             # Create a fake semihost library to allow tests to link
#   MESON_OPTS+=("specsdir=auto")                   # Where to install the .specs file (default is in the GCC directory).
#                                                   #   If set to none, then picolibc.specs will not be installed at all.
#   MESON_OPTS+=("sysroot-install=false")           # Install in GCC sysroot location (requires sysroot in GCC)
#   MESON_OPTS+=("tests=false")                     # Enable tests
#   MESON_OPTS+=("tinystdio=true")                  # Use tiny stdio from avr libc
MESON_OPTS+=("multilib-list=thumb/nofp")
MESON_OPTS+=("picocrt=false")
MESON_OPTS+=("semihost=false")
MESON_OPTS+=("fake-semihost=false")
#MESON_OPTS+=("specsdir=$INSTALL_DIR/picolibc")
MESON_OPTS+=("specsdir=none")
MESON_OPTS+=("sysroot-install=false")
MESON_OPTS+=("tests=false")


# These options extend support in printf and scanf for additional types and formats.
# long long support is always enabled for the tinystdio full printf/scanf modes, the io-long-long option adds them to the limited (float and integer) versions, as well as to the original newlib stdio bits.
# 
#   MESON_OPTS+=("io-c99-formats=true")             # Enable C99 support in IO functions like printf/scanf
#   MESON_OPTS+=("io-long-long=false")              # Enable long long type support in IO functions like printf/scanf. For tiny-stdio, this only affects the integer-only versions, the full version always includes long long support.
#   MESON_OPTS+=("io-pos-args=false")               # Enable printf-family positional arg support. For tiny-stdio, this only affects the integer-only versions, the full version always includes positional argument support.
MESON_OPTS+=("io-c99-formats=false")


# These options apply when tinystdio is enabled, which is the default. For stdin/stdout/stderr, the application will need to provide stdin, stdout and stderr, which are three pointers to FILE structures (which can all reference a single shared FILE structure, and which can be aliases to the same underlying global pointer).
# Note that while posix-io support is enabled by default, using it will require that the underlying system offer the required functions. POSIX console support offers built-in stdin, stdout and stderr definitions which use the same POSIX I/O functions.
# 
#   MESON_OPTS+=("atomic-ungetc=true")              # Make getc/ungetc re-entrant using atomic operations
#   MESON_OPTS+=("io-float-exact=true")             # Provide round-trip support in float/string conversions
#   MESON_OPTS+=("posix-io=true")                   # Provide fopen/fdopen using POSIX I/O (requires open, close, read, write, lseek)
#   MESON_OPTS+=("posix-console=false")             # Use POSIX I/O for stdin/stdout/stderr
#   MESON_OPTS+=("format-default=double")           # Sets the default printf/scanf style ('double', 'float' or 'integer')
#   MESON_OPTS+=("newlib-iconv-encodings=")         # Comma-separated list of iconv encodings to be built-in (default all supported).
#                                                   #   Set to none to disable all encodings.
MESON_OPTS+=("format-default=float")


# INTERNATIONALIZATION OPTIONS
# These options control which character sets are supported by iconv.
# 
#   MESON_OPTS+=("newlib-iconv-from-encodings=")    # Comma-separated list of "from" iconv encodings to be built-in (default iconv-encodings)
#   MESON_OPTS+=("newlib-iconv-to-encodings=")      # Comma-separated list of "to" iconv encodings to be built-in (default iconv-encodings)
#   MESON_OPTS+=("newlib-iconv-external-ccs=false") # Use file system to store iconv tables. Requires fopen. (default built-in to memory)
#   MESON_OPTS+=("newlib-iconv-dir=libdir/locale")  # Directory to install external CCS files. Only used with newlib-iconv-external-ccs=true
#   MESON_OPTS+=("newlib-iconv-runtime-dir=newlib-iconv-dir")   # Directory to read external CCS files from at runtim


# These options control how much Locale support is included in the library.
# By default, picolibc only supports the 'C' locale.
# 
#   MESON_OPTS+=("newlib-locale-info=false")        # Enable locale support
#   MESON_OPTS+=("newlib-locale-info-extended=false")   # Enable even more locale support
#   MESON_OPTS+=("newlib-mb=false")                 # Enable multibyte support


# STARTUP/SHUTDOWN OPTIONS
# These control how much support picolibc includes for calling functions at startup and shutdown times.
# 
#   MESON_OPTS+=("lite-exit=true")                  # Enable lightweight exit
#   MESON_OPTS+=("newlib-atexit-dynamic-alloc=false")   # Enable dynamic allocation of atexit entries
#   MESON_OPTS+=("newlib-global-atexit=false")      # Enable atexit data structure as global, instead of in TLS.
#                                                   #   If thread-local-storage == false, then the atexit data structure is always global.
#   MESON_OPTS+=("newlib-initfini=true")            # Support _init() and _fini() functions in picocrt
#   MESON_OPTS+=("newlib-initfini-array=true")      # Use .init_array and .fini_array sections in picocrt
#   MESON_OPTS+=("newlib-register-fini=false")      # Enable finalization function registration using atexit
#   MESON_OPTS+=("crt-runtime-size=false")          # Compute .data/.bss sizes at runtime rather than linktime.
#                                                   #   This option exists for targets where the linker can't handle a symbol that is the difference between two other symbols, e.g. m68k.


# THREAD LOCAL STORAGE SUPPORT
# By default, Picolibc can uses native TLS support as provided by the compiler, this allows re-entrancy into the library if the run-time environment supports that. A TLS model is specified only when TLS is enabled. The default TLS model is local-exec.
# As a separate option, you can make errno not use TLS if necessary.
# 
#   MESON_OPTS+=("thread-local-storage=auto")       # Use TLS for global variables. Default is automatic based on compiler support
#   MESON_OPTS+=("tls-model=local-exec")            # Select TLS model (global-dynamic, local-dynamic, initial-exec or local-exec)
#   MESON_OPTS+=("newlib-global-errno=false")       # Use single global errno even when thread-local-storage=true
#   MESON_OPTS+=("errno-function=")                 # If set, names a function which returns the address of errno. 'auto' will try to auto-detect.
MESON_OPTS+=("newlib-global-errno=true")


# MALLOC OPTION
# Picolibc offers two malloc implementations, the larger version offers better performance on large memory systems and for applications doing a lot of variable-sized allocations and deallocations.
# The smaller, default, implementation works best when applications perform few, persistent allocations.
#   MESON_OPTS+=("newlib-nano-malloc=true")         # Use small-footprint nano-malloc implementation
MESON_OPTS+=("newlib-nano-malloc=true")


# LOCKING SUPPORT
# There are some functions in picolibc that use global data that needs protecting when accessed by multiple threads.
# The largest set of these are the legacy stdio code, but there are other functions that can use locking, e.g. when newlib-global-atexit is enabled, calls to atexit need to lock the shared global data structure if they may be called from multiple threads at the same time.
# By default, these are enabled and use the retargetable API defined in locking.md.
# 
#   MESON_OPTS+=("newlib-retargetable-locking=true")# Allow locking routines to be retargeted at link time
#   MESON_OPTS+=("newlib-multithread=true")         # Enable support for multiple threads


# MATH LIBRARY OPTIONS
# There are two versions of many libm functions, old ones from SunPro and new ones from ARM.
# The new ones are generally faster for targets with hardware double support, except that the new float-valued functions use double-precision computations.
# On sytems without hardware double support, that's going to pull in soft double code.
# Measurements show the old routines are generally more accurate, which is why they are enabled by default.
# POSIX requires many of the math functions to set errno when exceptions occur; disabling that makes them only support fenv() exception reporting, which is what IEEE floating point and ANSI C standards require.
# 
#   MESON_OPTS+=("newlib-obsolete-math=true")       # Use old code for both float and double valued functions
#   MESON_OPTS+=("newlib-obsolete-math-float=auto") # Use old code for float-valued functions
#   MESON_OPTS+=("newlib-obsolete-math-double=auto")# Use old code for double-valued functions
#   MESON_OPTS+=("want-math-errno=false")           # Set errno when exceptions occur
MESON_OPTS+=("want-math-errno=false")


###############################################################################

COMPILE_FLAGS_STR="" 
for flag in $COMPILE_FLAGS; do
    printf -v COMPILE_FLAGS_STR "%s --cflag=%s" "$COMPILE_FLAGS_STR" "$flag"
done
# printf "COMPILE_FLAGS_STR=%s\n" "$COMPILE_FLAGS_STR"

LINK_FLAGS_STR=""
for flag in $LINK_FLAGS; do
    printf -v LINK_FLAGS_STR "%s --lflag=%s" "$LINK_FLAGS_STR" "$flag"
done
# printf "LINK_FLAGS_STR=%s\n" "$LINK_FLAGS_STR"

MESON_OPTS_STR=""
for opt in "${MESON_OPTS[@]}"; do
    printf -v MESON_OPTS_STR "%s -D%s" "$MESON_OPTS_STR" "$opt"
done
# printf "MESON_OPTS_STR=%s\n" "$MESON_OPTS_STR"


echo ""
echo "Clearing build directory \"$BUILD_DIR\"..."
rm -rf "$BUILD_DIR" 2>/dev/null || echo ""
mkdir -p "$BUILD_DIR"


echo ""
echo "Generating cross-file \"$CROSS_FILE\"..."
cd "$BUILD_DIR"
/usr/bin/env bash "$PICOLIB_REPO/scripts/GeneratePicolibcCrossFile.sh" \
        --target-arch=$ARCH         \
        --system=$SYSTEM_TYPE       \
        --cpu-family=$CPU_FAMILY    \
        --cpu=$CPU                  \
        --endianness=$ENDIANNESS    \
        --c-compiler=$C_COMPILER    \
        $COMPILE_FLAGS_STR          \
        $LINK_FLAGS_STR             \
        >"$CROSS_FILE"
        


echo ""
echo "Configuring Meson project..."
cd "$BUILD_DIR"
#"$PICOLIB_REPO/scripts/do-arm-configure" $MESON_OPTS_STR
meson setup \
        -Dincludedir="$(basename $SCRIPT_DIR)"/$ARCH/include \
        -Dlibdir="$(basename $SCRIPT_DIR)"/$ARCH/lib \
        --cross-file "$CROSS_FILE" \
        "-Dprefix=$INSTALL_DIR" \
        $MESON_OPTS_STR \
        "$PICOLIB_REPO"


echo ""
echo "Building picolibc..."
cd "$BUILD_DIR"
ninja


echo ""
echo "Installing picolibc to \"$INSTALL_DIR\"..."
cd "$BUILD_DIR"
ninja install
