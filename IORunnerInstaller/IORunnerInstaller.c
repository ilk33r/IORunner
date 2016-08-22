//
//  IORunnerInstaller.c
//  IORunner
//
//  Created by ilker özcan on 28/07/16.
//
//

#include "IORunnerInstaller.h"
#include "ConfigFile.h"
#include "IOAssets.h"

#define UNZIP_COMMAND "/usr/bin/unzip -qq -o %s -d %s"

#if IS_DARWIN == TRUE
#	define DARWIN_SERVICE_FILE RUNNER_DARWIN_SERVICE_PATH DARWIN_SERVICE_NAME
#elif IS_LINUX == TRUE
#	define LINUX_SERVICE_FILE RUNNER_LINUX_SERVICE_PATH LINUX_SERVICE_NAME
#endif

EXTLD(InstallData)
EXTLD(InstallConfig)

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
		
		unsigned int i = 0;
		for(i = 0; i < LDLEN(InstallConfig); i++) {
			
			fputc(LDVAR(InstallConfig)[i], configFileHandle);
		}
		
		fclose(configFileHandle);
	}
	configFile->release(configFile);
}

static void generateBashScript(IOString *installDir, IOString *binDir) {
	
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
	
	IOString *shortcutFile = INIT_STRING(binDir->value);
	shortcutFile->appendByPathComponent(shortcutFile, APP_PACKAGE_NAME);
	shortcutFile->append(shortcutFile, "_shortcut.sh");
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
		destinationPath->append(destinationPath, APP_PACKAGE_NAME);
		copyResult = copyFile(shortcutFile, destinationPath);
	}
	
	if(copyResult == -1) {
		
		if(destinationPath != NULL) {
			printf("\t[FAIL]\n\nAn error occured for creating shortcut file. Please run\ncp %s %s\ncommand as administrator.\nInstall complete with errors!\n", shortcutFile->value, destinationPath->value);
		}else{
			printf("\t[FAIL]\n\nAn error occured for creating shortcut file.\nInstall complete with errors!\n");
		}
	}else{
		
		char modeD[] = "0775";
		IO_UNUSED chmod(destinationPath->value ,strtol(modeD, 0, 8));
		
		printf("\t[OK]\n\nInstall complete.\n");
	}
	
	if(destinationPath != NULL) {
		destinationPath->release(destinationPath);
	}
	
	shortcutFile->release(shortcutFile);
	installRealPath->release(installRealPath);
}

static void updateFilePermissions(IODirectory *dirFiles, const char* mode) {
	
	dirFiles->generateContentlist(dirFiles);
	
	size_t i = 0;
	for (i = 0; i < dirFiles->fileCount; i++) {
		
		IOString *sourceFileName = dirFiles->contents->get(dirFiles->contents, i);
		if(sourceFileName->value == NULL) {
			continue;
		}
		
		if(sourceFileName->isEqualToString(sourceFileName, "..") == TRUE) {
			continue;
		}
		
		if(sourceFileName->isEqualToString(sourceFileName, ".") == TRUE) {
			continue;
		}
		
		IOString *sourceFilePath = INIT_STRING(dirFiles->path->value);
		sourceFilePath->appendByPathComponent(sourceFilePath, sourceFileName->value);
		
		if(IS_FILE(dirFiles, i)) {
			
			long i = strtol(mode, 0, 8);
			IO_UNUSED chmod(sourceFilePath->value ,i);
		}else if(IS_LINK(dirFiles, i)) {
			
			long i = strtol(mode, 0, 8);
			IO_UNUSED chmod(sourceFilePath->value ,i);
		}else if (IS_DIR(dirFiles, i)) {
			
			IODirectory *subdir = INIT_DIRECTORY_WITH_CHAR(sourceFilePath->value);
			updateFilePermissions(subdir, mode);
		}
		
		sourceFilePath->release(sourceFilePath);
	}
	
	dirFiles->release(dirFiles);
}

