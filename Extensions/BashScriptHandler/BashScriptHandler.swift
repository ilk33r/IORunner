//
//  BashScriptHandler.swift
//  IORunner/Extensions/BashScriptHandler
//
//  Created by ilker özcan on 10/08/16.
//
//

import Foundation
import IOIni
import IORunnerExtension

public class BashScriptHandler: AppHandlers {

#if swift(>=3)
	private var processStatus: [Int] = [Int]()
	private var checkingFrequency: Int = 60
	private var taskTimeout: Int = 60
	
	// 0 waiting, 1 stopping, 2 starting
	private var taskStatus = 0
#if os(Linux)
	private var lastTask: Task?
#else
	private var lastTask: Process?
#endif
	private var lastCheckDate: Date?
	private var lastTaskStartDate = 0
	private var asyncTaskPid: pid_t?
	private var asyncTaskStartTime: UInt = 0
	
	private var bashScriptCount = 0
	private var bashStatusses: [String]!
	private var bashStopCommands: [String]!
	private var bashStartCommands: [String]!
	private var currentScript = -1
	private var moduleConfigIsCorrect = false
	
	public required init(logger: Logger, configFilePath: String, moduleConfig: Section?) {

		super.init(logger: logger, configFilePath: configFilePath, moduleConfig: moduleConfig)
		
		if let currentProcessFrequency = moduleConfig?["ProcessFrequency"] {
		
			if let frequencyInt = Int(currentProcessFrequency) {
				
				self.checkingFrequency = frequencyInt
			}
		}
		
		if let currentProcessTimeout = moduleConfig?["ProcessTimeout"] {
			
			if let timeoutInt = Int(currentProcessTimeout) {
				
				self.taskTimeout = timeoutInt
			}
		}

		self.currentScript = -1
		if let currentBashScriptCount = moduleConfig?["BashScriptCount"] {
			
			if let currentBashScriptCountInt = Int(currentBashScriptCount) {
				
				bashScriptCount = currentBashScriptCountInt
			}
		}

		self.bashStatusses = [String]()
		if let currentBashStatusses = moduleConfig?["ProcessStatuses"] {
			
			let stripped = currentBashStatusses.characters.split(separator: ":").map(String.init)
			if(stripped.count > 0) {
				self.bashStatusses = stripped
			}
		}

		self.bashStopCommands = [String]()
		if let currentBashStopCommands = moduleConfig?["ProcessStopCommands"] {
			
			let stripped = currentBashStopCommands.characters.split(separator: ":").map(String.init)
			if(stripped.count > 0) {
				self.bashStopCommands = stripped
			}
		}

		self.bashStartCommands = [String]()
		if let currentBashStartCommands = moduleConfig?["ProcessStartCommands"] {
			
			let stripped = currentBashStartCommands.characters.split(separator: ":").map(String.init)
			if(stripped.count > 0) {
				self.bashStartCommands = stripped
			}
		}
		
		if(self.bashScriptCount > 0 && self.bashStatusses.count == self.bashScriptCount && self.bashStopCommands.count == self.bashScriptCount && self.bashStartCommands.count == self.bashScriptCount) {
			
			self.moduleConfigIsCorrect = true
		}
	}

	public override func getClassName() -> String {
		
		return String(describing: self)
	}
	
