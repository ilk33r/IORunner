//
//  BouncyHandler.swift
//  IORunner/Extensions/BouncyHandler
//
//  Created by ilker özcan on 10/08/16.
//
//

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif

import Foundation
import IOIni
import IORunnerExtension

public class BouncyHandler: AppHandlers {
	
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
	private var jobServerAsyncTaskPid: pid_t?
	private var pushServerAsyncTaskPid: pid_t?
	private var jobServerAsyncTaskStartTime: UInt = 0
	private var pushServerAsyncTaskStartTime: UInt = 0
	
	private struct JobserverCommand {
		
		private var _server: String
		private var _pid: String
		private var _log: String
		private var _db: String
		private var _sock: String
		private var _videos: String
		
		var Command: String {
			
			get {
				return _server
			}
		}
		
		var PidFile: String {
			
			get {
				return _pid
			}
		}
		
		var LogFile: String {
			
			get {
				return _log
			}
		}
		
		var DBFile: String {
			
			get {
				return _db
			}
		}
		
		var SockFile: String {
			
			get {
				return _sock
			}
		}
		
		var VideosFile: String {
			
			get {
				return _videos
			}
		}
		
		init(ServerCommand: String, PidFile: String, LogFile: String, DBFile: String, Socket: String, VideosFolder: String) {
			
			self._server = ServerCommand
			self._pid = PidFile
			self._log = LogFile
			self._db = DBFile
			self._sock = Socket
			self._videos = VideosFolder
		}
	}
	private var jobServerSettings: JobserverCommand?
	
	private struct PushserverCommand {
		
		private var _server: String
		private var _pid: String
		private var _log: String
		private var _dbHost: String
		private var _dbUser: String
		private var _dbPassword: String
		private var _dbName: String
		
		var Command: String {
			
			get {
				return _server
			}
		}
		
		var PidFile: String {
			
			get {
				return _pid
			}
		}
		
		var LogFile: String {
			
			get {
				return _log
			}
		}
		
		var DBHost: String {
			
			get {
				return _dbHost
			}
		}
		
		var DBUser: String {
			
			get {
				return _dbUser
			}
		}
		
		var DBPassword: String {
			
			get {
				return _dbPassword
			}
		}
		
		var DBName: String {
			
			get {
				return _dbName
			}
		}
		
		init(ServerCommand: String, PidFile: String, LogFile: String,
		     DBHost: String, DBUser: String, DBPassword: String, DBName: String) {
			
			self._server = ServerCommand
			self._pid = PidFile
			self._log = LogFile
			self._dbHost = DBHost
			self._dbUser = DBUser
			self._dbPassword = DBPassword
			self._dbName = DBName
		}
	}
	private var pushServerSettings: PushserverCommand?
	
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
		
