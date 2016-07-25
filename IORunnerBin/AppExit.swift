//
//  AppExit.swift
//  IORunner
//
//  Created by ilker özcan on 11/07/16.
//
//

import Foundation
import IORunnerExtension

internal struct AppExit {
	
	enum EXIT_STATUS: Int32 {
		case SUCCESS = 0
		case FAILURE = 1
	}
	
	private static var logger: Logger? = nil
	
	static func setLogger(logger: Logger!) {
		
		AppExit.logger = logger
	}
	
	static func Exit(parent: Bool, status: EXIT_STATUS) {
		
		if(parent) {
			exit(status.rawValue)
		}else{
			
			AppExit.applicationWillExit()
			exit(status.rawValue)
		}
	}
	
	private static func applicationWillExit() {
		
		if(AppExit.logger != nil) {
			AppExit.logger?.closeLogFile()
		}
		
		// Add pre exit methods
	}
}
