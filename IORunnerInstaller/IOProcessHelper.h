//
//  IOProcessHelper.h
//  IORunner
//
//  Created by ilker özcan on 01/08/16.
//
//

#ifndef IOProcessHelper_h
#define IOProcessHelper_h

#include "Defines.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "IOStringHelper.h"

IOString *IOProcess_readProcess(const char *command);

#endif /* IOProcessHelper_h */
