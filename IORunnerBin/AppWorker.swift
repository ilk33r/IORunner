//
//  AppWorker.swift
//  IORunner
//
//  Created by ilker özcan on 04/07/16.
//
//

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif

import Foundation
import IORunnerExtension

typealias maybeCChar = UnsafeMutablePointer<CChar>

internal final class AppWorker {
	
	private var signalHandler: SignalHandler!
	private var running = false
	private var currentHandlers: [AppHandlers]
	private var pidFile: String
	private var logger: Logger
	private var appArguments: Arguments
	private var childProcessPid: Int32 = -1

#if swift(>=3)
#if os(Linux)
	enum AppWorkerError: Error {
		case StdRedirectFailed
		case DaemonizeFailed
		case PidFileIsNotWritable
		case PidFileExists
	}
#else
	enum AppWorkerError: ErrorProtocol {
		case StdRedirectFailed
		case DaemonizeFailed
		case PidFileIsNotWritable
		case PidFileExists
	}
#endif
#elseif swift(>=2.2) && os(OSX)
	
	enum AppWorkerError: ErrorType {
		case StdRedirectFailed
		case DaemonizeFailed
		case PidFileIsNotWritable
		case PidFileExists
	}
#endif
	
	init(handlers: [AppHandlers], pidFile: String, logger: Logger, appArguments: Arguments) {
		
		self.currentHandlers = handlers
		self.pidFile = pidFile
		self.logger = logger
		self.appArguments = appArguments
		childProcessPid = self.checkPid()
		
	#if swift(>=3)
		
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Worker will start with \(currentHandlers.count) handlers!")
	#elseif swift(>=2.2) && os(OSX)
		
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Worker will start with \(currentHandlers.count) handlers!")
	#endif
	}
	
	func registerSignals() {
		signalHandler = SignalHandler()
	#if swift(>=3)
		
		signalHandler.register(signal: .Interrupt, handleINT)
		signalHandler.register(signal: .Quit, handleQUIT)
		signalHandler.register(signal: .Terminate, handleTerminate)
		SignalHandler.registerSignals()

		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Signals registered")
	#elseif swift(>=2.2) && os(OSX)
		
		signalHandler.register(.Interrupt, handleINT)
		signalHandler.register(.Quit, handleQUIT)
		signalHandler.register(.Terminate, handleTerminate)
		SignalHandler.registerSignals()
		
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Signals registered")
	#endif
	}

	func run(daemonize: Bool, isChildProcess: Bool) throws {
		
		if(isChildProcess) {
			
			registerSignals()
			running = true
			currentHandlers.forEach { $0.forStart() }
			startLoop()
			
		}else{
			
			if daemonize {
				
				var processConfig = ProcessConfigData()
				processConfig.ProcessArgs = [Process.arguments[0], "--config", appArguments.config!, "--onlyusearguments", "--signal", "environ"]
				processConfig.Environments = [("IO_RUNNER_SN", "child-start")]
				
				var procPid: pid_t! = 0
				do {
					
				#if swift(>=3)
					procPid = try SpawnCurrentProcess(logger: self.logger, configData: processConfig)
				#elseif swift(>=2.2) && os(OSX)
					procPid = try SpawnCurrentProcess(self.logger, configData: processConfig)
				#endif
				} catch _ {
					throw AppWorkerError.DaemonizeFailed
				}
				
			#if swift(>=3)
				
				logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Application running with daemonize.")
				try setChildProcessPid(pid: procPid)
			#elseif swift(>=2.2) && os(OSX)
				
				logger.writeLog(Logger.LogLevels.WARNINGS, message: "Application running with daemonize.")
				try setChildProcessPid(procPid)
			#endif
				
			}else{

			#if swift(>=3)
				
				logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Application running without daemonize.")
			#elseif swift(>=2.2) && os(OSX)
				
				logger.writeLog(Logger.LogLevels.WARNINGS, message: "Application running without daemonize.")
			#endif
				
				registerSignals()
				running = true
				currentHandlers.forEach { $0.forStart() }
				startLoop()
			}
		}
	}
	
