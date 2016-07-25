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

/* ## Swift 3
typealias maybeCChar = UnsafeMutablePointer<CChar>?
*/
typealias maybeCChar = UnsafeMutablePointer<CChar>

internal final class AppWorker {
	
	private var signalHandler: SignalHandler!
	private var running = false
	private var currentHandlers: [AppHandlers]
	private var pidFile: String
	private var logger: Logger
	private var appArguments: Arguments
	private var childProcessPid: Int32 = -1
	
	/* ## Swift 3
	enum AppWorkerError: ErrorProtocol {
		case StdRedirectFailed
		case DaemonizeFailed
		case PidFileIsNotWritable
		case PidFileExists
	}
	*/
	enum AppWorkerError: ErrorType {
		case StdRedirectFailed
		case DaemonizeFailed
		case PidFileIsNotWritable
		case PidFileExists
	}
	
	init(handlers: [AppHandlers], pidFile: String, logger: Logger, appArguments: Arguments) {
		
		self.currentHandlers = handlers
		self.pidFile = pidFile
		self.logger = logger
		self.appArguments = appArguments
		childProcessPid = self.checkPid()
		
		/* ## Swift 3
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Worker will start with \(currentHandlers.count) handlers!")
		*/
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Worker will start with \(currentHandlers.count) handlers!")
	}
	
