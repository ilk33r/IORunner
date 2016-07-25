//
//  main.swift
//  IORunner
//
//  Created by ilker özcan on 01/07/16.
//  Copyright © 2016 ilkerozcan. All rights reserved.
//

import Foundation
import IOIni

if let appArguments = ArgumentParser().parseArguments() {
	
	/* ## Swift 3
	if(appArguments.helpMode) {
		print(Arguments.getUsage())
		AppExit.Exit(parent: true, status: AppExit.EXIT_STATUS.SUCCESS)
	}else if(appArguments.versionMode) {
		print(Arguments.getVersion())
		AppExit.Exit(parent: true, status: AppExit.EXIT_STATUS.SUCCESS)
	}else if(appArguments.buildinfoMode) {
		print(Arguments.getBuildInfo())
		AppExit.Exit(parent: true, status: AppExit.EXIT_STATUS.SUCCESS)
	}
	*/
	if(appArguments.helpMode) {
		print(Arguments.getUsage())
		AppExit.Exit(true, status: AppExit.EXIT_STATUS.SUCCESS)
	}else if(appArguments.versionMode) {
		print(Arguments.getVersion())
		AppExit.Exit(true, status: AppExit.EXIT_STATUS.SUCCESS)
	}else if(appArguments.buildinfoMode) {
		print(Arguments.getBuildInfo())
		AppExit.Exit(true, status: AppExit.EXIT_STATUS.SUCCESS)
	}
	
	let currentConfigFile: String
	if(appArguments.config != nil) {
		currentConfigFile = appArguments.config!
	}else{
		currentConfigFile = "./../etc/Config.ini"
	}
	
	/* ## Swift 3
	if(FileManager.default().fileExists(atPath: currentConfigFile)) {
	*/
	if(NSFileManager.defaultManager().fileExistsAtPath(currentConfigFile)) {
		
		do {
			
			let config = try parseINI(withFile: currentConfigFile)
			let configData = try config.getConfigData()
			if(appArguments.configDumpMode) {
			
				print("\nAll Configurations\n\n")
				//print(configData)
				dump(configData)
				
				/* ## Swift 3
				AppExit.Exit(parent: true, status: AppExit.EXIT_STATUS.SUCCESS)
				*/
				AppExit.Exit(true, status: AppExit.EXIT_STATUS.SUCCESS)
			}else{
				
				let _ = Application(appConfig: configData, appArguments: appArguments)
			}
		} catch (let e) {
			print("\nError:\n\n")
			print(e)
			/* ## Swift 3
			AppExit.Exit(parent: true, status: AppExit.EXIT_STATUS.FAILURE)
			*/
			AppExit.Exit(true, status: AppExit.EXIT_STATUS.FAILURE)
		}
	}else{
		print("\nError: Config file could not found.")
		/* ## Swift 3
		AppExit.Exit(parent: true, status: AppExit.EXIT_STATUS.FAILURE)
		*/
		AppExit.Exit(true, status: AppExit.EXIT_STATUS.FAILURE)
	}
	
	
}else{
	print(Arguments.getUsage())
	/* ## Swift 3
	AppExit.Exit(parent: true, status: AppExit.EXIT_STATUS.FAILURE)
	*/
	AppExit.Exit(true, status: AppExit.EXIT_STATUS.FAILURE)
}
