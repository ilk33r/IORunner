//
//  IOStringHelper.c
//  IORunner
//
//  Created by ilker özcan on 29/07/16.
//
//

#include "IOStringHelper.h"

void IOString_release(IOString *self_pp) {
	
	if(self_pp->length > 0) {
		free(self_pp->value);
	}
	
	free(self_pp);
}

void IOString_append(IOString *self_pp, const char *appendString) {
	
	size_t appendStringLen = strlen(appendString);
	size_t newStringLength = self_pp->length + appendStringLen;
	char *result = malloc(newStringLength + 1);
	memset(result, 0, newStringLength + 1);
	memcpy(&result[0], self_pp->value, self_pp->length);
	size_t curLength = self_pp->length;
	memcpy(&result[curLength], appendString, appendStringLen);
	//strcpy(result, self_pp->value);
	//strcat(result, appendString);
	free(self_pp->value);
	self_pp->value = result;
	self_pp->length = newStringLength;
}

void IOString_appendByPathComponent(IOString *self_pp, const char *appendString) {
	
	size_t lastCharLocation = self_pp->length - 1;
	char lastCharacter = self_pp->value[lastCharLocation];
	
	size_t appendStringRealLength = strlen(appendString);
	size_t appendStringLen = appendStringRealLength + 1;
	
	if(lastCharacter != '/') {
		
		appendStringLen += 1;
	}
	
	char *tmpAppendString = malloc(appendStringLen);
	memset(tmpAppendString, 0, appendStringLen);
	
	if(lastCharacter != '/') {
		
		memcpy(&tmpAppendString[0], "/", 1);
		memcpy(&tmpAppendString[1], appendString, appendStringRealLength);
	}else{
		memcpy(&tmpAppendString[0], appendString, appendStringRealLength);
	}
	
	self_pp->append(self_pp, tmpAppendString);
	free(tmpAppendString);
}

IOString *IOString_subString(IOString *self_pp, size_t start, size_t length) {
	
	if(start > self_pp->length - 1) {
		return NULL;
	}
	
	size_t lengthLeft = self_pp->length - start;
	if(length > lengthLeft) {
		return NULL;
	}
	
	char *newString = malloc(length + 1);
	memset(newString, 0, length + 1);
	memcpy(newString, &self_pp->value[start], length);
	IOString *retval = INIT_STRING(newString);
	free(newString);
	return retval;
}

unsigned char IOString_isEqualToString(IOString *self_pp, const char *equality) {
	
	unsigned char retVal = 0;
	int result = strcmp (self_pp->value, equality);
	
	if(result == 0) {
		retVal = 1;
	}
	
	return retVal;
}

void IOStringBucket_release(IOStringBucket *self_pp) {
	
	if(self_pp != NULL) {
		
		size_t i = 0;
		for(i = 0; i < self_pp->count; i++) {
			
			(self_pp->stringArray[i])->release(self_pp->stringArray[i]);
		}
		
		free(self_pp->stringArray);
		free(self_pp);
	}
}

void IOStringBucket_push(IOStringBucket *self_pp, IOString *appendString) {
	
	size_t currentSize = self_pp->count;
	size_t newSize = self_pp->count + 1;
	self_pp->stringArray = realloc(self_pp->stringArray, (newSize * sizeof(void *)) + 1);
	
	if(self_pp->stringArray != NULL) {
		
		self_pp->stringArray[currentSize] = appendString;
		self_pp->count = newSize;
	}
}

void IOStringBucket_removeAt(IOStringBucket *self_pp, size_t index) {
	
	if(index < self_pp->count && self_pp->stringArray != NULL) {
		
		if(self_pp->count > 0) {
			
			size_t newSize = self_pp->count - 1;
			size_t i = 0;
			IOString **stringArray = malloc((newSize * sizeof(void *)) + 1);
			for (i = 0; i < self_pp->count; i++) {
				
				if(index == i) {
					
					self_pp->stringArray[i]->release(self_pp->stringArray[i]);
				}else{
					stringArray[i] = self_pp->stringArray[i];
				}
			}
			
			free(self_pp->stringArray);
			self_pp->stringArray  =stringArray;
		}
	}
}

IOString *IOStringBucket_get(IOStringBucket *self_pp, size_t index) {
	
	if(index < self_pp->count && self_pp->stringArray != NULL) {
		
		return self_pp->stringArray[index];
	}else{
		return NULL;
	}
}
