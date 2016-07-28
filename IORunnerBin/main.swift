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
	
	if(appArguments.helpMode) {
		print(Arguments.getUsage())
	#if swift(>=3)
		
		AppExit.Exit(parent: true, status: AppExit.EXIT_STATUS.SUCCESS)
	#elseif swift(>=2.2) && os(OSX)
		
		AppExit.Exit(true, status: AppExit.EXIT_STATUS.SUCCESS)
	#endif
	}else if(appArguments.versionMode) {
		print(Arguments.getVersion())
	#if swift(>=3)
		
		AppExit.Exit(parent: true, status: AppExit.EXIT_STATUS.SUCCESS)
	#elseif swift(>=2.2) && os(OSX)
		
		AppExit.Exit(true, status: AppExit.EXIT_STATUS.SUCCESS)
	#endif
	}else if(appArguments.buildinfoMode) {
		print(Arguments.getBuildInfo())
	#if swift(>=3)
		
		AppExit.Exit(parent: true, status: AppExit.EXIT_STATUS.SUCCESS)
	#elseif swift(>=2.2) && os(OSX)
		
		AppExit.Exit(true, status: AppExit.EXIT_STATUS.SUCCESS)
	#endif
	}
	
	let currentConfigFile: String
	if(appArguments.config != nil) {
		currentConfigFile = appArguments.config!
	}else{
		currentConfigFile = "./../etc/Config.ini"
	}
	
	#if swift(>=3)
	#if os(Linux)
		let configFileExists = NSFileManager.defaultManager().fileExists(atPath: currentConfigFile)
	#else
		let configFileExists = FileManager.default().fileExists(atPath: currentConfigFile)
	#endif
	if(configFileExists) {
			
		do {
				
			let config = try parseINI(withFile: currentConfigFile)
			let configData = try config.getConfigData()
			if(appArguments.configDumpMode) {
					
				print("\nAll Configurations\n\n")
				dump(configData)
					
				AppExit.Exit(parent: true, status: AppExit.EXIT_STATUS.SUCCESS)
			}else{
					
				let _ = Application(appConfig: configData, appArguments: appArguments)
			}
		} catch (let e) {
			print("\nError:\n\n")
			print(e)
			AppExit.Exit(parent: true, status: AppExit.EXIT_STATUS.FAILURE)
		}
	}else{
		print("\nError: Config file could not found.")
		AppExit.Exit(parent: true, status: AppExit.EXIT_STATUS.FAILURE)
	}
#elseif swift(>=2.2) && os(OSX)
	
	if(NSFileManager.defaultManager().fileExistsAtPath(currentConfigFile)) {
		
		do {
			
			let config = try parseINI(withFile: currentConfigFile)
			let configData = try config.getConfigData()
			if(appArguments.configDumpMode) {
	
				print("\nAll Configurations\n\n")
				dump(configData)

				AppExit.Exit(true, status: AppExit.EXIT_STATUS.SUCCESS)
			}else{
				
				let _ = Application(appConfig: configData, appArguments: appArguments)
			}
		} catch (let e) {
			print("\nError:\n\n")
			print(e)
			AppExit.Exit(true, status: AppExit.EXIT_STATUS.FAILURE)
		}
	}else{
		print("\nError: Config file could not found.")
		AppExit.Exit(true, status: AppExit.EXIT_STATUS.FAILURE)
	}
#endif
	
	
}else{
	print(Arguments.getUsage())
#if swift(>=3)
	
	AppExit.Exit(parent: true, status: AppExit.EXIT_STATUS.FAILURE)
#elseif swift(>=2.2) && os(OSX)
	
	AppExit.Exit(true, status: AppExit.EXIT_STATUS.FAILURE)
#endif
}