	public override func forStart() {
		
		self.logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "BASH extension registered!")
		self.lastCheckDate = Date()
	}
	
	public override func inLoop() {
	
		if(moduleConfigIsCorrect) {
			
			if(lastCheckDate != nil) {
			
				let currentDate = Int(Date().timeIntervalSince1970)
				let lastCheckDif = currentDate - Int(lastCheckDate!.timeIntervalSince1970)
			
				if(lastCheckDif >= self.checkingFrequency) {
				
					if(!self.checkBashProcess()) {
				
						self.restartBash()
					}
				
					if(self.asyncTaskPid != nil) {
					
						self.waitAsyncTask()
					}
				}
			}else{
			
				self.lastCheckDate = Date()
			}
		}
	}
	
	public override func forAsyncTask() {
		
		if(!self.moduleConfigIsCorrect) {
			return
		}
		
		if(self.currentScript == -1) {
			
		#if os(Linux)
			let environments = ProcessInfo.processInfo().environment
		#else
			let environments = ProcessInfo.processInfo.environment
		#endif
			
			if let currentBashScriptNumStr = environments["IO_RUNNER_BASH_EXT_SCRIPT"] {
				
				if let currentBashScriptNumInt = Int(currentBashScriptNumStr) {
					self.currentScript = currentBashScriptNumInt
					forAsyncTask()
				}
			}
			
			return
		}
		
		if(self.taskStatus == 0) {
			
			self.taskStatus = 1
			self.lastTaskStartDate = Int(Date().timeIntervalSince1970)
			
			let processStopCommand = bashStopCommands[self.currentScript]
			self.lastTask = self.executeTask(command: processStopCommand)
			
		}else if(self.taskStatus == 1) {
			
			guard self.lastTask != nil else {
				
				self.taskStatus = 0
				return
			}
			
			let taskIsRunning: Bool
		#if os(Linux)
			taskIsRunning = self.lastTask!.running
		#else
			taskIsRunning = self.lastTask!.isRunning
		#endif
			if(!taskIsRunning) {
				
				self.taskStatus = 2
				self.lastTaskStartDate = Int(Date().timeIntervalSince1970)
				
				let processStartCommand = bashStartCommands[self.currentScript]
				self.lastTask = self.executeTask(command: processStartCommand)
			}
		}else if(self.taskStatus == 2) {
			
			guard self.lastTask != nil else {
				
				self.taskStatus = 0
				return
			}
			
			let lastTaskIsRunning: Bool
		#if os(Linux)
			lastTaskIsRunning = self.lastTask!.running
		#else
			lastTaskIsRunning = self.lastTask!.isRunning
		#endif
			
			if(!lastTaskIsRunning) {
				
				self.taskStatus = 0
			}
		}
		
		if(self.taskStatus != 0) {
		
			let curDate = Int(Date().timeIntervalSince1970)
			let startDif = curDate - self.lastTaskStartDate
			
			if(startDif > taskTimeout) {
				
				self.taskStatus = 0
			}else{
				
				usleep(300000)
				self.forAsyncTask()
			}
			
		}
	}

	private func executeTaskWithPipe(command: String, args: [String], withAsync: Bool) -> String? {
		
	#if os(Linux)
		let task = Task()
	#else
		let task = Process()
	#endif
		task.launchPath = command
	#if os(Linux)
		let environments = ProcessInfo.processInfo().environment
	#else
		let environments = ProcessInfo().environment
	#endif
		task.environment = environments
		task.arguments = args
		
		if(withAsync) {
			
			self.lastTask = task
		}
		
		let pipe: Pipe?
		
		if(!withAsync) {
			pipe = Pipe()
			task.standardOutput = pipe
		}else{
			pipe = nil
		}
		
		task.launch()
		
		if(!withAsync) {
			task.waitUntilExit()
			
			let data = pipe!.fileHandleForReading.readDataToEndOfFile()
			let output = String(data: data, encoding: String.Encoding.utf8)
			return output
		}else{
			return nil
		}
	}
	
	private func checkBashProcess() -> Bool {
		
		if(moduleConfigIsCorrect) {
			
			lastCheckDate = Date()
			self.currentScript += 1
			if(self.currentScript >= self.bashScriptCount) {
				self.currentScript = 0
			}
			
			var processArguments = [String]()
			let splittedProcName: [String]
			splittedProcName = self.bashStatusses[self.currentScript].characters.split(separator: " ").map(String.init)
			
			var idx = 0
			var processCommand: String
			
			if(splittedProcName.count > 0) {
				
				processCommand = splittedProcName[0]
				
				for procArg in splittedProcName {
					
					if(idx == 0) {
						idx += 1
						continue
					}
					processArguments.append(procArg)
					
					idx += 1
				}
			}else{
				processCommand = "/bin/bash"
			}
			
			if let response = self.executeTaskWithPipe(command: processCommand, args: processArguments, withAsync: false) {
				
				let strippedResponse = response.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
				do {
					let internalExpression = try NSRegularExpression(pattern: "OK", options: .caseInsensitive)
					let matches = internalExpression.matches(in: strippedResponse, options: .reportProgress, range:NSMakeRange(0, strippedResponse.characters.count))
					
					if(matches.count > 0) {
						return true
					}else{
						self.logger.writeLog(level: Logger.LogLevels.ERROR, message: "BASH SCRIPT \(self.currentScript) is not running...")
						return false
					}
					
				} catch _ {
					self.logger.writeLog(level: Logger.LogLevels.ERROR, message: "BASH SCRIPT \(self.currentScript) is not running...")
					return false
				}
			}
		}
		
		return true
	}
	
	private func restartBash() {

		self.logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Restarting BASH SCRIPT \(self.currentScript)")
		
		if(self.asyncTaskPid == nil) {
		
			self.asyncTaskStartTime = UInt(Date().timeIntervalSince1970)
			
			let extraEnv: [(String, String)] = [("IO_RUNNER_BASH_EXT_SCRIPT", "\(self.currentScript)")]
			self.asyncTaskPid = self.startAsyncTask(command: "self", extraEnv: extraEnv, extensionName: self.getClassName())
		}else{
			
			self.logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "BASH SCRIPT \(self.currentScript) Async task already started")
			if(kill(self.asyncTaskPid!, 0) != 0) {
				
				self.logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "BASH SCRIPT \(self.currentScript) Async task already started but does not work!")
				self.asyncTaskPid = nil
				self.restartBash()
			}
		}
	}
	
	private func waitAsyncTask() {
		
		let curDate = UInt(Date().timeIntervalSince1970)
		let startDif = curDate - self.asyncTaskStartTime
		
		if(startDif > UInt(taskTimeout + 30)) {
			
			if(kill(self.asyncTaskPid!, 0) == 0) {
				
				var pidStatus: Int32 = 0
				waitpid(self.asyncTaskPid!, &pidStatus, 0)
				self.asyncTaskPid = nil
			}else{
				
				self.asyncTaskPid = nil
			}
		}
	}
	
#elseif swift(>=2.2) && os(OSX)
	public required init(logger: Logger, configFilePath: String, moduleConfig: Section?) {
	
		super.init(logger: logger, configFilePath: configFilePath, moduleConfig: moduleConfig)
		self.logger.writeLog(Logger.LogLevels.ERROR, message: "BASH SCRIPT extension only works swift >= 3 build.")
	}
#endif

}


