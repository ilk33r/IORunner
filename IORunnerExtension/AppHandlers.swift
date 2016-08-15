//
//  AppHandlers.swift
//  IORunner/IORunnerExtension
//
//  Created by ilker özcan on 12/07/16.
//
//

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif
import Foundation
import IOIni

public class AppHandlers {
	
	public var logger: Logger
	public var moduleConfig: Section?
	
	public required init(logger: Logger, moduleConfig: Section?) {
		
		self.logger = logger
		self.moduleConfig = moduleConfig
	}
	
#if swift(>=3)
	public func checkProcess(processName: String) -> [Int] {
		
		var retval = [Int]()
		
		let task = Task()
		task.launchPath = "/usr/bin/pgrep"
		task.arguments = [processName]
		
		let pipe = Pipe()
		task.standardOutput = pipe
		task.launch()
		
		let data = pipe.fileHandleForReading.readDataToEndOfFile()
		let output = String(data: data, encoding: String.Encoding.utf8)
		
		if(output != nil) {
			
			if let splittedPids = output?.characters.split(separator: "\n") {
			
				for pids in splittedPids {
				
					if let pidInt = Int(String(pids)) {
						
						retval.append(pidInt)
					}
				}
			}
		}
		
		return retval
	}
	
#endif
	
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
