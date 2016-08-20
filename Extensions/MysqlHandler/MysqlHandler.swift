//
//  MysqlHandler.swift
//  IORunner/Extensions/MysqlHandler
//
//  Created by ilker özcan on 10/08/16.
//
//

import Foundation
import IOIni
import IORunnerExtension

public class MysqlHandler: AppHandlers {

	private var processStatus: [Int] = [Int]()
	private var checkingFrequency: Int = 60
	private var taskTimeout: Int = 60
	
	// 0 waiting, 1 stopping, 2 starting
	private var taskStatus = 0
	private var lastTask: Task?
	private var lastCheckDate: Date?
	private var lastTaskStartDate = 0
	private var asyncTaskPid: pid_t?
	
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
	}
	
	public override func getClassName() -> String {
		
		return String(self)
	}
	
	public override func forStart() {
		
		self.logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "MYSQL extension registered!")
		self.lastCheckDate = Date()
	}
	
	public override func inLoop() {
		
		if(lastCheckDate != nil) {
			
			let currentDate = Int(Date().timeIntervalSince1970)
			let lastCheckDif = currentDate - Int(lastCheckDate!.timeIntervalSince1970)
			
			if(lastCheckDif >= self.checkingFrequency) {
				
				if(!self.checkMysqlProcess()) {
					
					self.restartMysql()
				}
			}
		}else{
			
			self.lastCheckDate = Date()
		}
	}
	
	public override func forAsyncTask() {
		
		if(self.taskStatus == 0) {
			
			self.taskStatus = 1
			self.lastTaskStartDate = Int(Date().timeIntervalSince1970)
			
			if let processStopCommand = moduleConfig?["ProcessStopCommand"] {
				
				self.lastTask = self.executeTask(command: processStopCommand)
			}
			
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
				
				if let processStartCommand = moduleConfig?["ProcessStartCommand"] {
					
					self.lastTask = self.executeTask(command: processStartCommand)
				}
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
			
			var loopStatus = true
			repeat {
				
				let curDate = Int(Date().timeIntervalSince1970)
				let startDif = curDate - self.lastTaskStartDate
				
				if(startDif > taskTimeout) {
					
					self.taskStatus = 0
					loopStatus = false
					break
				}
				
				usleep(300000)
				
				if(self.taskStatus == 0) {
					
					loopStatus = false
				}else{
					
					self.forAsyncTask()
				}
				
			} while (loopStatus)
		}
	}
	
	private func checkMysqlProcess() -> Bool {
		
		if let currentProcessName = moduleConfig?["ProcessName"] {
			
			self.processStatus = self.checkProcess(processName: currentProcessName)
			self.lastCheckDate = Date()
			if(self.processStatus.count > 0) {
				
				return true
			}else{
				
				self.logger.writeLog(level: Logger.LogLevels.ERROR, message: "Warning Process MYSQL does not working!")
				return false
			}
		}
		
		return true
	}
	
	private func restartMysql() {
		
		self.logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Restarting MYSQL")
		
		if(self.asyncTaskPid == nil) {
			
			self.asyncTaskPid = self.startAsyncTask(command: "self", extraEnv: nil, extensionName: self.getClassName())
		}else{
			
			self.logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Async task already started")
			if(kill(self.asyncTaskPid!, 0) != 0) {
				
				self.logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Async task already started but does not work!")
				self.asyncTaskPid = nil
				self.restartMysql()
			}
		}
	}
}


