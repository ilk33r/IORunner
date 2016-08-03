//
//  IODirectory.c
//  IORunner
//
//  Created by ilker özcan on 29/07/16.
//
//

#include "IODirectory.h"

void IODirectory_release(IODirectory *self_pp) {
	
	if(self_pp != NULL) {
		
		self_pp->path->release(self_pp->path);
		if(self_pp->contents != NULL) {
			
			self_pp->contents->release(self_pp->contents);
		}
		
		free(self_pp->types);
		free(self_pp);
	}
}

void IODirectory_generateContentlist(IODirectory *self_pp) {
	
	if(self_pp->fileCount > 0) {
		return;
	}
	
	struct stat st = {0};
	if(stat(self_pp->path->value, &st) == 0) {
		
		DIR *dir;
		struct dirent *ent;
		
		if ((dir = opendir (self_pp->path->value)) != NULL) {
			
			IOStringBucket *dirContents = INIT_STRING_ARRAY();
			self_pp->types = malloc(0);
			size_t currentIdx = 0;
			
			while ((ent = readdir(dir)) != NULL) {
				
				STRING_ARRAY_PUSH_CHAR(dirContents, ent->d_name);
				self_pp->types = realloc(self_pp->types, (currentIdx + 1) * sizeof(unsigned short));
				self_pp->types[currentIdx] = ent->d_type;
				currentIdx += 1;
			}
			
			self_pp->fileCount = currentIdx;
			self_pp->contents = dirContents;
			
			closedir (dir);
		}
	}
}

unsigned char copyDirectory_ex(IODirectory *sourceDirectory, IOString *destinationPath, unsigned char deleteAfterCopy) {
	
	unsigned char retVal = 0;
	sourceDirectory->generateContentlist(sourceDirectory);
	
	struct stat st = {0};
	int dirCreateResult = 0;
	if(stat(destinationPath->value, &st) == -1) {
		
		dirCreateResult = mkdir(destinationPath->value, 0775);
	}
	
	if(dirCreateResult != 0) {
		return retVal;
	}
	
	size_t i = 0;
	for (i = 0; i < sourceDirectory->fileCount; i++) {
		
		IOString *sourceFileName = sourceDirectory->contents->get(sourceDirectory->contents, i);
		if(sourceFileName->value == NULL) {
			continue;
		}
		
		if(sourceFileName->isEqualToString(sourceFileName, "..") == TRUE) {
			continue;
		}
		
		if(sourceFileName->isEqualToString(sourceFileName, ".") == TRUE) {
			continue;
		}
		
		if(IS_FILE(sourceDirectory, i)) {
			
			IOString *destinationFilePath = INIT_STRING(destinationPath->value);
			destinationFilePath->appendByPathComponent(destinationFilePath, sourceFileName->value);
			IOString *sourceFilePath = INIT_STRING(sourceDirectory->path->value);
			sourceFilePath->appendByPathComponent(sourceFilePath, sourceFileName->value);
			
			IO_UNUSED copyFile(sourceFilePath, destinationFilePath);
			destinationFilePath->release(destinationFilePath);
			if(deleteAfterCopy == 1) {
				
				IO_UNUSED unlink(sourceFilePath->value);
			}
			sourceFilePath->release(sourceFilePath);
			
		}else if(IS_LINK(sourceDirectory, i)) {
			
			IOString *sourceFilePath = INIT_STRING(sourceDirectory->path->value);
			sourceFilePath->appendByPathComponent(sourceFilePath, sourceFileName->value);
			IOString *destinationFilePath = INIT_STRING(destinationPath->value);
			destinationFilePath->appendByPathComponent(destinationFilePath, sourceFileName->value);
			char buf[1024];
			memset(&buf[0], 0, 1024);
			ssize_t len = readlink(sourceFilePath->value, buf, sizeof(buf) - 1);
			if(len >= 0) {
				IOString *linkCommand = INIT_STRING("ln -sf ");
				linkCommand->append(linkCommand, &buf[0]);
				linkCommand->append(linkCommand, " ");
				linkCommand->append(linkCommand, destinationFilePath->value);
				system(linkCommand->value);
				linkCommand->release(linkCommand);
			}
			destinationFilePath->release(destinationFilePath);
			if(deleteAfterCopy == 1) {
				unlink(sourceFilePath->value);
			}
			sourceFilePath->release(sourceFilePath);
			
		}else if (IS_DIR(sourceDirectory, i)) {
			
			IOString *sourceDirPath = INIT_STRING(sourceDirectory->path->value);
			sourceDirPath->appendByPathComponent(sourceDirPath, sourceFileName->value);
			IOString *destinationDirPath = INIT_STRING(destinationPath->value);
			destinationDirPath->appendByPathComponent(destinationDirPath, sourceFileName->value);
			IODirectory *currentSourceDirectory = INIT_DIRECTORY(sourceDirPath);
			IO_UNUSED copyDirectory_ex(currentSourceDirectory, destinationDirPath, deleteAfterCopy);
			destinationDirPath->release(destinationDirPath);
			if(deleteAfterCopy == 1) {
				
				IO_UNUSED rmdir(sourceFileName->value);
			}
			currentSourceDirectory->release(currentSourceDirectory);
		}
	}
	
	if(deleteAfterCopy == 1) {
		
		IO_UNUSED rmdir(sourceDirectory->path->value);
	}
	
	retVal = 1;
	return retVal;
}

int copyFile(IOString *source, IOString *destination) {
	
	int input, output;
	if ((input = open(source->value, O_RDONLY)) == -1)
	{
		return -1;
	}
	if ((output = open(destination->value, O_RDWR | O_CREAT)) == -1)
	{
		close(input);
		return -1;
	}
	
	//Here we use kernel-space copying for performance reasons
#if defined(__APPLE__) || defined(__FreeBSD__)
	//fcopyfile works on FreeBSD and OS X 10.5+
	int result = fcopyfile(input, output, 0, COPYFILE_ALL);
#else
	//sendfile will work with non-socket output (i.e. regular file) on Linux 2.6.33+
	off_t bytesCopied = 0;
	struct stat fileinfo = {0};
	fstat(input, &fileinfo);
	int result = sendfile(output, input, &bytesCopied, fileinfo.st_size);
#endif
	
	close(input);
	close(output);
	return result;
}
