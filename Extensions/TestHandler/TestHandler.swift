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
	
#if swift(>=3.0)
	
#if os(Linux)
	private var currentUnixTime = NSDate().timeIntervalSince1970
#else
	private var currentUnixTime = Date().timeIntervalSince1970
#endif
	
#elseif swift(>=2.2) && os(OSX)
	private var currentUnixTime = NSDate().timeIntervalSince1970
#endif
	
	public required init(logger: Logger, moduleConfig: Section?) {
		
		super.init(logger: logger, moduleConfig: moduleConfig)
		
		if(moduleConfig != nil) {
		#if swift(>=3)
			
			logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Test worker init with config \(moduleConfig)")
		#elseif swift(>=2.2) && os(OSX)
				
			logger.writeLog(Logger.LogLevels.WARNINGS, message: "Test worker init with config \(moduleConfig)")
		#endif
		}
	}
	
	public override func forStart() {
	#if swift(>=3)
		
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Test worker start!")
	#elseif swift(>=2.2) && os(OSX)
			
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Test worker start!")
	#endif
	}
	
	public override func forStop() {
	#if swift(>=3)
		
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Test worker stop!")
	#elseif swift(>=2.2) && os(OSX)
			
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Test worker stop!")
	#endif
	}
	
	#if swift(>=3)
	
	public override func inLoop() {
		
	#if os(Linux)
		let uTime = NSDate().timeIntervalSince1970
	#else
		let uTime = Date().timeIntervalSince1970
	#endif
		if(uTime - currentUnixTime >= 60) {
			currentUnixTime = uTime
			logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Test worker in loop current unix time \(uTime)!")
		}
	}
	#elseif swift(>=2.2) && os(OSX)
	
	public override func inLoop() {
	
		let uTime = NSDate().timeIntervalSince1970
		if(uTime - currentUnixTime >= 60) {
			currentUnixTime = uTime
			logger.writeLog(Logger.LogLevels.WARNINGS, message: "Test worker in loop current unix time \(uTime)!")
		}
	}
	#endif
}
