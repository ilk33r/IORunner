//
//  IOStringHelper.h
//  IORunner
//
//  Created by ilker özcan on 29/07/16.
//
//

#ifndef IOStringHelper_h
#define IOStringHelper_h

#include "Defines.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>

typedef struct _IOString IOString;
typedef struct _IOStringBucket IOStringBucket;

struct _IOString {
	
	size_t length;
	char *value;
	
	void (*release)(IOString *);
	void (*append)(IOString *, const char *);
	void (*appendByPathComponent)(IOString *, const char *);
	IOString *(*subString)(IOString *, size_t, size_t);
	IOStringBucket *(*split)(IOString *, const char *);
	unsigned char (*isEqualToString)(IOString *, const char *);
};

extern void IOString_release(IOString *self_pp);
extern void IOString_append(IOString *self_pp, const char *appendString);
extern void IOString_appendByPathComponent(IOString *self_pp, const char *appendString);
extern IOString *IOString_subString(IOString *self_pp, size_t start, size_t length);
extern IOStringBucket *IOString_split(IOString *self_pp, const char *splitCharacter);
extern unsigned char IOString_isEqualToString(IOString *self_pp, const char *equality);

#define INIT_STRING(constCharP) ({												\
	IOString *retVal = malloc(sizeof(IOString));								\
	size_t charSize = strlen(constCharP);										\
	size_t strMemSize = charSize + 1;											\
																				\
	retVal->value = malloc(strMemSize);											\
	memset(retVal->value, 0, strMemSize);										\
	memcpy(retVal->value, constCharP, strlen(constCharP));						\
	retVal->length = charSize;													\
	retVal->release = &IOString_release;										\
	retVal->append = &IOString_append;											\
	retVal->appendByPathComponent = &IOString_appendByPathComponent;			\
	retVal->subString = &IOString_subString;									\
	retVal->split = &IOString_split;											\
	retVal->isEqualToString = &IOString_isEqualToString;						\
	(retVal);																	\
})

struct _IOStringBucket {
	
	size_t count;
	IOString **stringArray;
	
	void (*release)(IOStringBucket *);
	void (*push)(IOStringBucket *, IOString *);
	void (*removeAt)(IOStringBucket *, size_t);
	IOString *(*get)(IOStringBucket *, size_t);
};

extern void IOStringBucket_release(IOStringBucket *self_pp);
extern void IOStringBucket_push(IOStringBucket *self_pp, IOString *appendString);
extern void IOStringBucket_removeAt(IOStringBucket *self_pp, size_t index);
extern IOString *IOStringBucket_get(IOStringBucket *self_pp, size_t index);

#define INIT_STRING_ARRAY() ({												\
	IOStringBucket *retVal = malloc(sizeof(IOStringBucket));				\
																			\
	retVal->count = 0;														\
	retVal->stringArray = malloc(0);										\
	retVal->release = &IOStringBucket_release;								\
	retVal->push = &IOStringBucket_push;									\
	retVal->removeAt = &IOStringBucket_removeAt;							\
	retVal->get = &IOStringBucket_get;										\
	(retVal);																\
})

#define STRING_ARRAY_PUSH_CHAR(ioStringArr, pushChar) ({					\
	IOString *pushString = INIT_STRING(pushChar);							\
	ioStringArr->push(ioStringArr, pushString);								\
})

#endif /* IOStringHelper_h */
