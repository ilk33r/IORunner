//
//  IORunnerUpdater.c
//  IORunner
//
//  Created by ilker özcan on 02/09/16.
//
//

# include "IORunnerUpdater.h"

IOUpdate *updateData;

void PREPARE_VERSION(101) {
	
	const size_t ruleCount = 24;
	
	INIT_UPDATE_RULES(ruleCount, 101)
	ADD_RULE(101, 0, RULE_OVERRIDE, "0755", FALSE, "Build/bin/IORunner", "bin/IORunner")
	ADD_RULE(101, 1, RULE_OVERRIDE, "0755", FALSE, "Build/lib/libIOGUI.so", "lib/libIOGUI.so")
	ADD_RULE(101, 2, RULE_OVERRIDE, "0755", FALSE, "Build/lib/libIOIni.so", "lib/libIOIni.so")
	ADD_RULE(101, 3, RULE_OVERRIDE, "0755", FALSE, "Build/lib/libIORunnerExtension.so", "lib/libIORunnerExtension.so")
	ADD_RULE(101, 4, RULE_DELETE, "0644", TRUE, "", "frameworks/IOGUI.framework")
	ADD_RULE(101, 5, RULE_DELETE, "0644", TRUE, "", "frameworks/IOIni.framework")
	ADD_RULE(101, 6, RULE_DELETE, "0644", TRUE, "", "frameworks/IORunnerExtension.framework")
	ADD_RULE(101, 7, RULE_COPY, "0755", TRUE, "Build/frameworks/IOGUI.framework", "frameworks/IOGUI.framework")
	ADD_RULE(101, 8, RULE_COPY, "0755", TRUE, "Build/frameworks/IOIni.framework", "frameworks/IOIni.framework")
	ADD_RULE(101, 9, RULE_COPY, "0755", TRUE, "Build/frameworks/IORunnerExtension.framework", "frameworks/IORunnerExtension.framework")
	ADD_RULE(101, 10, RULE_OVERRIDE, "0755", FALSE, "Build/extensions/libBouncyHandler.dylib", "extensions/available/libBouncyHandler.dylib")
	ADD_RULE(101, 11, RULE_OVERRIDE, "0755", FALSE, "Build/extensions/libDovecotHandler.dylib", "extensions/available/libDovecotHandler.dylib")
	ADD_RULE(101, 12, RULE_OVERRIDE, "0755", FALSE, "Build/extensions/libMysqlHandler.dylib", "extensions/available/libMysqlHandler.dylib")
	ADD_RULE(101, 13, RULE_OVERRIDE, "0755", FALSE, "Build/extensions/libNginxHandler.dylib", "extensions/available/libNginxHandler.dylib")
	ADD_RULE(101, 14, RULE_OVERRIDE, "0755", FALSE, "Build/extensions/libOpendkimHandler.dylib", "extensions/available/libOpendkimHandler.dylib")
	ADD_RULE(101, 15, RULE_OVERRIDE, "0755", FALSE, "Build/extensions/libPHPFastCGIHandler.dylib", "extensions/available/libPHPFastCGIHandler.dylib")
	ADD_RULE(101, 16, RULE_OVERRIDE, "0755", FALSE, "Build/extensions/libPostfixHandler.dylib", "extensions/available/libPostfixHandler.dylib")
	ADD_RULE(101, 17, RULE_OVERRIDE, "0755", FALSE, "Build/extensions/libSSHHandler.dylib", "extensions/available/libSSHHandler.dylib")
	ADD_RULE(101, 18, RULE_OVERRIDE, "0755", FALSE, "Build/extensions/libTestHandler.dylib", "extensions/available/libTestHandler.dylib")
	ADD_RULE(101, 19, RULE_COPY, "0755", FALSE, "Build/extensions/libBashScriptHandler.dylib", "extensions/available/libBashScriptHandler.dylib")
	ADD_RULE(101, 20, RULE_DELETE, "0755", TRUE, "", "lib")
	ADD_RULE(101, 21, RULE_CREATE_DIRECTORY, "0775", TRUE, "lib", "")
	ADD_RULE(101, 22, RULE_COPY, "0755", TRUE, "Build/lib", "lib")
	ADD_RULE(101, 23, RULE_APPEND_CONFIG, "0644", FALSE, "etc/Config.ini", GET_CONFIG_DATA(101))
	
	INIT_VERSION(ruleCount, 101, 0)
}

void prepareUpdateData() {
	
	size_t versionCount = 1;
	INIT_UPDATE(versionCount);
	PREPARE_VERSION(101);
}

void releaseUpdateData() {
	
	size_t i = 0;
	for (i = 0; i < GET_UPDATE_VERSION_COUNT; i++) {
		
		IOVersion *version = GET_UPDATE_VERSIONS[i];
		size_t j = 0;
		
		for (j = 0; j < version->ruleCount; j++) {
			
			IOUpdaterRules *rule = version->rules[j];
			free(rule);
		}
		free(version->rules);
		free(version);
	}
	free(updateData->versions);
	free(updateData);
}


