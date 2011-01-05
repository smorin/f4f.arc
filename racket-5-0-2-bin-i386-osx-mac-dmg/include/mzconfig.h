/* racket/mzconfig.h.  Generated from mzconfig.h.in by configure.  */

/* This file contains information that was gathered by the configure script. */

#ifndef __MZSCHEME_CONFIGURATION_INFO__
#define __MZSCHEME_CONFIGURATION_INFO__

/* The size of a `char', as computed by sizeof. */
#define SIZEOF_CHAR 1

/* The size of a `int', as computed by sizeof. */
#define SIZEOF_INT 4

/* The size of a `short', as computed by sizeof. */
#define SIZEOF_SHORT 2

/* The size of a `long', as computed by sizeof. */
#define SIZEOF_LONG 4

/* The size of a `long long', as computed by sizeof. */
#define SIZEOF_LONG_LONG 8

/* Endianness. */
/* #undef SCHEME_BIG_ENDIAN */

/* Direction of stack growth: 1 = up, -1 = down, 0 = unknown. */
#define STACK_DIRECTION -1

/* Whether nl_langinfo works. */
#define HAVE_CODESET 1

/* Whether getaddrinfo works. */
/* #undef HAVE_GETADDRINFO */

/* Whether __attribute__ ((noinline)) works */
#define MZ_USE_NOINLINE 1

/* Whether pthread_rwlock is availabale: */
#define HAVE_PTHREAD_RWLOCK 1

/* Enable futures and/or places (but not with sgc): */
#if !defined(USE_SENORA_GC) || defined(NEWGC_BTC_ACCOUNT)
#define MZ_USE_FUTURES 1
/* #undef MZ_USE_PLACES */
#endif

/* Configure use of pthreads for the user-thread timer: */
#define USE_PTHREAD_INSTEAD_OF_ITIMER 1

/* Enable GC2 Places Testing: */
/* #undef GC2_PLACES_TESTING */

#endif
