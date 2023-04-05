/*
 * Autogenerated by the Meson build system.
 * Do not edit, your changes will be lost.
 */

#pragma once

/* Use atomics for fgetc/ungetc for re-entrancy */
#define ATOMIC_UNGETC

/* Always optimize strcmp for performance */
#define FAST_STRCMP

/* Obsoleted. Use regular syscalls */
#undef MISSING_SYSCALL_NAMES

/* use global errno variable */
#undef NEWLIB_GLOBAL_ERRNO

/* use thread local storage */
#undef NEWLIB_TLS

/* use thread local storage */
#undef PICOLIBC_TLS

/* Use open/close/read/write in tinystdio */
#define POSIX_IO

/* Optimize for space over speed */
#define PREFER_SIZE_OVER_SPEED

/* Obsoleted. Reentrant syscalls provided for us */
#undef REENTRANT_SYSCALLS_PROVIDED

/* Use tiny stdio from gcc avr */
#define TINY_STDIO

#undef _ATEXIT_DYNAMIC_ALLOC

#define _ELIX_LEVEL 4

#undef _FSEEK_OPTIMIZATION

#undef _FVWRITE_IN_STREAMIO

#define _HAVE_ALIAS_ATTRIBUTE

/* The compiler REALLY has the attribute __alloc_size__ */
#define _HAVE_ALLOC_SIZE

/* The compiler supports the always_inline function attribute */
#define _HAVE_ATTRIBUTE_ALWAYS_INLINE

/* The compiler supports the gnu_inline function attribute */
#define _HAVE_ATTRIBUTE_GNU_INLINE

/* Use bitfields in packed structs */
#define _HAVE_BITFIELDS_IN_PACKED_STRUCTS

/* Compiler has __builtin_add_overflow */
#define _HAVE_BUILTIN_ADD_OVERFLOW

/* The compiler supports __builtin_alloca */
#define _HAVE_BUILTIN_ALLOCA

/* The compiler supports __builtin_copysign */
#define _HAVE_BUILTIN_COPYSIGN

/* The compiler supports __builtin_copysignl */
#define _HAVE_BUILTIN_COPYSIGNL

/* The compiler supports __builtin_ctz */
#define _HAVE_BUILTIN_CTZ

/* The compiler supports __builtin_ctzl */
#define _HAVE_BUILTIN_CTZL

/* The compiler supports __builtin_ctzll */
#define _HAVE_BUILTIN_CTZLL

/* Compiler has __builtin_expect */
#define _HAVE_BUILTIN_EXPECT

/* The compiler supports __builtin_ffs */
#define _HAVE_BUILTIN_FFS

/* The compiler supports __builtin_ffsl */
#define _HAVE_BUILTIN_FFSL

/* The compiler supports __builtin_ffsll */
#define _HAVE_BUILTIN_FFSLL

/* The compiler supports __builtin_finitel */
#define _HAVE_BUILTIN_FINITEL

/* The compiler supports __builtin_isfinite */
#define _HAVE_BUILTIN_ISFINITE

/* The compiler supports __builtin_isinf */
#define _HAVE_BUILTIN_ISINF

/* The compiler supports __builtin_isinfl */
#define _HAVE_BUILTIN_ISINFL

/* The compiler supports __builtin_isnan */
#define _HAVE_BUILTIN_ISNAN

/* The compiler supports __builtin_isnanl */
#define _HAVE_BUILTIN_ISNANL

/* Compiler has __builtin_mul_overflow */
#define _HAVE_BUILTIN_MUL_OVERFLOW

/* Compiler flag to prevent detecting memcpy/memset patterns */
#define _HAVE_CC_INHIBIT_LOOP_TO_LIBCALL

/* Compiler supports _Complex */
#define _HAVE_COMPLEX

#undef _HAVE_FCNTL

#define _HAVE_FORMAT_ATTRIBUTE

/* IEEE fp funcs available */
#undef _HAVE_IEEEFP_FUNCS

/* compiler supports INIT_ARRAY sections */
#define _HAVE_INITFINI_ARRAY

/* Support _init() and _fini() functions */
#define _HAVE_INIT_FINI

/* Compiler has long double type */
#define _HAVE_LONG_DOUBLE

/* Compiler attribute to prevent the optimizer from adding new builtin calls */
#undef _HAVE_NO_BUILTIN_ATTRIBUTE

/* _set_tls and _init_tls functions available */
#undef _HAVE_PICOLIBC_TLS_API

/* Semihost APIs supported */
#define _HAVE_SEMIHOST

#define _HAVE_WEAK_ATTRIBUTE

