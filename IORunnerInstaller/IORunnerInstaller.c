//
//  IORunnerInstaller.c
//  IORunner
//
//  Created by ilker özcan on 28/07/16.
//
//

#include "IORunnerInstaller.h"

#include "ConfigFile.h"
#define UNZIP_COMMAND "/usr/bin/unzip -qq -o %s -d %s"

static void generateConfigFile(IOString *etcDir, IOString *logDir, IOString *runDir, IOString *extDir) {
	
	IOString *configFile = INIT_STRING(etcDir->value);
	configFile->appendByPathComponent(configFile, "Config.ini");
	FILE *configFileHandle = fopen(configFile->value, "w");
	if(configFileHandle != NULL) {
		
		IOString *pidFile = INIT_STRING(APP_PACKAGE_NAME);
		pidFile->append(pidFile, ".pid");
		
		IOString *logFile = INIT_STRING(APP_PACKAGE_NAME);
		logFile->append(logFile, ".log");
		
		IOString *pidFilePath = INIT_STRING(runDir->value);
		pidFilePath->appendByPathComponent(pidFilePath, pidFile->value);
		pidFile->release(pidFile);
		
		IOString *logFilePath = INIT_STRING(logDir->value);
		logFilePath->appendByPathComponent(logFilePath, logFile->value);
		logFile->release(logFile);
		
		size_t configFileBufferLen = strlen(RUNNER_CONFIG_INI) + pidFilePath->length + logFilePath->length + extDir->length + 1;
		char *configFileData = malloc(configFileBufferLen);
		
		if(configFileData != NULL) {
			
			memset(configFileData, 0, configFileBufferLen);
			sprintf(configFileData, RUNNER_CONFIG_INI, pidFilePath->value, logFilePath->value, extDir->value);
			fputs(configFileData, configFileHandle);
			free(configFileData);
		}
		
		pidFilePath->release(pidFilePath);
		logFilePath->release(logFilePath);
		
		fclose(configFileHandle);
	}
	configFile->release(configFile);
}

static void generateBashScript(IOString *installDir) {
	
	size_t lastCharacterIdx = installDir->length - 1;
	IOString *lastCharacter = installDir->subString(installDir, lastCharacterIdx, 1);
	IOString *installRealPath = NULL;
	IOString *destinationPath = NULL;
	int copyResult = -1;
	
	if(lastCharacter->isEqualToString(lastCharacter, "/") == TRUE) {
		
		installRealPath = installDir->subString(installDir, 0, lastCharacterIdx);
	}else{
		
		installRealPath = INIT_STRING(installDir->value);
	}
	
	lastCharacter->release(lastCharacter);
	
	IOString *shortcutFile = INIT_STRING(installRealPath->value);
	shortcutFile->appendByPathComponent(shortcutFile, APP_PACKAGE_NAME);
	FILE *appShortcut = fopen(shortcutFile->value, "w");
	if(appShortcut) {
		
		size_t shortcutFileContentLength = strlen(RUNNER_SHORTCUT_BASH) + 1 + installRealPath->length;
		char *shortcutFileContent = malloc(shortcutFileContentLength);
		if(shortcutFileContent) {
			
			memset(shortcutFileContent, 0, shortcutFileContentLength);
			sprintf(shortcutFileContent, RUNNER_SHORTCUT_BASH, installRealPath->value);
			fputs(shortcutFileContent, appShortcut);
			free(shortcutFileContent);
			
			char mode[] = "0775";
			long i = strtol(mode, 0, 8);
			IO_UNUSED chmod(shortcutFile->value ,i);
		}
		
		fclose(appShortcut);
		destinationPath = INIT_STRING("/usr/local/bin/");
		copyResult = copyFile(shortcutFile, destinationPath);
	}
	
	if(copyResult == -1) {
		
		if(destinationPath != NULL) {
			printf("\t[FAIL]\n\nAn error occured for creating shortcut file. Please run\ncp %s %s\ncommand as administrator.\nInstall complete with errors!", shortcutFile->value, destinationPath->value);
		}else{
			printf("\t[FAIL]\n\nAn error occured for creating shortcut file.\nInstall complete with errors!");
		}
	}else{
		printf("\t[OK]\n\nInstall complete.");
	}
	
	if(destinationPath != NULL) {
		destinationPath->release(destinationPath);
	}
	
	shortcutFile->release(shortcutFile);
	installRealPath->release(installRealPath);
}

