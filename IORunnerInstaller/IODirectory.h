//
//  IODirectory.h
//  IORunner
//
//  Created by ilker özcan on 29/07/16.
//
//

#ifndef IODirectory_h
#define IODirectory_h

#include "Defines.h"

#include <stdio.h>
#include <dirent.h>
#include <stdlib.h>
#include <sys/dir.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>

#if defined(__APPLE__) || defined(__FreeBSD__)
#	include <copyfile.h>
#else
#	include <sys/sendfile.h>
#endif

#include "IOStringHelper.h"

typedef struct _IODirectory IODirectory;

struct _IODirectory {

	IOString *path;
	IOStringBucket *contents;
	size_t fileCount;
	unsigned short *types;
	
	void (*release)(IODirectory *);
	void (*generateContentlist)(IODirectory *);
};

extern void IODirectory_release(IODirectory *self_pp);
extern void IODirectory_generateContentlist(IODirectory *self_pp);

#define INIT_DIRECTORY(pathString) ({									\
	IODirectory *retVal = malloc(sizeof(IODirectory));					\
																		\
	retVal->fileCount = 0;												\
	retVal->path = pathString;											\
	retVal->types = malloc(0);											\
	retVal->contents = NULL;											\
	retVal->release = &IODirectory_release;								\
	retVal->generateContentlist = &IODirectory_generateContentlist;		\
	(retVal);															\
})

#define INIT_DIRECTORY_WITH_CHAR(pathChar) ({							\
	IOString *pathString = INIT_STRING(pathChar);						\
	IODirectory *retVal = INIT_DIRECTORY(pathString);					\
	(retVal);															\
})

#define GET_FILE_TYPE(ioDirectory, dirIndex) ({							\
	unsigned short retVal = 0;											\
	if(dirIndex < ioDirectory->fileCount) {								\
		retVal = ioDirectory->types[dirIndex];							\
	}																	\
	(retVal);															\
})

#define IS_DIR(ioDirectory, dirIndex) ({								\
	unsigned char retVal = 0;											\
	if(dirIndex < ioDirectory->fileCount) {								\
		unsigned short fileType = GET_FILE_TYPE(ioDirectory, dirIndex);	\
		if(fileType == DT_DIR) {										\
			retVal = 1;													\
		}																\
	}																	\
	(retVal);															\
})

#define IS_FILE(ioDirectory, dirIndex) ({								\
	unsigned char retVal = 0;											\
	if(dirIndex < ioDirectory->fileCount) {								\
		unsigned short fileType = GET_FILE_TYPE(ioDirectory, dirIndex);	\
		if(fileType == DT_REG) {										\
			retVal = 1;													\
		}																\
	}																	\
	(retVal);															\
})

#define IS_LINK(ioDirectory, dirIndex) ({								\
	unsigned char retVal = 0;											\
	if(dirIndex < ioDirectory->fileCount) {								\
		unsigned short fileType = GET_FILE_TYPE(ioDirectory, dirIndex);	\
		if(fileType == DT_LNK) {										\
			retVal = 1;													\
		}																\
	}																	\
	(retVal);															\
})

int copyFile(IOString *source, IOString *destination);
unsigned char copyDirectory_ex(IODirectory *sourceDirectory, IOString *destinationPath, unsigned char deleteAfterCopy);

#define COPY_DIR(ioDirectory, destinationPathString) ({					\
	unsigned char retVal = copyDirectory_ex(ioDirectory, destinationPathString, 0); \
	(retVal);															\
})

#define MOVE_DIR(ioDirectory, destinationPathString) ({					\
	unsigned char retVal = copyDirectory_ex(ioDirectory, destinationPathString, 1); \
	(retVal);															\
})

#endif /* IODirectory_h */
