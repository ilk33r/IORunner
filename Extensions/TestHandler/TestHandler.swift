//
//  TestHandler.swift
//  IORunner/Extensions/TestHandler
//
//  Created by ilker özcan on 08/07/16.
//
//

import Foundation
import IOIni
import IORunnerExtension

public class TestHandler: AppHandlers {
	
	private var currentUnixTime = NSDate().timeIntervalSince1970
	
	public required init(logger: Logger, moduleConfig: Section?) {
		
		super.init(logger: logger, moduleConfig: moduleConfig)
		
		if(moduleConfig != nil) {
			logger.writeLog(Logger.LogLevels.WARNINGS, message: "Test worker init with config \(moduleConfig)")
		}
	}
	
	public override func forStart() {
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Test worker start!")
	}
	
	public override func forStop() {
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Test worker stop!")
	}
	
	public override func inLoop() {
		
		let uTime = NSDate().timeIntervalSince1970
		if(uTime - currentUnixTime >= 60) {
			currentUnixTime = uTime
			logger.writeLog(Logger.LogLevels.WARNINGS, message: "Test worker in loop current unix time \(uTime)!")
		}
	}
}