#if IS_DARWIN == TRUE
static void generateService(IOString *installDir, IOString *etcDir) {
	
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
	
	IOString *shortcutFile = INIT_STRING(etcDir->value);
	shortcutFile->appendByPathComponent(shortcutFile, DARWIN_SERVICE_NAME);
	FILE *appShortcut = fopen(shortcutFile->value, "w");
	if(appShortcut) {
		
		size_t shortcutFileContentLength = strlen(RUNNER_DARWIN_SERVICE) + 1 + (installRealPath->length * 2);
		char *shortcutFileContent = malloc(shortcutFileContentLength);
		if(shortcutFileContent) {
			
			memset(shortcutFileContent, 0, shortcutFileContentLength);
			sprintf(shortcutFileContent, RUNNER_DARWIN_SERVICE, installRealPath->value, installRealPath->value);
			fputs(shortcutFileContent, appShortcut);
			free(shortcutFileContent);
			
			char mode[] = "0644";
			long i = strtol(mode, 0, 8);
			IO_UNUSED chmod(shortcutFile->value ,i);
			
			const char *chownCommandSchema = "chown root %s";
			size_t chownCommandLen = strlen(chownCommandSchema) + shortcutFile->length + 1;
			char *chownCommand = malloc(chownCommandLen);
			memset(chownCommand, 0, chownCommandLen);
			sprintf(chownCommand, chownCommandSchema, shortcutFile->value);
			IO_UNUSED system(chownCommand);
			free(chownCommand);
		}
		
		fclose(appShortcut);
		destinationPath = INIT_STRING(RUNNER_DARWIN_SERVICE_PATH);
		destinationPath->append(destinationPath, DARWIN_SERVICE_NAME);
		copyResult = copyFile(shortcutFile, destinationPath);
	}
	
	if(copyResult == -1) {
		
		if(destinationPath != NULL) {
			printf("\t[FAIL]\n\nAn error occured for creating system service file. Please run\ncp %s %s\ncommand as administrator.\nInstall complete with errors!\n", shortcutFile->value, destinationPath->value);
		}else{
			printf("\t[FAIL]\n\nAn error occured for creating system service file.\nInstall complete with errors!\n");
		}
	}else{
		printf("\t[OK]\n\nInstall complete.\n");
	}
	
	if(destinationPath != NULL) {
		destinationPath->release(destinationPath);
	}
	
	shortcutFile->release(shortcutFile);
	installRealPath->release(installRealPath);
}
#elif IS_LINUX == TRUE
static void generateService(IOString *installDir, IOString *etcDir) {

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
	
	IOString *shortcutFile = INIT_STRING(etcDir->value);
	shortcutFile->appendByPathComponent(shortcutFile, LINUX_SERVICE_NAME);
	shortcutFile->append(shortcutFile, ".init_d");
	FILE *appShortcut = fopen(shortcutFile->value, "w");
	if(appShortcut) {
		
		size_t shortcutFileContentLength = strlen(RUNNER_LINUX_SERVICE) + 1 + installRealPath->length;
		char *shortcutFileContent = malloc(shortcutFileContentLength);
		if(shortcutFileContent) {
			
			memset(shortcutFileContent, 0, shortcutFileContentLength);
			sprintf(shortcutFileContent, RUNNER_LINUX_SERVICE, installRealPath->value);
			fputs(shortcutFileContent, appShortcut);
			free(shortcutFileContent);
			
			char mode[] = "0755";
			long i = strtol(mode, 0, 8);
			IO_UNUSED chmod(shortcutFile->value ,i);
			
			const char *chownCommandSchema = "chown root %s";
			size_t chownCommandLen = strlen(chownCommandSchema) + shortcutFile->length + 1;
			char *chownCommand = malloc(chownCommandLen);
			memset(chownCommand, 0, chownCommandLen);
			sprintf(chownCommand, chownCommandSchema, shortcutFile->value);
			IO_UNUSED system(chownCommand);
			free(chownCommand);
		}
		
		fclose(appShortcut);
		destinationPath = INIT_STRING(RUNNER_LINUX_SERVICE_PATH);
		destinationPath->append(destinationPath, LINUX_SERVICE_NAME);
		copyResult = copyFile(shortcutFile, destinationPath);
	}
	
	if(copyResult == -1) {
		
		if(destinationPath != NULL) {
			printf("\t[FAIL]\n\nAn error occured for creating system service file. Please run\ncp %s %s\ncommand as administrator.\nInstall complete with errors!\n", shortcutFile->value, destinationPath->value);
		}else{
			printf("\t[FAIL]\n\nAn error occured for creating system service file.\nInstall complete with errors!\n");
		}
	}else{
		printf("\t[OK]\n\nInstall complete.\n");
	}
	
	if(destinationPath != NULL) {
		destinationPath->release(destinationPath);
	}
	
	shortcutFile->release(shortcutFile);
	installRealPath->release(installRealPath);
}
#else
static void generateService(IOString *installDir, IOString *etcDir) {}
#endif

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
		
			printf("Application already installed!\n");
			zipFilePath->release(zipFilePath);
			installPath->release(installPath);
			buildDirectory->release(buildDirectory);
			return 1;
		}
	
	
		FILE *zipFile = fopen(zipFilePath->value, "w");
		if(zipFile == NULL) {
		
			printf("An error occured for writing files.\n");
			zipFilePath->release(zipFilePath);
			installPath->release(installPath);
			buildDirectory->release(buildDirectory);
			return 1;
		}

		unsigned int i = 0;
		for(i = 0; i < LDLEN(InstallData); i++) {
		
			fputc(LDVAR(InstallData)[i], zipFile);
		}
	
		fclose(zipFile);
	
		size_t unzipCommadLen = strlen(UNZIP_COMMAND) + zipFilePath->length + installPath->length + 1;
		char *unzipCommand = malloc(unzipCommadLen);
		memset(unzipCommand, 0, unzipCommadLen);
		sprintf(unzipCommand, UNZIP_COMMAND, zipFilePath->value, installPath->value);
		int processResult = system(unzipCommand);
		sleep(4);
		free(unzipCommand);
		long writableChmode = strtol("0777", 0, 8);

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
					IO_UNUSED mkdir(tmpDestinationPath->value, 0775);
					IO_UNUSED chmod(tmpDestinationPath->value, writableChmode);
					tmpDestinationPath->appendByPathComponent(tmpDestinationPath, "available");
					IO_UNUSED mkdir(tmpDestinationPath->value, 0777);
					IO_UNUSED chmod(tmpDestinationPath->value, writableChmode);
