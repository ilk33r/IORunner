//
//  Update.h
//  IORunner
//
//  Created by ilker özcan on 23/08/16.
//
//

#ifndef Update_h
#define Update_h

#include "Defines.h"
#include <string.h>
#include "Constants.h"
#include "IOStringHelper.h"
#include "IOProcessHelper.h"

long currentAppVersion = 0;


#define PROCESS_VERSION_COMMAND(PP) ({															\
	IOString *processVersionCommand = INIT_STRING(PP);											\
	processVersionCommand->append(processVersionCommand, "/bin/");								\
	processVersionCommand->append(processVersionCommand, APP_PACKAGE_NAME);						\
	processVersionCommand->append(processVersionCommand, " --verint");							\
	(processVersionCommand);																	\
})

#define UPDATE_OR_UNINSTALL(appPath) ({															\
	IOString *processVersionCommand = PROCESS_VERSION_COMMAND(appPath);							\
	IOString *versionNumberBash = IOProcess_readProcess(processVersionCommand->value);			\
	processVersionCommand->release(processVersionCommand);										\
	IOStringBucket *versionNumberBucket = versionNumberBash->split(versionNumberBash, "\n");	\
	unsigned char retVal = 0;																	\
	if(versionNumberBucket->count > 0) {														\
		IOString *versionNumberStr = versionNumberBucket->get(versionNumberBucket, 0);			\
		currentAppVersion = strtol(versionNumberStr->value, (char **)NULL, 10);					\
		if(APP_VERSION_INT > currentAppVersion) {												\
			retVal = 1;																			\
		}																						\
	}																							\
	versionNumberBucket->release(versionNumberBucket);											\
	versionNumberBash->release(versionNumberBash);												\
	(retVal);																					\
})

#endif /* Update_h */
