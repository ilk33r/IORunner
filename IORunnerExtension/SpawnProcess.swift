//
//  SpawnProcess.swift
//  IORunner
//
//  Created by ilker özcan on 20/08/16.
//
//

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif
import Foundation

public typealias maybeCChar = UnsafeMutablePointer<CChar>

#if swift(>=3)
	enum SpawnProcessError: Error {
		case DaemonizeFailed
	}
#elseif swift(>=2.2) && os(OSX)
	
	enum SpawnProcessError: ErrorType {
		case DaemonizeFailed
	}
#endif

public struct ProcessConfigData {
	
	private var _currentEnvironments: [(String, String)]?
	private var _processArgs: [String]?
	
	public var Environments: [(String, String)]? {
		
		get {
			return self._currentEnvironments
		}
		
		set {
			
			guard newValue != nil else {
				return
			}
			
			if(newValue!.count > 0) {
				
				if(self._currentEnvironments == nil) {
					self._currentEnvironments = [(String, String)]()
				}
				
				for envData in newValue! {
					
					self._currentEnvironments?.append(envData)
				}
			}
		}
	}
	
	public var ProcessArgs: [String]? {
		
		get {
			return self._processArgs
		}
		
		set {
			self._processArgs = newValue
		}
	}
	
	public init() {
		
		self._currentEnvironments = nil
		self._processArgs = nil
	}
	
	public mutating func resetEnv() {
		
		self._currentEnvironments = nil
	}
	
	public mutating func resetArgs() {
		
		self._processArgs = nil
	}
}

public func SpawnCurrentProcess(logger: Logger, configData: ProcessConfigData) throws -> pid_t {
	
	guard configData.ProcessArgs != nil else {
		
		throw SpawnProcessError.DaemonizeFailed
	}
	
	let argLen = configData.ProcessArgs!.count
	
	if(argLen < 1) {
		throw SpawnProcessError.DaemonizeFailed
	}
	
	var procPid = pid_t()
	let allocateLen = argLen + 1
	
#if swift(>=3)

	let cArgs = UnsafeMutablePointer<maybeCChar?>.allocate(capacity: allocateLen)
	defer {
		cArgs.deinitialize(count: allocateLen)
		cArgs.deallocate(capacity: allocateLen)
	}
	
#else

	let cArgs = UnsafeMutablePointer<maybeCChar>.alloc(allocateLen)
	defer {
		cArgs.dealloc(allocateLen)
		cArgs.destroy(allocateLen)
	}
	
#endif
	
	var currentIdx = 0
	for currentArg in configData.ProcessArgs! {
		
		cArgs[currentIdx] = strdup(currentArg)
		currentIdx += 1
	}
	
#if swift(>=3)
#if os(Linux)
	cArgs[currentIdx] = UnsafeMutablePointer<CChar>(nil)
	var environments = ProcessInfo.processInfo().environment
#else
	cArgs[currentIdx] = UnsafeMutablePointer<CChar>(mutating: nil)
	var environments = ProcessInfo().environment
#endif
	
	if let extraEnv = configData.Environments {
		
		for currentEnv in extraEnv {
			
			let envKey = currentEnv.0
			environments[envKey] = currentEnv.1
		}
	}
	
	let cEnv = UnsafeMutablePointer<maybeCChar?>.allocate(capacity: environments.count + 1)
						
	defer {
		cEnv.deinitialize(count: environments.count + 1)
		cEnv.deallocate(capacity: environments.count + 1)
	}
#if os(Linux)
	cEnv[environments.count] = UnsafeMutablePointer<CChar>(nil)
#else
	cEnv[environments.count] = UnsafeMutablePointer<CChar>(mutating: nil)
#endif
#else
					
	cArgs[currentIdx] = UnsafeMutablePointer<CChar>(nil)
					
	var environments = NSProcessInfo().environment
	
	if let extraEnv = configData.Environments {
	
		for currentEnv in extraEnv {
	
			let envKey = currentEnv.0
				environments[envKey] = currentEnv.1
			}
	}
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

#if swift(>=3) && os(OSX)
	pipe(UnsafeMutablePointer<Int32>(mutating: fSTDIN))
	pipe(UnsafeMutablePointer<Int32>(mutating: fSTDOUT))
	pipe(UnsafeMutablePointer<Int32>(mutating: fSTDERR))
#else
	pipe(UnsafeMutablePointer<Int32>(fSTDIN))
	pipe(UnsafeMutablePointer<Int32>(fSTDOUT))
	pipe(UnsafeMutablePointer<Int32>(fSTDERR))
#endif

#if os(Linux)
	var fileActions = posix_spawn_file_actions_t()
#else
	var fileActions = posix_spawn_file_actions_t(mutating: nil)
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
	
	/*
	var spawnAttr: posix_spawnattr_t?
#if os(Linux)
	let attrSize = sizeof(posix_spawnattr_t.self)
	let attrPoint = UnsafeMutablePointer<posix_spawnattr_t>.allocate(capacity: attrSize)
	
	defer {
		attrPoint.deinitialize(count: attrSize)
		attrPoint.deallocate(capacity: attrSize)
	}
	
	let _ = posix_spawnattr_init(attrPoint)
	posix_spawnattr_setflags(attrPoint, Int16(POSIX_SPAWN_SETSIGDEF))
	let spawnRes = posix_spawnp(&procPid, configData.ProcessArgs![0], &fileActions, attrPoint, cArgs, cEnv)
#else
	let _ = posix_spawnattr_init(&spawnAttr)
	posix_spawnattr_setflags(&spawnAttr, Int16(POSIX_SPAWN_SETSIGDEF))
	let spawnRes = posix_spawnp(&procPid, configData.ProcessArgs![0], &fileActions, &spawnAttr, cArgs, cEnv)
#endif
	*/
	let spawnRes = posix_spawnp(&procPid, configData.ProcessArgs![0], &fileActions, nil, cArgs, cEnv)
	
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
	
	/*
#if os(Linux)
	posix_spawnattr_destroy(attrPoint)
#else
	posix_spawnattr_destroy(&spawnAttr)
#endif
	*/
	
#if os(Linux)
	_ = Glibc.close(fSTDIN[0])
	_ = Glibc.close(fSTDOUT[1])
	_ = Glibc.close(fSTDERR[1])
	if spawnRes != 0 {
		_ = Glibc.close(fSTDIN[1])
		_ = Glibc.close(fSTDOUT[0])
		_ = Glibc.close(fSTDERR[0])
		throw SpawnProcessError.DaemonizeFailed
	}
#else
	_ = Darwin.close(fSTDIN[0])
	_ = Darwin.close(fSTDOUT[1])
	_ = Darwin.close(fSTDERR[1])
	if spawnRes != 0 {
		_ = Darwin.close(fSTDIN[1])
		_ = Darwin.close(fSTDOUT[0])
		_ = Darwin.close(fSTDERR[0])
		throw SpawnProcessError.DaemonizeFailed
	}
#endif

	return procPid
}
