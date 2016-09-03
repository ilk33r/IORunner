//
//  IORunnerUpdater.h
//  IORunner
//
//  Created by ilker özcan on 02/09/16.
//
//

#ifndef IORunnerUpdater_h
#define IORunnerUpdater_h

#include "Update.h"

#ifndef CONFIG_DATA_101
#	define CONFIG_DATA_101 "\n\n"\
"; BashScriptHandler extension config file\n"\
"[BashScriptHandler]\n"\
"\n"\
"; How many bash script will checked?\n"\
"BashScriptCount = 2\n"\
"\n"\
"; Colon seperated commands\n"\
"ProcessStatuses = \"/home/script1 status:/home/script2 status\"\n"\
"\n"\
"; Colon seperated commands\n"\
"ProcessStopCommands = \"/home/script1 stop:/home/script2 stop\"\n"\
"\n"\
"; Colon seperated commands\n"\
"ProcessStartCommands = \"/home/script1 start:/home/script2 start\"\n"\
"\n"\
"; Process checking interval (seconds)\n"\
"ProcessFrequency = 30\n"\
"\n"\
"ProcessTimeout = 60\n"\
"\n"

#endif

#define GET_CONFIG_DATA(versionInt) (CONFIG_DATA_ ## versionInt)

extern IOUpdate *updateData;
void prepareUpdateData();
void releaseUpdateData();

#endif /* IORunnerUpdater_h */