// MOVE_DIR(sourceDir, tmpDestinationPath);
COPY_DIR(sourceDir, tmpDestinationPath);
					tmpDestinationPath->release(tmpDestinationPath);
					sourceDir->release(sourceDir);
				
				}else{
					IOString *currentDirPath = INIT_STRING(buildDirectory->value);
					currentDirPath->appendByPathComponent(currentDirPath, currentDir->value);
					IODirectory *sourceDir = INIT_DIRECTORY(currentDirPath);
					IOString *tmpDestinationPath = INIT_STRING(installPath->value);
					tmpDestinationPath->appendByPathComponent(tmpDestinationPath, currentDir->value);
// MOVE_DIR(sourceDir, tmpDestinationPath);
COPY_DIR(sourceDir, tmpDestinationPath);
					tmpDestinationPath->release(tmpDestinationPath);
					sourceDir->release(sourceDir);
				}
			}
		
			IO_UNUSED rmdir(buildDir->path->value);
			buildDir->release(buildDir);
		
			IOString *enabledExtensionsDir = INIT_STRING(installPath->value);
			enabledExtensionsDir->appendByPathComponent(enabledExtensionsDir, "extensions/enabled");
			IO_UNUSED mkdir(enabledExtensionsDir->value, 0777);
			IO_UNUSED chmod(enabledExtensionsDir->value, writableChmode);
			enabledExtensionsDir->release(enabledExtensionsDir);
		
			IOString *etcDir = INIT_STRING(installPath->value);
			etcDir->appendByPathComponent(etcDir, "etc");
			IO_UNUSED mkdir(etcDir->value, 0775);
			
			IOString *varDir = INIT_STRING(installPath->value);
			varDir->appendByPathComponent(varDir, "var");
			IO_UNUSED mkdir(varDir->value, 0777);
			IO_UNUSED chmod(varDir->value, writableChmode);
		
			IOString *logDir = INIT_STRING(installPath->value);
			logDir->appendByPathComponent(logDir, "var/log");
			IO_UNUSED mkdir(logDir->value, 0777);
			IO_UNUSED chmod(logDir->value, writableChmode);
		
			IOString *runDir = INIT_STRING(installPath->value);
			runDir->appendByPathComponent(runDir, "var/run");
			IO_UNUSED mkdir(runDir->value, 0777);
			IO_UNUSED chmod(runDir->value, writableChmode);
		
			IOString *extensionDir = INIT_STRING(installPath->value);
			extensionDir->appendByPathComponent(extensionDir, "extensions");
		
			IOString *binPath = INIT_STRING(installPath->value);
			binPath->appendByPathComponent(binPath, "bin");
			
			printf("\nGenerating config file ...");
			generateConfigFile(etcDir, logDir, runDir, extensionDir);
			printf("\t[OK]\n");
			printf("Generating shortcut file ...");
			generateBashScript(installPath, binPath);
			printf("Generating system service file ...");
			generateService(installPath, etcDir);
			
			IODirectory *etcIODir = INIT_DIRECTORY(etcDir);
			updateFilePermissions(etcIODir, "0644");
			
			IODirectory *binIODir = INIT_DIRECTORY(binPath);
			updateFilePermissions(binIODir, "0755");
			
			IOString *libIOPath = INIT_STRING(installPath->value);
			libIOPath->appendByPathComponent(libIOPath, "lib");
			IODirectory *libIODir = INIT_DIRECTORY(libIOPath);
			updateFilePermissions(libIODir, "0755");
			
			IOString *enabledExtensionDir = INIT_STRING(extensionDir->value);
			enabledExtensionDir->appendByPathComponent(enabledExtensionDir, "available");
			IODirectory *enabledExtensionIODir = INIT_DIRECTORY(enabledExtensionDir);
			updateFilePermissions(enabledExtensionIODir, "0755");
			
			IOString *frameworksDirPath = INIT_STRING(installPath->value);
			frameworksDirPath->appendByPathComponent(frameworksDirPath, "frameworks");
			IODirectory *frameworksDirectory = INIT_DIRECTORY(frameworksDirPath);
			updateFilePermissions(frameworksDirectory, "0755");
			
			extensionDir->release(extensionDir);
			varDir->release(varDir);
			logDir->release(logDir);
			runDir->release(runDir);
		
		}else{
		
			zipFilePath->release(zipFilePath);
			installPath->release(installPath);
			buildDirectory->release(buildDirectory);
			printf("An error occured when opening zip file. Are you sure zip/unzip installed ?\n");
			return 1;
		}
	
		unlink(zipFilePath->value);
		zipFilePath->release(zipFilePath);
		installPath->release(installPath);
	
		return 0;
	}else{
		
		IOStringBucket *installedPaths = processResponse->split(processResponse, "\n");
		if(installedPaths->count > 0) {
			
			IOString *installedPathStr = installedPaths->get(installedPaths, 0);
			IOString *installedPathStrCopy = INIT_STRING(installedPathStr->value);
			installedPaths->release(installedPaths);
			IODirectory *installedPathDir = INIT_DIRECTORY(installedPathStrCopy);
			Bool uninstallResult = deleteDirectory(installedPathDir);
			if(uninstallResult == TRUE) {
				
				unlink(PROCESS_MAIN_COMMAND);
				#if IS_DARWIN == TRUE
				unlink(DARWIN_SERVICE_FILE);
				#elif IS_LINUX == TRUE
				unlink(LINUX_SERVICE_FILE);
				#endif
				printf("Application uninstalled.\nPlease re-run installer.");
			}else{
				printf("An error occured when uninstalling %s\n", APP_NAME);
			}
			
			installedPathDir->release(installedPathDir);
		}else{
			printf("An error occured when uninstalling %s\n", APP_NAME);
		}
		
		processResponse->release(processResponse);
		return 0;
	}
}