#undef _ICONV_ENABLE_EXTERNAL_CCS

#define _ICONV_FROM_ENCODING_

#define _ICONV_FROM_ENCODING_BIG5

#define _ICONV_FROM_ENCODING_CP775

#define _ICONV_FROM_ENCODING_CP850

#define _ICONV_FROM_ENCODING_CP852

#define _ICONV_FROM_ENCODING_CP855

#define _ICONV_FROM_ENCODING_CP866

#define _ICONV_FROM_ENCODING_EUC_JP

#define _ICONV_FROM_ENCODING_EUC_KR

#define _ICONV_FROM_ENCODING_EUC_TW

#define _ICONV_FROM_ENCODING_ISO_8859_1

#define _ICONV_FROM_ENCODING_ISO_8859_10

#define _ICONV_FROM_ENCODING_ISO_8859_11

#define _ICONV_FROM_ENCODING_ISO_8859_13

#define _ICONV_FROM_ENCODING_ISO_8859_14

#define _ICONV_FROM_ENCODING_ISO_8859_15

#define _ICONV_FROM_ENCODING_ISO_8859_2

#define _ICONV_FROM_ENCODING_ISO_8859_3

#define _ICONV_FROM_ENCODING_ISO_8859_4

#define _ICONV_FROM_ENCODING_ISO_8859_5

#define _ICONV_FROM_ENCODING_ISO_8859_6

#define _ICONV_FROM_ENCODING_ISO_8859_7

#define _ICONV_FROM_ENCODING_ISO_8859_8

#define _ICONV_FROM_ENCODING_ISO_8859_9

#define _ICONV_FROM_ENCODING_ISO_IR_111

#define _ICONV_FROM_ENCODING_KOI8_R

#define _ICONV_FROM_ENCODING_KOI8_RU

#define _ICONV_FROM_ENCODING_KOI8_U

#define _ICONV_FROM_ENCODING_KOI8_UNI

#define _ICONV_FROM_ENCODING_UCS_2

#define _ICONV_FROM_ENCODING_UCS_2BE

#define _ICONV_FROM_ENCODING_UCS_2LE

#define _ICONV_FROM_ENCODING_UCS_2_INTERNAL

#define _ICONV_FROM_ENCODING_UCS_4

#define _ICONV_FROM_ENCODING_UCS_4BE

#define _ICONV_FROM_ENCODING_UCS_4LE

#define _ICONV_FROM_ENCODING_UCS_4_INTERNAL

#define _ICONV_FROM_ENCODING_US_ASCII

#define _ICONV_FROM_ENCODING_UTF_16

#define _ICONV_FROM_ENCODING_UTF_16BE

#define _ICONV_FROM_ENCODING_UTF_16LE

#define _ICONV_FROM_ENCODING_UTF_8

#define _ICONV_FROM_ENCODING_WIN_1250

#define _ICONV_FROM_ENCODING_WIN_1251

#define _ICONV_FROM_ENCODING_WIN_1252

#define _ICONV_FROM_ENCODING_WIN_1253

#define _ICONV_FROM_ENCODING_WIN_1254

#define _ICONV_FROM_ENCODING_WIN_1255

#define _ICONV_FROM_ENCODING_WIN_1256

#define _ICONV_FROM_ENCODING_WIN_1257

#define _ICONV_FROM_ENCODING_WIN_1258

#define _ICONV_TO_ENCODING_

#define _ICONV_TO_ENCODING_BIG5

#define _ICONV_TO_ENCODING_CP775

#define _ICONV_TO_ENCODING_CP850

#define _ICONV_TO_ENCODING_CP852

#define _ICONV_TO_ENCODING_CP855

#define _ICONV_TO_ENCODING_CP866

#define _ICONV_TO_ENCODING_EUC_JP

#define _ICONV_TO_ENCODING_EUC_KR

#define _ICONV_TO_ENCODING_EUC_TW

#define _ICONV_TO_ENCODING_ISO_8859_1

#define _ICONV_TO_ENCODING_ISO_8859_10

#define _ICONV_TO_ENCODING_ISO_8859_11

#define _ICONV_TO_ENCODING_ISO_8859_13

#define _ICONV_TO_ENCODING_ISO_8859_14

#define _ICONV_TO_ENCODING_ISO_8859_15

#define _ICONV_TO_ENCODING_ISO_8859_2

#define _ICONV_TO_ENCODING_ISO_8859_3

#define _ICONV_TO_ENCODING_ISO_8859_4

#define _ICONV_TO_ENCODING_ISO_8859_5

#define _ICONV_TO_ENCODING_ISO_8859_6

