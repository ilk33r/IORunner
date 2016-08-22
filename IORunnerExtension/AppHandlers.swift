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
	public var configFilePath: String
	public var moduleConfig: Section?
	
	public required init(logger: Logger, configFilePath: String, moduleConfig: Section?) {
		
		self.logger = logger
		self.configFilePath = configFilePath
		self.moduleConfig = moduleConfig
	}
	
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
		task.waitUntilExit()
		
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
	
	public func executeTask(command: String) -> Task? {

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
			
			#if os(Linux)
				let environments = ProcessInfo.processInfo().environment
			#else
				let environments = ProcessInfo().environment
			#endif
			task.environment = environments
			task.arguments = taskArgs
			task.launch()
			
			return task
		}
		
		return nil
	}
	
	public func startAsyncTask(command: String, extraEnv: [(String, String)]?, extensionName: String?) -> pid_t? {
		
		
		var processConfig = ProcessConfigData()
		var procPid: pid_t? = nil
		
		if(command == "self") {
			
			processConfig.ProcessArgs = [Process.arguments[0], "--config", self.configFilePath, "--onlyusearguments", "--signal", "environ"]
			
			var extEnvArr: [(String, String)]
			if(extraEnv == nil) {
				
				extEnvArr = [(String, String)]()
			}else{
				extEnvArr = extraEnv!
			}
			
			if(extensionName != nil) {
				
				extEnvArr.append(("IO_RUNNER_SN", "ext-start"))
				extEnvArr.append(("IO_RUNNER_EX", extensionName!))
			}
			
			processConfig.Environments = extEnvArr
			
		}else{
			
			let commandWithArgs = command.characters.split(separator: " ").map({String.init($0)})
			
			if(commandWithArgs.count > 0) {
				
				processConfig.ProcessArgs = commandWithArgs
				
				if extraEnv != nil {
					
					processConfig.Environments = extraEnv
				}
				
			}
		}
		
		do {
			
			procPid = try SpawnCurrentProcess(logger: self.logger, configData: processConfig)
		} catch _ {
			procPid = nil
		}
		
		
		return procPid
	}
	
	public func getClassName() -> String {
		
		abort()
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
	
	public func forAsyncTask() -> Void {
		// pass
	}
}
