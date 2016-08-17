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
		
		var processArguments = [String]()
		let splittedProcName = processName.characters.split(separator: " ").map(String.init)
		
		for procArg in splittedProcName {
			processArguments.append(procArg)
		}
		
		task.arguments = processArguments
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
	
	public func executeTask(command: String) {
		
		let commandWithArgs = command.characters.split(separator: " ")
				
		if(commandWithArgs.count > 0) {
					
			let task = Task()
			task.launchPath = String(commandWithArgs[0])
					
			var taskArgs = [String]()
			var loopIdx = 0
			for argument in commandWithArgs {
						
				if(loopIdx > 0) {
							
					taskArgs.append(String(argument))
				}
						
				loopIdx += 1
			}
					
			task.launch()
		}
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