		self.generateJobServerSettings()
		self.generatePushServerSettings()
	}
	
	public override func getClassName() -> String {
		
		return String(describing: self)
	}
	
	private func generateJobServerSettings() {
		
		guard moduleConfig != nil else {
			return
		}
		
		let processCommand = moduleConfig!["JobServer"]
		guard processCommand != nil else {
			
			return
		}
		
		let processPidFile = moduleConfig!["JobServerPidFile"]
		guard processPidFile != nil else {
			
			return
		}
		
		let processLogFile = moduleConfig!["JobServerLogFile"]
		guard processLogFile != nil else {
			
			return
		}
		
		let processDBFile = moduleConfig!["JobServerDBFile"]
		guard processDBFile != nil else {
			
			return
		}
		
		let processSockFile = moduleConfig!["JobServerSockFile"]
		guard processSockFile != nil else {
			
			return
		}
		
		let processVideosFile = moduleConfig!["JobServerVideosFile"]
		guard processVideosFile != nil else {
			
			return
		}
		
		self.jobServerSettings = JobserverCommand(ServerCommand: processCommand!, PidFile: processPidFile!, LogFile: processLogFile!, DBFile: processDBFile!, Socket: processSockFile!, VideosFolder: processVideosFile!)
	}
	
	private func generatePushServerSettings() {
		
		guard moduleConfig != nil else {
			return
		}
		
		let processCommand = moduleConfig!["PushServer"]
		guard processCommand != nil else {
			
			return
		}
		
		let processPidFile = moduleConfig!["PushServerPidFile"]
		guard processPidFile != nil else {
			
			return
		}
		
		let processLogFile = moduleConfig!["PushServerLogFile"]
		guard processLogFile != nil else {
			
			return
		}
		
		let processDBHost = moduleConfig!["PushServerDBHost"]
		guard processDBHost != nil else {
			
			return
		}
		
		let processDBUser = moduleConfig!["PushServerDBUser"]
		guard processDBUser != nil else {
			
			return
		}
		
		let processDBPassword = moduleConfig!["PushServerDBPassword"]
		guard processDBPassword != nil else {
			
			return
		}
		
		let processDBName = moduleConfig!["PushServerDBName"]
		guard processDBName != nil else {
			
			return
		}
		
		self.pushServerSettings = PushserverCommand(ServerCommand: processCommand!, PidFile: processPidFile!, LogFile: processLogFile!, DBHost: processDBHost!, DBUser: processDBUser!, DBPassword: processDBPassword!, DBName: processDBName!)
	}
	
	public override func forStart() {
		
		self.logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "BOUNCY extension registered!")
		self.lastCheckDate = Date()
	}
	
	public override func inLoop() {
		
		if(lastCheckDate != nil) {
			
			let currentDate = Int(Date().timeIntervalSince1970)
			let lastCheckDif = currentDate - Int(lastCheckDate!.timeIntervalSince1970)
			
			if(lastCheckDif >= self.checkingFrequency) {
				
				if(!self.checkJobServerProcess()) {
					
					self.restartJobServer()
				}
				
				if(self.jobServerAsyncTaskPid != nil) {
					
					self.waitJobServerAsyncTask()
				}
				
				if(!self.checkPushServerProcess()) {
					
					self.restartPushServer()
				}
				
				if(self.pushServerAsyncTaskPid != nil) {
					
					self.waitPushServerAsyncTask()
				}
				
				self.lastCheckDate = Date()
			}
		}else{
			
			self.lastCheckDate = Date()
		}
	}
	
	private func getServerStopCommand() -> (String, [String])? {
		
	#if os(Linux)
		let environments = ProcessInfo.processInfo().environment
	#else
		let environments = ProcessInfo().environment
	#endif
		
		if let envType = environments["IO_RUNNER_EX_BOUNCY"] {
			
			if(envType == "JOBSERVER") {
				
				let procStopArgs: [String] = [ "stop", "-p", self.jobServerSettings!.PidFile ]
				return (self.jobServerSettings!.Command, procStopArgs)
				
			}else if(envType == "PUSHSERVER") {
				
				let procStopArgs: [String] = [ "stop", "-p", self.pushServerSettings!.PidFile ]
				return (self.pushServerSettings!.Command, procStopArgs)
			}
			
			return nil
		}else{
			return nil
		}
	}
	
	private func getServerStartCommand() -> (String, [String])? {
		
	#if os(Linux)
		let environments = ProcessInfo.processInfo().environment
	#else
		let environments = ProcessInfo().environment
	#endif
		
		if let envType = environments["IO_RUNNER_EX_BOUNCY"] {
			
			if(envType == "JOBSERVER") {
				
				let procStartArgs: [String] = [
					"start",
					"-p",
					self.jobServerSettings!.PidFile,
					"-l",
					self.jobServerSettings!.LogFile,
					"-j",
					self.jobServerSettings!.DBFile,
					"-s",
					self.jobServerSettings!.SockFile,
					"-v",
					self.jobServerSettings!.VideosFile
				]
				return (self.jobServerSettings!.Command, procStartArgs)
				
			}else if(envType == "PUSHSERVER") {
				
				let procStartArgs: [String] = [
					"start",
					"-l",
					self.pushServerSettings!.LogFile,
					"-p",
					self.pushServerSettings!.PidFile,
					"-mh",
					self.pushServerSettings!.DBHost,
					"-mu",
					self.pushServerSettings!.DBUser,
					"-mp",
					self.pushServerSettings!.DBPassword,
					"-md",
					self.pushServerSettings!.DBName
				]
				return (self.pushServerSettings!.Command, procStartArgs)
			}
			
			return nil
		}else{
			return nil
		}
	}
	
	public override func forAsyncTask() {
		
		if(self.taskStatus == 0) {
			
			self.taskStatus = 1
			self.lastTaskStartDate = Int(Date().timeIntervalSince1970)
			
			if let processStopCommand = getServerStopCommand() {
				
				let _ = self.executeTaskWithPipe(command: processStopCommand.0, args: processStopCommand.1, withAsync: true)
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
				
				if let processStartCommand = getServerStartCommand() {
					
					let _ = executeTaskWithPipe(command: processStartCommand.0, args: processStartCommand.1, withAsync: true)
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
	
	private func checkJobServerProcess() -> Bool {
		
		guard self.jobServerSettings != nil else {
			return true
		}
		
		let procArgs: [String] = [ "status", "-p", self.jobServerSettings!.PidFile ]
		if let response = self.executeTaskWithPipe(command: self.jobServerSettings!.Command, args: procArgs, withAsync: false) {
			
			let strippedResponse = response.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
			if let integerResponse = Int(strippedResponse) {
				
				if(integerResponse == 200) {
					return true
				}else{
					
					self.logger.writeLog(level: Logger.LogLevels.ERROR, message: "JOB SERVER is not running...")
					return false
				}
			}
		}
		
		return false
	}
	
	private func checkPushServerProcess() -> Bool {
		
		guard self.pushServerSettings != nil else {
			return true
		}
		
		let procArgs: [String] = [ "status", "-p", self.pushServerSettings!.PidFile ]
		if let response = self.executeTaskWithPipe(command: self.pushServerSettings!.Command, args: procArgs, withAsync: false) {
			
			let strippedResponse = response.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
			if let integerResponse = Int(strippedResponse) {
				
				if(integerResponse == 200) {
					return true
				}else{
					
					self.logger.writeLog(level: Logger.LogLevels.ERROR, message: "PUSH SERVER is not running...")
					return false
				}
			}
		}
		
		return false
	}
	
	private func restartJobServer() {
		
		self.logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Restarting JOB SERVER")
		
		if(self.jobServerAsyncTaskPid == nil) {
			
			self.jobServerAsyncTaskStartTime = UInt(Date().timeIntervalSince1970)
			self.jobServerAsyncTaskPid = self.startAsyncTask(command: "self", extraEnv: [("IO_RUNNER_EX_BOUNCY", "JOBSERVER")], extensionName: self.getClassName())
		}else{
			
			self.logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "JOB SERVER Async task already started")
			if(kill(self.jobServerAsyncTaskPid!, 0) != 0) {
				
				self.logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "JOB SERVER Async task already started but does not work!")
				self.jobServerAsyncTaskPid = nil
				self.restartJobServer()
			}
		}
	}
	
	private func restartPushServer() {
		
		self.logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Restarting PUSH SERVER")
		
		if(self.pushServerAsyncTaskPid == nil) {
			
			self.pushServerAsyncTaskStartTime = UInt(Date().timeIntervalSince1970)
			self.pushServerAsyncTaskPid = self.startAsyncTask(command: "self", extraEnv: [("IO_RUNNER_EX_BOUNCY", "PUSHSERVER")], extensionName: self.getClassName())
		}else{
			
			self.logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "PUSH SERVER Async task already started")
			if(kill(self.pushServerAsyncTaskPid!, 0) != 0) {
				
				self.logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "PUSH SERVER Async task already started but does not work!")
				self.pushServerAsyncTaskPid = nil
				self.restartPushServer()
			}
		}
	}
	
	private func waitJobServerAsyncTask() {
		
		let curDate = UInt(Date().timeIntervalSince1970)
		let startDif = curDate - self.jobServerAsyncTaskStartTime
		
		if(startDif > UInt(taskTimeout + 30)) {
			
			if(kill(self.jobServerAsyncTaskPid!, 0) == 0) {
				
				var pidStatus: Int32 = 0
				waitpid(self.jobServerAsyncTaskPid!, &pidStatus, 0)
				self.jobServerAsyncTaskPid = nil
			}else{
				
				self.jobServerAsyncTaskPid = nil
			}
		}
	}
	
	private func waitPushServerAsyncTask() {
		
		let curDate = UInt(Date().timeIntervalSince1970)
		let startDif = curDate - self.pushServerAsyncTaskStartTime
		
		if(startDif > UInt(taskTimeout + 30)) {
			
			if(kill(self.pushServerAsyncTaskPid!, 0) == 0) {
				
				var pidStatus: Int32 = 0
				waitpid(self.pushServerAsyncTaskPid!, &pidStatus, 0)
				self.pushServerAsyncTaskPid = nil
			}else{
				
				self.pushServerAsyncTaskPid = nil
			}
		}
	}
	
#elseif swift(>=2.2) && os(OSX)
	public required init(logger: Logger, configFilePath: String, moduleConfig: Section?) {
	
		super.init(logger: logger, configFilePath: configFilePath, moduleConfig: moduleConfig)
		self.logger.writeLog(Logger.LogLevels.ERROR, message: "BOUNCY extension only works swift >= 3 build.")
	}
#endif
}