int main(int argc, const char *argv[]) {
	
	if(argc < 2) {
		printf(USAGE_STRING);
		return 1;
	}
	
	IOString *processResponse = IOProcess_readProcess(PROCESS_IS_INSTALLED_COMMAND);
	Bool isInstall = FALSE;
	
	if(processResponse == NULL) {
		
		isInstall = TRUE;
	}else if(processResponse->length < 2) {
		
		processResponse->release(processResponse);
		isInstall = TRUE;
	}
	
	if(isInstall == TRUE) {
	
		struct stat st = {0};
	
		if (stat(argv[1], &st) == -1) {
		
			int createInstallDirResult = mkdir(argv[1], 0775);
		
			if(createInstallDirResult) {
			
				printf("An error occured for creating directory %s\n", argv[1]);
				return 1;
			}
		}
	
		IOString *installPath = INIT_STRING(argv[1]);
	
		if(installPath->isEqualToString(installPath, "/") || installPath->isEqualToString(installPath, "/usr/local") || installPath->isEqualToString(installPath, "/usr/local/")) {
		
			printf("You can not install the application to the %s\nPlease pick different directory like /usr/local/%s\n", installPath->value, APP_PACKAGE_NAME);
			installPath->release(installPath);
			return -1;
		}
		
		printf("Installing ...");
		IOString *zipFilePath = INIT_STRING(installPath->value);
		zipFilePath->appendByPathComponent(zipFilePath, "installData.zip");
	
		IOString *buildDirectory = INIT_STRING(installPath->value);
		buildDirectory->appendByPathComponent(buildDirectory, "Build");
		struct stat st2 = {0};
		if(stat(buildDirectory->value, &st2) == 0) {
		
			printf("Application already installed!");
			zipFilePath->release(zipFilePath);
			installPath->release(installPath);
			buildDirectory->release(buildDirectory);
			return 1;
		}
	
	
		FILE *zipFile = fopen(zipFilePath->value, "w");
		if(zipFile == NULL) {
		
			printf("An error occured for writing files.");
			zipFilePath->release(zipFilePath);
			installPath->release(installPath);
			buildDirectory->release(buildDirectory);
			return 1;
		}
	
		unsigned int i = 0;
		for(i = 0; i < Build_IORunnerInstallData_len; i++) {
		
			fputc(Build_IORunnerInstallData[i], zipFile);
		
			if(i % 1000 == 0) {
				printf(".");
			}
		}
	
		fclose(zipFile);
	
		size_t unzipCommadLen = strlen(UNZIP_COMMAND) + zipFilePath->length + installPath->length + 1;
		char *unzipCommand = malloc(unzipCommadLen);
		memset(unzipCommand, 0, unzipCommadLen);
		sprintf(unzipCommand, UNZIP_COMMAND, zipFilePath->value, installPath->value);
		int processResult = system(unzipCommand);
		sleep(2);
		free(unzipCommand);

		if(processResult == 0) {
		
			IODirectory *buildDir = INIT_DIRECTORY(buildDirectory);
			buildDir->generateContentlist(buildDir);
			size_t j = 0;
			for(j = 0; j < buildDir->fileCount; j++) {
			
				IOString *currentDir = buildDir->contents->get(buildDir->contents, j);
				if(currentDir->value == NULL) {
					continue;
				}
			
				if(currentDir->isEqualToString(currentDir, "..") == TRUE) {
					continue;
				}
			
				if(currentDir->isEqualToString(currentDir, ".") == TRUE) {
					continue;
				}
			
				unsigned char isExtensionsDir = currentDir->isEqualToString(currentDir, "extensions");
				if(isExtensionsDir == TRUE) {
				
					IOString *currentDirPath = INIT_STRING(buildDirectory->value);
					currentDirPath->appendByPathComponent(currentDirPath, currentDir->value);
					IODirectory *sourceDir = INIT_DIRECTORY(currentDirPath);
					IOString *tmpDestinationPath = INIT_STRING(installPath->value);
					tmpDestinationPath->appendByPathComponent(tmpDestinationPath, currentDir->value);
					mkdir(tmpDestinationPath->value, 0775);
					tmpDestinationPath->appendByPathComponent(tmpDestinationPath, "available");
					mkdir(tmpDestinationPath->value, 0775);
					MOVE_DIR(sourceDir, tmpDestinationPath);
					tmpDestinationPath->release(tmpDestinationPath);
					sourceDir->release(sourceDir);
				
				}else{
					IOString *currentDirPath = INIT_STRING(buildDirectory->value);
					currentDirPath->appendByPathComponent(currentDirPath, currentDir->value);
					IODirectory *sourceDir = INIT_DIRECTORY(currentDirPath);
					IOString *tmpDestinationPath = INIT_STRING(installPath->value);
					tmpDestinationPath->appendByPathComponent(tmpDestinationPath, currentDir->value);
					MOVE_DIR(sourceDir, tmpDestinationPath);
					tmpDestinationPath->release(tmpDestinationPath);
					sourceDir->release(sourceDir);
				
				}
			}
		
			IO_UNUSED rmdir(buildDir->path->value);
			buildDir->release(buildDir);
		
			IOString *enabledExtensionsDir = INIT_STRING(installPath->value);
			enabledExtensionsDir->appendByPathComponent(enabledExtensionsDir, "extensions/enabled");
			IO_UNUSED mkdir(enabledExtensionsDir->value, 0775);
			enabledExtensionsDir->release(enabledExtensionsDir);
		
			IOString *etcDir = INIT_STRING(installPath->value);
			etcDir->appendByPathComponent(etcDir, "etc");
			IO_UNUSED mkdir(etcDir->value, 0775);
		
			IOString *varDir = INIT_STRING(installPath->value);
			varDir->appendByPathComponent(varDir, "var");
			IO_UNUSED mkdir(varDir->value, 0775);
		
			IOString *logDir = INIT_STRING(installPath->value);
			logDir->appendByPathComponent(logDir, "var/log");
			IO_UNUSED mkdir(logDir->value, 0775);
		
			IOString *runDir = INIT_STRING(installPath->value);
			runDir->appendByPathComponent(runDir, "var/run");
			mkdir(runDir->value, 0775);
		
			IOString *extensionDir = INIT_STRING(installPath->value);
			extensionDir->appendByPathComponent(extensionDir, "extensions");
		
			printf("\nGenerating config file ...");
			generateConfigFile(etcDir, logDir, runDir, extensionDir);
			printf("\t[OK]\n");
			printf("Generating shortcut file ...");
			generateBashScript(installPath);
		
			extensionDir->release(extensionDir);
			varDir->release(varDir);
			logDir->release(logDir);
			runDir->release(runDir);
			etcDir->release(etcDir);
		
		}else{
		
			zipFilePath->release(zipFilePath);
			installPath->release(installPath);
			buildDirectory->release(buildDirectory);
			printf("An error occured when opening zip file. Are you sure zip/unzip installed ?");
			return 1;
		}
	
		unlink(zipFilePath->value);
		zipFilePath->release(zipFilePath);
		installPath->release(installPath);
	
		return 0;
	}else{
		// uninstall
		printf("Process response: \n%s.\n.", processResponse->value);
		processResponse->release(processResponse);
		return 0;
	}
}

