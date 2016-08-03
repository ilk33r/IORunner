//
//  IOProcessHelper.c
//  IORunner
//
//  Created by ilker özcan on 01/08/16.
//
//

#include "IOProcessHelper.h"

IOString *IOProcess_readProcess(const char *command) {
	
	FILE *proccess;
	proccess = popen(command, "r");
	const size_t readBuffer = 4096;
	
	size_t bufferSize = readBuffer;
	size_t currentBuffer = 0;
	char *bufferString = malloc(bufferSize + 1);
	memset(&bufferString[0], 0, bufferSize + 1);
	char *responseString = malloc(bufferSize + 1);
	memset(&responseString[0], 0, bufferSize + 1);
	
	if (proccess != NULL) {
		
		while (1) {
			char *line;
			line = fgets(bufferString, readBuffer, proccess);
			
			if (line == NULL) {
				break;
			}else{
				
				size_t lineSize = strlen(line);
				memcpy(&responseString[currentBuffer], line, lineSize);
				currentBuffer += lineSize;
				
				if(currentBuffer > (bufferSize - 256)) {
					bufferSize += readBuffer;
					responseString = realloc(responseString, bufferSize + 1);
					
					if(responseString != NULL) {
						memset(&responseString[currentBuffer], 0, readBuffer + 1);
					}
				}
			}
		}
		
		pclose(proccess);
	}else{
		free(bufferString);
		free(responseString);
		return NULL;
	}
	
	memset(&responseString[currentBuffer], 0, sizeof(char));
	free(bufferString);
	IOString *retval = INIT_STRING(responseString);
	free(responseString);
	return retval;
}
