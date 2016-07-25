//
//  AppHandlers.swift
//  IORunner/IORunnerExtension
//
//  Created by ilker özcan on 12/07/16.
//
//

import IOIni

public class AppHandlers {
	
	public var logger: Logger
	public var moduleConfig: Section?
	
	public required init(logger: Logger, moduleConfig: Section?) {
		
		self.logger = logger
		self.moduleConfig = moduleConfig
	}
	
	public func forStart() -> Void {
		// pass
	}
	
	public func inLoop() -> Void {
		// pass
	}
	
	public func forStop() -> Void {
		// pass
	}
}
