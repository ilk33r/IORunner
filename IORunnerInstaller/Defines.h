//
//  Defines.h
//  IORunner
//
//  Created by ilker özcan on 29/07/16.
//
//

#ifndef Defines_h
#define Defines_h

#ifndef _XOPEN_SOURCE
#	define _XOPEN_SOURCE
#endif

#ifndef _XOPEN_SOURCE_EXTENDED
#	define _XOPEN_SOURCE_EXTENDED
#endif

#ifndef IO_UNUSED
#	define IO_UNUSED //(void)
#endif

#ifndef TRUE
#	define TRUE 1
#endif

#ifndef FALSE
#	define FALSE 0
#endif

typedef unsigned char Bool;

#ifdef BUILD_OS_Linux
#	define IS_LINUX TRUE
#	define IS_DARWIN FALSE
#endif

#ifdef BUILD_OS_Darwin
#	define IS_LINUX FALSE
#	define IS_DARWIN TRUE
#endif

#ifndef IS_LINUX
#	define IS_LINUX FALSE
#endif

#ifndef IS_DARWIN
#	define IS_DARWIN FALSE
#endif

#endif /* Defines_h */
