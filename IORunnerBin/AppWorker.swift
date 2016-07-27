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
	
	enum AppWorkerError: ErrorProtocol {
		case StdRedirectFailed
		case DaemonizeFailed
		case PidFileIsNotWritable
		case PidFileExists
	}
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
				
				var procPid = pid_t()
				let argumets = Process.arguments
			#if swift(>=3)
					
				let cArgs = UnsafeMutablePointer<maybeCChar?>(allocatingCapacity: 7)
				defer {
					cArgs.deinitialize(count: 7)
					cArgs.deallocateCapacity(7)
				}
			#else
				
				let cArgs = UnsafeMutablePointer<maybeCChar>.alloc(7)
				defer {
					cArgs.dealloc(7)
					cArgs.destroy(7)
				}
			#endif
			
				cArgs[0] = strdup(Process.arguments[0])
				cArgs[1] = strdup("--config")
				cArgs[2] = strdup(appArguments.config!)
				cArgs[3] = strdup("--onlyusearguments")
				cArgs[4] = strdup("--signal")
				cArgs[5] = strdup("environ")
			#if swift(>=3)
				
				cArgs[6] = UnsafeMutablePointer<CChar>(nil)!
				
			#if os(Linux)
				var environments = NSProcessInfo().environment
			#else
				var environments = ProcessInfo().environment
			#endif
				environments["IO_RUNNER_SN"] = "child-start"
				let cEnv = UnsafeMutablePointer<maybeCChar?>(allocatingCapacity: environments.count + 1)
				
				defer {
					cEnv.deinitialize(count: environments.count + 1)
					cEnv.deallocateCapacity(environments.count + 1)
				}
				cEnv[environments.count] = UnsafeMutablePointer<CChar>(nil)!
			#else
				
				cArgs[6] = UnsafeMutablePointer<CChar>(nil)
				
				var environments = NSProcessInfo().environment
				environments["IO_RUNNER_SN"] = "child-start"
				let cEnv = UnsafeMutablePointer<maybeCChar>.alloc(environments.count + 1)
				
				defer {
					cEnv.dealloc( environments.count + 1)
					cEnv.destroy(environments.count + 1)
				}
				cEnv[environments.count] = UnsafeMutablePointer<CChar>(nil)
			#endif

			
				var idx = 0
				for environmentData in environments {
				
					cEnv[idx] = strdup(environmentData.0 + "=" + environmentData.1)
					idx += 1
				}
			
				var fSTDIN: [Int32] = [0, 0]
				var fSTDOUT: [Int32] = [0, 0]
				var fSTDERR: [Int32] = [0, 0]
			
				pipe(UnsafeMutablePointer<Int32>(fSTDIN))
				pipe(UnsafeMutablePointer<Int32>(fSTDOUT))
				pipe(UnsafeMutablePointer<Int32>(fSTDERR))
				#if os(Linux)
					var fileActions = posix_spawn_file_actions_t()
				#else
					var fileActions = posix_spawn_file_actions_t(nil)
				#endif
			
				posix_spawn_file_actions_init(&fileActions);
				posix_spawn_file_actions_adddup2(&fileActions, fSTDOUT[1], STDOUT_FILENO);
				posix_spawn_file_actions_adddup2(&fileActions, fSTDIN[0], STDIN_FILENO);
				posix_spawn_file_actions_adddup2(&fileActions, fSTDERR[1], STDERR_FILENO);
			
				posix_spawn_file_actions_addclose(&fileActions, fSTDOUT[0]);
				posix_spawn_file_actions_addclose(&fileActions, fSTDIN[0]);
				posix_spawn_file_actions_addclose(&fileActions, fSTDERR[0]);
				posix_spawn_file_actions_addclose(&fileActions, fSTDOUT[1]);
				posix_spawn_file_actions_addclose(&fileActions, fSTDIN[1]);
				posix_spawn_file_actions_addclose(&fileActions, fSTDERR[1]);
			
				let spawnRes = posix_spawnp(&procPid, argumets[0], &fileActions, nil, cArgs, cEnv)
			
				switch spawnRes {
				case EINVAL:
				#if swift(>=3)
					
					logger.writeLog(level: Logger.LogLevels.ERROR, message: "The value specified by file_actions or attrp is invalid.")
				#elseif swift(>=2.2) && os(OSX)
					
					logger.writeLog(Logger.LogLevels.ERROR, message: "The value specified by file_actions or attrp is invalid.")
				#endif
					break
				case E2BIG:
				#if swift(>=3)
					
					logger.writeLog(level: Logger.LogLevels.ERROR, message: "The number of bytes in the new process's argument list is larger than the system-imposed limit.")
				#elseif swift(>=2.2) && os(OSX)
					
					logger.writeLog(Logger.LogLevels.ERROR, message: "The number of bytes in the new process's argument list is larger than the system-imposed limit.")
				#endif
					break
				case EACCES:
				#if swift(>=3)
					
					logger.writeLog(level: Logger.LogLevels.ERROR, message: "The new process file mode denies execute permission.")
				#elseif swift(>=2.2) && os(OSX)
					
					logger.writeLog(Logger.LogLevels.ERROR, message: "The new process file mode denies execute permission.")
				#endif
					break
				case EFAULT:
				#if swift(>=3)
					
					logger.writeLog(level: Logger.LogLevels.ERROR, message: "Path, argv, or envp point to an illegal address.")
				#elseif swift(>=2.2) && os(OSX)
					
					logger.writeLog(Logger.LogLevels.ERROR, message: "Path, argv, or envp point to an illegal address.")
				#endif
					break
				case EIO:
				#if swift(>=3)
					
					logger.writeLog(level: Logger.LogLevels.ERROR, message: " An I/O error occurred while reading from the file system.")
				#elseif swift(>=2.2) && os(OSX)
					
					logger.writeLog(Logger.LogLevels.ERROR, message: " An I/O error occurred while reading from the file system.")
				#endif
					break
				case ELOOP:
				#if swift(>=3)
					
					logger.writeLog(level: Logger.LogLevels.ERROR, message: "Too many symbolic links were encountered in translating the pathname.  This is taken to be indicative of a looping symbolic link.")
				#elseif swift(>=2.2) && os(OSX)
					
					logger.writeLog(Logger.LogLevels.ERROR, message: "Too many symbolic links were encountered in translating the pathname.  This is taken to be indicative of a looping symbolic link.")
				#endif
					break
				case ENAMETOOLONG:
				#if swift(>=3)
					
					logger.writeLog(level: Logger.LogLevels.ERROR, message: "A component of a pathname exceeded {NAME_MAX} characters, or an entire path name exceeded {PATH_MAX} characters.")
				#elseif swift(>=2.2) && os(OSX)
					
					logger.writeLog(Logger.LogLevels.ERROR, message: "A component of a pathname exceeded {NAME_MAX} characters, or an entire path name exceeded {PATH_MAX} characters.")
				#endif
					break
				case ENOEXEC, ENOENT:
				#if swift(>=3)
					
					logger.writeLog(level: Logger.LogLevels.ERROR, message: "The new process file does not exist.")
				#elseif swift(>=2.2) && os(OSX)
					
					logger.writeLog(Logger.LogLevels.ERROR, message: "The new process file does not exist.")
				#endif
					break
				case ENOMEM:
				#if swift(>=3)
					
					logger.writeLog(level: Logger.LogLevels.ERROR, message: "The new process requires more virtual memory than is allowed by the imposed maximum")
				#elseif swift(>=2.2) && os(OSX)
					
					logger.writeLog(Logger.LogLevels.ERROR, message: "The new process requires more virtual memory than is allowed by the imposed maximum")
				#endif
					break
				case ENOTDIR:
				#if swift(>=3)
					
					logger.writeLog(level: Logger.LogLevels.ERROR, message: "A component of the path prefix is not a directory.")
				#elseif swift(>=2.2) && os(OSX)
					
					logger.writeLog(Logger.LogLevels.ERROR, message: "A component of the path prefix is not a directory.")
				#endif
					break
				case ETXTBSY:
				#if swift(>=3)
					
					logger.writeLog(level: Logger.LogLevels.ERROR, message: "The new process file is a pure procedure (shared text) file that is currently open for writing or reading by some process.")
				#elseif swift(>=2.2) && os(OSX)
					
					logger.writeLog(Logger.LogLevels.ERROR, message: "The new process file is a pure procedure (shared text) file that is currently open for writing or reading by some process.")
				#endif
					break
				default:
					break
				}
			
				#if os(Linux)
					_ = Glibc.close(fSTDIN[0])
					_ = Glibc.close(fSTDOUT[1])
					_ = Glibc.close(fSTDERR[1])
					if spawnRes != 0 {
						_ = Glibc.close(fSTDIN[1])
						_ = Glibc.close(fSTDOUT[0])
						_ = Glibc.close(fSTDERR[0])
						throw AppWorkerError.DaemonizeFailed
					}
				#else
					_ = Darwin.close(fSTDIN[0])
					_ = Darwin.close(fSTDOUT[1])
					_ = Darwin.close(fSTDERR[1])
					if spawnRes != 0 {
						_ = Darwin.close(fSTDIN[1])
						_ = Darwin.close(fSTDOUT[0])
						_ = Darwin.close(fSTDERR[0])
						throw AppWorkerError.DaemonizeFailed
					}
				#endif
				
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
	
	/*func handleChild() {
		while true {
			var stat: Int32 = 0
			let pid = waitpid(-1, &stat, WNOHANG)
			if pid == -1 {
				break
			}
			
			workers.removeValueForKey(pid)
		}
		
		manageWorkers()
	}*/
	
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
		
	#if os (Linux)
		let pidFileExists = NSFileManager.defaultManager().fileExists(atPath: pidFile)
	#else
		let pidFileExists = FileManager.default().fileExists(atPath: pidFile)
	#endif
		if(pidFileExists) {
			
		#if os (Linux)
			let pidFileDescriptor = NSFileHandle(forReadingAtPath: pidFile)
		#else
			let pidFileDescriptor = FileHandle(forReadingAtPath: pidFile)
		#endif
			if(pidFileDescriptor == nil) {
				
				return -1
			}else{
				
			#if os (Linux)
				pidFileDescriptor?.seekToFileOffset(0)
			#else
				pidFileDescriptor?.seek(toFileOffset: 0)
			#endif
				
				if let pidData = pidFileDescriptor?.readDataToEndOfFile() {
					
				#if os (Linux)
					let pidStr = String(data: pidData, encoding: NSUTF8StringEncoding)
				#else
					let pidStr = String(data: pidData, encoding: String.Encoding.utf8)
				#endif
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
	
	private func setChildProcessPid(pid: Int32) throws {
		
	#if swift(>=3)
		
	#if os (Linux)
		let pidFileExists = NSFileManager.defaultManager().fileExists(atPath: pidFile)
	#else
		let pidFileExists = FileManager.default().fileExists(atPath: pidFile)
	#endif
		if(pidFileExists) {
			
			kill(pid, SIGINT)
			throw AppWorkerError.PidFileExists
		}else{
		
		#if os (Linux)
			let createStatus = NSFileManager.defaultManager().createFile(atPath: pidFile, contents: nil, attributes: nil)
		#else
			let createStatus = FileManager.default().createFile(atPath: pidFile, contents: nil, attributes: nil)
		#endif
			if(!createStatus) {
				
				kill(pid, SIGINT)
				throw AppWorkerError.PidFileIsNotWritable
			}
			
		#if os (Linux)
			let pidFileDescriptor = NSFileHandle(forWritingAtPath: pidFile)
		#else
			let pidFileDescriptor = FileHandle(forWritingAtPath: pidFile)
		#endif
			if(pidFileDescriptor == nil) {
				kill(pid, SIGINT)
				throw AppWorkerError.PidFileIsNotWritable
			}else{
				
				logger.writeLog(level: Logger.LogLevels.ERROR, message: "Pid file created")
				let pidStr = "\(pid)"
				
			#if os (Linux)
				pidFileDescriptor?.writeData(pidStr.data(using: NSUTF8StringEncoding)!)
			#else
				pidFileDescriptor?.write(pidStr.data(using: String.Encoding.utf8)!)
			#endif
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
		
	#if os(Linux)
		
		let runLoop = NSRunLoop.currentRunLoop()
		repeat {
			let _ = signalHandler.process()
			currentHandlers.forEach { $0.inLoop() }
			usleep(Constants.CpuSleepSec)
			
			
		} while (running && runLoop.runMode(NSDefaultRunLoopMode, beforeDate: NSDate().addingTimeInterval(-1 * Constants.CpuSleepMsec)))
	#else
		
		let runLoop = RunLoop.current()
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
	
	private func deletePid() {
		
	#if swift(>=3)
	#if os(Linux)
		if(NSFileManager.defaultManager().fileExists(atPath: pidFile)) {
			
			do {
				
				try NSFileManager.defaultManager().removeItem(atPath: pidFile)
			} catch _ {
				
				logger.writeLog(level: Logger.LogLevels.ERROR, message: "Could not delete pid file!")
			}
		}else{
			
			logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Pid file does not exists!")
		}
	#else
		if(FileManager.default().fileExists(atPath: pidFile)) {
			
			do {
			
				try FileManager.default().removeItem(atPath: pidFile)
			} catch _ {
				
				logger.writeLog(level: Logger.LogLevels.ERROR, message: "Could not delete pid file!")
			}
		}else{
			
			logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Pid file does not exists!")
		}
	#endif
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
}