	func registerSignals() {
		signalHandler = SignalHandler()
		/* ## Swift 3
		signalHandler.register(signal: .Interrupt, handleINT)
		signalHandler.register(signal: .Quit, handleQUIT)
		signalHandler.register(signal: .Terminate, handleTerminate)
		SignalHandler.registerSignals()
		
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Signals registered")
		*/
		signalHandler.register(.Interrupt, handleINT)
		signalHandler.register(.Quit, handleQUIT)
		signalHandler.register(.Terminate, handleTerminate)
		SignalHandler.registerSignals()
		
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Signals registered")
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
			
				/* ## Swift 3
				let cArgs = UnsafeMutablePointer<maybeCChar>(allocatingCapacity: 7)
				*/
				let cArgs = UnsafeMutablePointer<maybeCChar>.alloc(7)
				/* ## Swift 3
				defer {
					cArgs.deinitialize(count: 7)
					cArgs.deallocateCapacity(7)
				}
				*/
				defer {
					/* ## Swift 3
					cArgs.deinitialize(count: 7)
					cArgs.deallocateCapacity(7)
					*/
					cArgs.dealloc(7)
					cArgs.destroy(7)
				}
			
				cArgs[0] = strdup(Process.arguments[0])
				cArgs[1] = strdup("--config")
				/* ## Swift 3
				cArgs[2] = strdup(appArguments.config)
				*/
				cArgs[2] = strdup(appArguments.config!)
				cArgs[3] = strdup("--onlyusearguments")
				cArgs[4] = strdup("--signal")
				cArgs[5] = strdup("environ")
				cArgs[6] = UnsafeMutablePointer<CChar>(nil)
			
				/* ## Swift 3
				var environments = ProcessInfo().environment
				*/
				var environments = NSProcessInfo().environment
				environments["IO_RUNNER_SN"] = "child-start"
			
				/* ## Swift 3
				let cEnv = UnsafeMutablePointer<maybeCChar>(allocatingCapacity: environments.count + 1)
				*/
				let cEnv = UnsafeMutablePointer<maybeCChar>.alloc(environments.count + 1)
				defer {
					/* ## Swift 3
					cEnv.deinitialize(count: environments.count + 1)
					cEnv.deallocateCapacity(environments.count + 1)
					*/
					cEnv.dealloc( environments.count + 1)
					cEnv.destroy(environments.count + 1)
				}
				cEnv[environments.count] = UnsafeMutablePointer<CChar>(nil)
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
			
				/* ## Swift 3
				let spawnRes = posix_spawnp(&procPid, argumets[0], &fileActions, nil, cArgs, cEnv)
				*/
				let spawnRes = posix_spawnp(&procPid, argumets[0], &fileActions, nil, cArgs, cEnv)
			
				switch spawnRes {
				case EINVAL:
					/* ## Swift 3
					logger.writeLog(level: Logger.LogLevels.ERROR, message: "The value specified by file_actions or attrp is invalid.")
					*/
					logger.writeLog(Logger.LogLevels.ERROR, message: "The value specified by file_actions or attrp is invalid.")
					break
				case E2BIG:
					/* ## Swift 3
					logger.writeLog(level: Logger.LogLevels.ERROR, message: "The number of bytes in the new process's argument list is larger than the system-imposed limit.")
					*/
					logger.writeLog(Logger.LogLevels.ERROR, message: "The number of bytes in the new process's argument list is larger than the system-imposed limit.")
					break
				case EACCES:
					/* ## Swift 3
					logger.writeLog(level: Logger.LogLevels.ERROR, message: "The new process file mode denies execute permission.")
					*/
					logger.writeLog(Logger.LogLevels.ERROR, message: "The new process file mode denies execute permission.")
					break
				case EFAULT:
					/* ## Swift 3
					logger.writeLog(level: Logger.LogLevels.ERROR, message: "Path, argv, or envp point to an illegal address.")
					*/
					logger.writeLog(Logger.LogLevels.ERROR, message: "Path, argv, or envp point to an illegal address.")
					break
				case EIO:
					/* ## Swift 3
					logger.writeLog(level: Logger.LogLevels.ERROR, message: " An I/O error occurred while reading from the file system.")
					*/
					logger.writeLog(Logger.LogLevels.ERROR, message: " An I/O error occurred while reading from the file system.")
					break
				case ELOOP:
					/* ## Swift 3
					logger.writeLog(level: Logger.LogLevels.ERROR, message: "Too many symbolic links were encountered in translating the pathname.  This is taken to be indicative of a looping symbolic link.")
					*/
					logger.writeLog(Logger.LogLevels.ERROR, message: "Too many symbolic links were encountered in translating the pathname.  This is taken to be indicative of a looping symbolic link.")
					break
				case ENAMETOOLONG:
					/* ## Swift 3
					logger.writeLog(level: Logger.LogLevels.ERROR, message: "A component of a pathname exceeded {NAME_MAX} characters, or an entire path name exceeded {PATH_MAX} characters.")
					*/
					logger.writeLog(Logger.LogLevels.ERROR, message: "A component of a pathname exceeded {NAME_MAX} characters, or an entire path name exceeded {PATH_MAX} characters.")
					break
				case ENOEXEC, ENOENT:
					/* ## Swift 3
					logger.writeLog(level: Logger.LogLevels.ERROR, message: "The new process file does not exist.")
					*/
					logger.writeLog(Logger.LogLevels.ERROR, message: "The new process file does not exist.")
					break
				case ENOMEM:
					/* ## Swift 3
					logger.writeLog(level: Logger.LogLevels.ERROR, message: "The new process requires more virtual memory than is allowed by the imposed maximum")
					*/
					logger.writeLog(Logger.LogLevels.ERROR, message: "The new process requires more virtual memory than is allowed by the imposed maximum")
					break
				case ENOTDIR:
					/* ## Swift 3
					logger.writeLog(level: Logger.LogLevels.ERROR, message: "A component of the path prefix is not a directory.")
					*/
					logger.writeLog(Logger.LogLevels.ERROR, message: "A component of the path prefix is not a directory.")
					break
				case ETXTBSY:
					/* ## Swift 3
					logger.writeLog(level: Logger.LogLevels.ERROR, message: "The new process file is a pure procedure (shared text) file that is currently open for writing or reading by some process.")
					*/
					logger.writeLog(Logger.LogLevels.ERROR, message: "The new process file is a pure procedure (shared text) file that is currently open for writing or reading by some process.")
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
				
				/* ## Swift 3
				logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Application running with daemonize.")
				try setChildProcessPid(pid: procPid)
				*/
				logger.writeLog(Logger.LogLevels.WARNINGS, message: "Application running with daemonize.")
				try setChildProcessPid(procPid)
				
			}else{

				/* ## Swift 3
				logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Application running without daemonize.")
				*/
				logger.writeLog(Logger.LogLevels.WARNINGS, message: "Application running without daemonize.")
				//waitpid(procPid, nil, 0)
				
				registerSignals()
				running = true
				currentHandlers.forEach { $0.forStart() }
				startLoop()
			}
		}
	}
	
	func stop(graceful: Bool = true) {
		
		/* ## Swift 3
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Stop called! graceful: \(graceful)")
		*/
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Stop called! graceful: \(graceful)")
		currentHandlers.forEach { $0.forStop() }
		
		/* ## Swift 3
		if graceful {
			killWorkers(signal: SIGTERM)
		} else {
			killWorkers(signal: SIGQUIT)
		}
		*/
		if graceful {
			killWorkers(SIGTERM)
		} else {
			killWorkers(SIGQUIT)
		}
	}
	
	// MARK: Handle Signals
	
	func handleINT() {
		/* ## Swift 3
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Signal INT received")
		stop(graceful: false)
		*/
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Signal INT received")
		stop(false)
		running = false
	}
	
	func handleQUIT() {
		/* ## Swift 3
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Signal QUIT received")
		stop(graceful: false)
		*/
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Signal QUIT received")
		stop(false)
		running = false
	}
	
	func handleTerminate() {
		/* ## Swift 3
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Signal TERMINATE received")
		*/
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Signal TERMINATE received")
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
		
		/* ## Swift 3
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Killing workers with signal: \(signal)")
		*/
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Killing workers with signal: \(signal)")
		if(childProcessPid == -1) {
			deletePid()
			running = false
			return
		}
		
		if(kill(childProcessPid, signal) == 0) {
			childProcessPid = -1
			deletePid()
		}else{
			/* ## Swift 3
			logger.writeLog(level: Logger.LogLevels.MINIMAL, message: "Process already dead! Removing pid file")
			*/
			logger.writeLog(Logger.LogLevels.MINIMAL, message: "Process already dead! Removing pid file")
			deletePid()
		}
	}
	
	// MARK: Pid
	func checkPid() -> Int32 {
		
		/* ## Swift 3
		if(FileManager.default().fileExists(atPath: pidFile)) {
		*/
		if(NSFileManager.defaultManager().fileExistsAtPath(pidFile)) {
			
			/* ## Swift 3
			let pidFileDescriptor = FileHandle(forReadingAtPath: pidFile)
			*/
			let pidFileDescriptor = NSFileHandle(forReadingAtPath: pidFile)
			if(pidFileDescriptor == nil) {
				return -1
			}else{
				/* ## Swift 3
				pidFileDescriptor?.seek(toFileOffset: 0)
				*/
				pidFileDescriptor?.seekToFileOffset(0)
				if let pidData = pidFileDescriptor?.readDataToEndOfFile() {
					
					/* ## Swift 3
					let pidStr = String(data: pidData, encoding: String.Encoding.utf8)
					*/
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
	}
	
	private func setChildProcessPid(pid: Int32) throws {
		
		/* ## Swift 3
		if(FileManager.default().fileExists(atPath: pidFile)) {
		*/
		if(NSFileManager.defaultManager().fileExistsAtPath(pidFile)) {
			kill(pid, SIGINT)
			throw AppWorkerError.PidFileExists
		}else{
			
			/* ## Swift 3
			let createStatus = FileManager.default().createFile(atPath: pidFile, contents: nil, attributes: nil)
			*/
			let createStatus = NSFileManager.defaultManager().createFileAtPath(pidFile, contents: nil, attributes: nil)
			if(!createStatus) {
				kill(pid, SIGINT)
				throw AppWorkerError.PidFileIsNotWritable
			}
			
			/* ## Swift 3
			let pidFileDescriptor = FileHandle(forWritingAtPath: pidFile)
			*/
			let pidFileDescriptor = NSFileHandle(forWritingAtPath: pidFile)
			if(pidFileDescriptor == nil) {
				kill(pid, SIGINT)
				throw AppWorkerError.PidFileIsNotWritable
			}else{
				/* ## Swift 3
				logger.writeLog(level: Logger.LogLevels.ERROR, message: "Pid file created")
				*/
				logger.writeLog(Logger.LogLevels.ERROR, message: "Pid file created")
				let pidStr = "\(pid)"
				/* ## Swift 3
				pidFileDescriptor?.write(pidStr.data(using: String.Encoding.utf8)!)
				*/
				pidFileDescriptor?.writeData(pidStr.dataUsingEncoding(NSUTF8StringEncoding)!)
				pidFileDescriptor?.closeFile()
				childProcessPid = pid
			}
		}
	}
	
	// MARK: Loop
	private func startLoop() {
		
		/* ## Swift 3
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Child process will be start \(running)")
		*/
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Child process will be start \(running)")
		/* ## Swift 3
		let runLoop = RunLoop.current()
		*/
		let runLoop = NSRunLoop.currentRunLoop()
		repeat {
			let _ = signalHandler.process()
			currentHandlers.forEach { $0.inLoop() }
			usleep(Constants.CpuSleepSec)
		
		/* ## Swift 3
		} while (running && runLoop.run(mode: RunLoopMode.defaultRunLoopMode, before: Date().addingTimeInterval(-1 * Constants.CpuSleepMsec)))
		*/
		} while (running && runLoop.runMode(NSDefaultRunLoopMode, beforeDate: NSDate().dateByAddingTimeInterval(-1 * Constants.CpuSleepMsec)))

		/* ## Swift 3
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Child process will be stop \(running)")
		*/
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Child process will be stop \(running)")
	}
	
	private func deletePid() {
		
		/* ## Swift 3
		if(FileManager.default().fileExists(atPath: pidFile)) {
		*/
		if(NSFileManager.defaultManager().fileExistsAtPath(pidFile)) {
			
			do {
				/* ## Swift 3
				try FileManager.default().removeItem(atPath: pidFile)
				*/
				try NSFileManager.defaultManager().removeItemAtPath(pidFile)
			} catch _ {
				
				/* ## Swift 3
				logger.writeLog(level: Logger.LogLevels.ERROR, message: "Could not delete pid file!")
				*/
				logger.writeLog(Logger.LogLevels.ERROR, message: "Could not delete pid file!")
			}
		}else{
			
			/* ## Swift 3
			logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Pid file does not exists!")
			*/
			logger.writeLog(Logger.LogLevels.WARNINGS, message: "Pid file does not exists!")
		}
	}
}