	func stop(graceful: Bool = true) {
		
	#if swift(>=3)
			
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Stop called! graceful: \(graceful)")
		currentHandlers.forEach { $0.forStop() }
		
		if graceful {
			killWorkers(signal: SIGTERM)
		} else {
			killWorkers(signal: SIGQUIT)
		}
	#elseif swift(>=2.2) && os(OSX)
		
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Stop called! graceful: \(graceful)")
		currentHandlers.forEach { $0.forStop() }
		if graceful {
			killWorkers(SIGTERM)
		} else {
			killWorkers(SIGQUIT)
		}
	#endif
	}

	// MARK: Handle Signals
	
	func handleINT() {
	#if swift(>=3)
		
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Signal INT received")
		stop(graceful: false)
	#elseif swift(>=2.2) && os(OSX)
		
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Signal INT received")
		stop(false)
	#endif
		running = false
	}
	
	func handleQUIT() {
	#if swift(>=3)
		
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Signal QUIT received")
		stop(graceful: false)
	#elseif swift(>=2.2) && os(OSX)
		
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Signal QUIT received")
		stop(false)
	#endif
		running = false
	}
	
	func handleTerminate() {
	#if swift(>=3)
		
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Signal TERMINATE received")
	#elseif swift(>=2.2) && os(OSX)
		
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Signal TERMINATE received")
	#endif
		currentHandlers.forEach { $0.forStop() }
		running = false
	}
	
	// MARK: Worker
	// Kill all workers with given signal
	func killWorkers(signal: Int32) {
		
	#if swift(>=3)
		
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Killing workers with signal: \(signal)")
	#elseif swift(>=2.2) && os(OSX)
		
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Killing workers with signal: \(signal)")
	#endif
		if(childProcessPid == -1) {
			deletePid()
			running = false
			return
		}
		
		if(kill(childProcessPid, signal) == 0) {
			childProcessPid = -1
			deletePid()
		}else{
		#if swift(>=3)
			
			logger.writeLog(level: Logger.LogLevels.MINIMAL, message: "Process already dead! Removing pid file")
		#elseif swift(>=2.2) && os(OSX)
			
			logger.writeLog(Logger.LogLevels.MINIMAL, message: "Process already dead! Removing pid file")
		#endif
			deletePid()
		}
	}
	
	// MARK: Pid
	func checkPid() -> Int32 {
		
	#if swift(>=3)
		
		let pidFileExists = FileManager.default().fileExists(atPath: pidFile)
		if(pidFileExists) {
			
			let pidFileDescriptor = FileHandle(forReadingAtPath: pidFile)
			if(pidFileDescriptor == nil) {
				
				return -1
			}else{
				
				pidFileDescriptor?.seek(toFileOffset: 0)
				
				if let pidData = pidFileDescriptor?.readDataToEndOfFile() {
					
					let pidStr = String(data: pidData, encoding: String.Encoding.utf8)
					pidFileDescriptor?.closeFile()
					
					if let pidVal = Int32(pidStr!) {
						return pidVal
					}else{
						return -1
					}
				}else{
					return -1
				}
			}
		}else{
			return -1
		}
	#elseif swift(>=2.2) && os(OSX)
		
		if(NSFileManager.defaultManager().fileExistsAtPath(pidFile)) {
			
			let pidFileDescriptor = NSFileHandle(forReadingAtPath: pidFile)
			if(pidFileDescriptor == nil) {
				return -1
			}else{
				pidFileDescriptor?.seekToFileOffset(0)
				if let pidData = pidFileDescriptor?.readDataToEndOfFile() {
					
					let pidStr = String(data: pidData, encoding: NSUTF8StringEncoding)
					pidFileDescriptor?.closeFile()
					
					if let pidVal = Int32(pidStr!) {
						return pidVal
					}else{
						return -1
					}
				}else{
					return -1
				}
			}
		}else{
			return -1
		}
	#endif
	}
	
