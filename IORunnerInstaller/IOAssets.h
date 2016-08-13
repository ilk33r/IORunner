//
//  IOAssets.h
//  IORunner
//
//  Created by ilker özcan on 13/08/16.
//
//

#ifndef IOAssets_h
#define IOAssets_h

#include "Defines.h"
#include <stdint.h>

#	ifdef __APPLE__

#		define EXTLD(NAME)							\
			extern const uint8_t NAME ## _Data[];	\
			extern const int NAME ## _Size;			\

#		define LDVAR(NAME) NAME ## _Data

#		define LDLEN(NAME) NAME ## _Size

#	elif (defined __WIN32__)  /* mingw */

#		define EXTLD(NAME)								\
			extern const uint8_t _ ## NAME ## _Data[];	\
			extern const int _ ## NAME ## _Size;		\

#		define LDVAR(NAME) _ ## NAME ## _Data

#		define LDLEN(NAME) _ ## NAME ## _Size

#	else /* gnu/linux ld */

#		define EXTLD(NAME)								\
			extern const uint8_t _ ## NAME ## _Data [];	\
			extern const int _ ## NAME ## _Size;		\

#		define LDVAR(NAME) _ ## NAME ## _Data

#		define LDLEN(NAME) _ ## NAME ## _Size

#	endif

#endif /* IOAssets_h */
