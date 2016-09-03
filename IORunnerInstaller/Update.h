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


#define PROCESS_VERSION_COMMAND(PP) ({															\
	IOString *processVersionCommand = INIT_STRING(PP);											\
	processVersionCommand->append(processVersionCommand, "/bin/");								\
	processVersionCommand->append(processVersionCommand, APP_PACKAGE_NAME);						\
	processVersionCommand->append(processVersionCommand, " --verint");							\
	(processVersionCommand);																	\
})

#define UPDATE_OR_UNINSTALL(appPath, currentAppVersion) ({										\
	IOString *processVersionCommand = PROCESS_VERSION_COMMAND(appPath);							\
	IOString *versionNumberBash = IOProcess_readProcess(processVersionCommand->value);			\
	processVersionCommand->release(processVersionCommand);										\
	IOStringBucket *versionNumberBucket = versionNumberBash->split(versionNumberBash, "\n");	\
	unsigned char retVal = 0;																	\
	if(versionNumberBucket->count > 0) {														\
		IOString *versionNumberStr = versionNumberBucket->get(versionNumberBucket, 0);			\
		*currentAppVersion = strtol(versionNumberStr->value, (char **)NULL, 10);				\
		if(APP_VERSION_INT > *currentAppVersion) {												\
			retVal = 1;																			\
		}																						\
	}																							\
	versionNumberBucket->release(versionNumberBucket);											\
	versionNumberBash->release(versionNumberBash);												\
	(retVal);																					\
})

#define RULE_NO_CHANGE 0
#define RULE_OVERRIDE 1
#define RULE_DELETE 2
#define RULE_COPY 3
#define RULE_APPEND_CONFIG 4
#define RULE_CREATE_DIRECTORY 5

typedef struct _IOUpdaterRules IOUpdaterRules;
typedef struct _IOVersion IOVersion;
typedef struct _IOUpdate IOUpdate;

struct _IOUpdaterRules {

	unsigned short ruleTypes;
	const char *chmod;
	unsigned short isDirectory;
	const char *newFilePath;
	size_t newFilePathLen;
	const char *fromFilePath;
	size_t fromFilePathLen;
};

struct _IOVersion {
	
	long targetVersion;
	size_t ruleCount;
	IOUpdaterRules **rules;
};

struct _IOUpdate {
	
	size_t versionCount;
	IOVersion **versions;
};

#define INIT_UPDATE(versionCount)										\
	updateData = malloc(sizeof(IOUpdate));								\
	updateData->versionCount = versionCount;							\
	updateData->versions = malloc((versionCount * sizeof(void *)) + 1);

#define GET_UPDATE_VERSION_COUNT (updateData->versionCount)

#define GET_UPDATE_VERSIONS (updateData->versions)

#define PREPARE_VERSION(versionInt)										\
	prepareVersion_ ## versionInt ()

#define INIT_UPDATE_RULES(_ruleCount, versionInt)											\
	IOUpdaterRules **rules_ ## versionInt ## _PP = malloc((_ruleCount * sizeof(void *)) + 1);

#define ADD_RULE(versionInt, idx, _ruleType, _chmod, _isDirectory, _newFilePath, _fromFilePath)	\
	IOUpdaterRules *ruleData_ ## versionInt ## _ ## idx = malloc(sizeof(IOUpdaterRules));	\
	ruleData_ ## versionInt ## _ ## idx ->ruleTypes = _ruleType;							\
	ruleData_ ## versionInt ## _ ## idx ->chmod = _chmod;									\
	ruleData_ ## versionInt ## _ ## idx ->isDirectory = _isDirectory;						\
	ruleData_ ## versionInt ## _ ## idx ->newFilePath = _newFilePath;						\
	ruleData_ ## versionInt ## _ ## idx ->newFilePathLen = strlen(_newFilePath);			\
	ruleData_ ## versionInt ## _ ## idx ->fromFilePath = _fromFilePath;						\
	ruleData_ ## versionInt ## _ ## idx ->fromFilePathLen = strlen(_fromFilePath);			\
	rules_ ## versionInt ## _PP [idx] = ruleData_ ## versionInt ## _ ## idx;

#define INIT_VERSION(_ruleCount, versionInt, versionIdx)									\
	IOVersion *version_ ## versionInt ## _ ## versionIdx = malloc(sizeof(IOVersion));		\
	version_ ## versionInt ## _ ## versionIdx ->targetVersion = versionInt;					\
	version_ ## versionInt ## _ ## versionIdx ->ruleCount = _ruleCount;						\
	version_ ## versionInt ## _ ## versionIdx ->rules = rules_ ## versionInt ## _PP;		\
	updateData->versions[versionIdx] = version_ ## versionInt ## _ ## versionIdx;

#endif /* Update_h */