#define _ICONV_TO_ENCODING_ISO_8859_7

#define _ICONV_TO_ENCODING_ISO_8859_8

#define _ICONV_TO_ENCODING_ISO_8859_9

#define _ICONV_TO_ENCODING_ISO_IR_111

#define _ICONV_TO_ENCODING_KOI8_R

#define _ICONV_TO_ENCODING_KOI8_RU

#define _ICONV_TO_ENCODING_KOI8_U

#define _ICONV_TO_ENCODING_KOI8_UNI

#define _ICONV_TO_ENCODING_UCS_2

#define _ICONV_TO_ENCODING_UCS_2BE

#define _ICONV_TO_ENCODING_UCS_2LE

#define _ICONV_TO_ENCODING_UCS_2_INTERNAL

#define _ICONV_TO_ENCODING_UCS_4

#define _ICONV_TO_ENCODING_UCS_4BE

#define _ICONV_TO_ENCODING_UCS_4LE

#define _ICONV_TO_ENCODING_UCS_4_INTERNAL

#define _ICONV_TO_ENCODING_US_ASCII

#define _ICONV_TO_ENCODING_UTF_16

#define _ICONV_TO_ENCODING_UTF_16BE

#define _ICONV_TO_ENCODING_UTF_16LE

#define _ICONV_TO_ENCODING_UTF_8

#define _ICONV_TO_ENCODING_WIN_1250

#define _ICONV_TO_ENCODING_WIN_1251

#define _ICONV_TO_ENCODING_WIN_1252

#define _ICONV_TO_ENCODING_WIN_1253

#define _ICONV_TO_ENCODING_WIN_1254

#define _ICONV_TO_ENCODING_WIN_1255

#define _ICONV_TO_ENCODING_WIN_1256

#define _ICONV_TO_ENCODING_WIN_1257

#define _ICONV_TO_ENCODING_WIN_1258

/* math library does not set errno (offering only ieee semantics) */
#define _IEEE_LIBM

#define _IO_FLOAT_EXACT

#define _LITE_EXIT

#undef _MB_CAPABLE

#define _MB_LEN_MAX 1

#undef _NANO_FORMATTED_IO

#define _NANO_MALLOC

/* The newlib version in string format. */
#define _NEWLIB_VERSION "4.1.0"

/* The Picolibc minor version number. */
#define _PICOLIBC_MINOR__ 8

/* The Picolibc version in string format. */
#define _PICOLIBC_VERSION "1.8"

/* The Picolibc major version number. */
#define _PICOLIBC__ 1

#define _PICO_EXIT

#undef _REENT_GLOBAL_ATEXIT

#define _RETARGETABLE_LOCKING

#undef _UNBUF_STREAM_OPT

#define _WANT_IO_C99_FORMATS

#undef _WANT_IO_LONG_DOUBLE

#undef _WANT_IO_LONG_LONG

#undef _WANT_IO_PERCENT_B

#undef _WANT_IO_POS_ARGS

/* math library sets errno */
#undef _WANT_MATH_ERRNO

#undef _WANT_REENT_SMALL

#undef _WANT_REGISTER_FINI

/* Obsoleted. Define time_t to long instead of using a 64-bit type */
#undef _WANT_USE_LONG_TIME_T

#undef _WIDE_ORIENT

/* extended locale support */
#undef __HAVE_LOCALE_INFO_EXTENDED__

/* locale support */
#undef __HAVE_LOCALE_INFO__

/* The newlib minor version number. */
#define __NEWLIB_MINOR__ 1

/* The newlib patch level. */
#define __NEWLIB_PATCHLEVEL__ 0

/* The newlib major version number. */
#define __NEWLIB__ 4

/* Use old math code (undef auto, 0 no, 1 yes) */
#undef __OBSOLETE_MATH

/* Use old math code for double funcs (undef auto, 0 no, 1 yes) */
#undef __OBSOLETE_MATH_DOUBLE

/* Use old math code for float funcs (undef auto, 0 no, 1 yes) */
#undef __OBSOLETE_MATH_FLOAT

/* Compute static memory area sizes at runtime instead of link time */
#undef __PICOLIBC_CRT_RUNTIME_SIZE

/* The Picolibc minor version number. */
#define __PICOLIBC_MINOR__ 8

/* The Picolibc patch level. */
#define __PICOLIBC_PATCHLEVEL__ 0

/* The Picolibc version in string format. */
#define __PICOLIBC_VERSION__ "1.8"

/* The Picolibc major version number. */
#define __PICOLIBC__ 1

#undef __SINGLE_THREAD__