	func setChildProcessPid(pid: Int32) throws {
		
	#if swift(>=3)
		
		let pidFileExists = FileManager.default().fileExists(atPath: pidFile)
		if(pidFileExists) {
			
			kill(pid, SIGINT)
			throw AppWorkerError.PidFileExists
		}else{
		
			let createStatus = FileManager.default().createFile(atPath: pidFile, contents: nil, attributes: nil)
			if(!createStatus) {
				
				kill(pid, SIGINT)
				throw AppWorkerError.PidFileIsNotWritable
			}
			
			let pidFileDescriptor = FileHandle(forWritingAtPath: pidFile)
			if(pidFileDescriptor == nil) {
				kill(pid, SIGINT)
				throw AppWorkerError.PidFileIsNotWritable
			}else{
				
				logger.writeLog(level: Logger.LogLevels.ERROR, message: "Pid file created")
				let pidStr = "\(pid)"
				
				pidFileDescriptor?.write(pidStr.data(using: String.Encoding.utf8)!)
				pidFileDescriptor?.closeFile()
				childProcessPid = pid
			}
		}
	#elseif swift(>=2.2) && os(OSX)
		
		if(NSFileManager.defaultManager().fileExistsAtPath(pidFile)) {
			kill(pid, SIGINT)
			throw AppWorkerError.PidFileExists
		}else{
			
			let createStatus = NSFileManager.defaultManager().createFileAtPath(pidFile, contents: nil, attributes: nil)
			if(!createStatus) {
				kill(pid, SIGINT)
				throw AppWorkerError.PidFileIsNotWritable
			}
			
			let pidFileDescriptor = NSFileHandle(forWritingAtPath: pidFile)
			if(pidFileDescriptor == nil) {
				kill(pid, SIGINT)
				throw AppWorkerError.PidFileIsNotWritable
			}else{
				logger.writeLog(Logger.LogLevels.ERROR, message: "Pid file created")
				let pidStr = "\(pid)"
				
				pidFileDescriptor?.writeData(pidStr.dataUsingEncoding(NSUTF8StringEncoding)!)
				pidFileDescriptor?.closeFile()
				childProcessPid = pid
			}
		}
	#endif
	}
	
	// MARK: Loop
	private func startLoop() {
		
	#if swift(>=3)
		
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Child process will be start \(running)")
		let runLoop = RunLoop.current()
		
	#if os(Linux)
		
		repeat {
			let _ = signalHandler.process()
			currentHandlers.forEach { $0.inLoop() }
			usleep(Constants.CpuSleepSec)
			let _ = runLoop.run(mode: RunLoopMode.defaultRunLoopMode, before: NSDate().addingTimeInterval(-1 * Constants.CpuSleepMsec))
			
		} while (running)
		
	#else
		
		repeat {
			let _ = signalHandler.process()
			currentHandlers.forEach { $0.inLoop() }
			usleep(Constants.CpuSleepSec)
		
		
		} while (running && runLoop.run(mode: RunLoopMode.defaultRunLoopMode, before: Date().addingTimeInterval(-1 * Constants.CpuSleepMsec)))
		
	#endif
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Child process will be stop \(running)")
	#else
			
		
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Child process will be start \(running)")
		
		let runLoop = NSRunLoop.currentRunLoop()
		repeat {
			let _ = signalHandler.process()
			currentHandlers.forEach { $0.inLoop() }
			usleep(Constants.CpuSleepSec)
		
		} while (running && runLoop.runMode(NSDefaultRunLoopMode, beforeDate: NSDate().dateByAddingTimeInterval(-1 * Constants.CpuSleepMsec)))

		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Child process will be stop \(running)")
	#endif
	}
	
	func deletePid() {
		
	#if swift(>=3)

		if(FileManager.default().fileExists(atPath: pidFile)) {
			
			do {
			
				try FileManager.default().removeItem(atPath: pidFile)
			} catch _ {
				
				logger.writeLog(level: Logger.LogLevels.ERROR, message: "Could not delete pid file!")
			}
		}else{
			
			logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Pid file does not exists!")
		}

	#elseif swift(>=2.2) && os(OSX)

		if(NSFileManager.defaultManager().fileExistsAtPath(pidFile)) {
		
			do {

				try NSFileManager.defaultManager().removeItemAtPath(pidFile)
			} catch _ {
				
				logger.writeLog(Logger.LogLevels.ERROR, message: "Could not delete pid file!")
			}
		}else{
		
			logger.writeLog(Logger.LogLevels.WARNINGS, message: "Pid file does not exists!")
		}
	#endif
	}
	
	func runExtension(extensionName: String) {
		
		for currentHandler in self.currentHandlers {
			
			if(currentHandler.getClassName() == extensionName) {
				
				currentHandler.forAsyncTask()
				break
			}
		}
	}
}
