//
//  Logger.swift
//  IORunner/IORunnerExtension
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

public final class Logger {
	
	public enum LogLevels: Int {
		case MINIMAL = 0
		case ERROR = 1
		case WARNINGS = 2
		
		func getNameForLevel() -> String {
			
			switch self.rawValue {
			case 0:
				return "CRITICAL"
			case 1:
				return "ERROR"
			case 2:
				return "WARNING"
			default:
				return "LOG"
			}
		}
	}

#if swift(>=3)
#if os(Linux)
	public enum LoggerError: Error {
		case FileSizeTooSmall
		case FileIsNotWritable
	}
#else
	public enum LoggerError: ErrorProtocol {
		case FileSizeTooSmall
		case FileIsNotWritable
	}
#endif
#elseif swift(>=2.2) && os(OSX)
	
	public enum LoggerError: ErrorType {
		case FileSizeTooSmall
		case FileIsNotWritable
	}
#endif
	
	private static let logFormat = "[%@] - %@ %@\n"
	private static let logDebugFormat = "%@: %@\n"
	private static let logTimeFormat = "yyyy-LL-dd HH:mm:ss"
	
	private var logLevel: Int
	private var logFilePath: String
	private var maxLogFileSize: UInt64
	private var logFileInitialized = false
	private var currentLogFileSize: UInt64 = 0
	private var debugMode = false
#if swift(>=3)
	private var logFileDescriptor: FileHandle?
#elseif swift(>=2.2) && os(OSX)
	private var logFileDescriptor: NSFileHandle?
#endif
	
	public init(logLevel: Int, logFilePath: String, maxLogFileSize: Int, debugMode: Bool = false) throws {
		
		self.logLevel = logLevel
		self.logFilePath = logFilePath
		self.maxLogFileSize = UInt64(maxLogFileSize)
		self.debugMode = debugMode
		
		if(self.maxLogFileSize < 10) {
			throw LoggerError.FileSizeTooSmall
		}
		
		try setupLogger()
	}
	
	private func currentLoggerTime() -> String {
		
	#if swift(>=3)
		
		let currentDate = Date()
		let formatter = DateFormatter()
	#else
		
		let currentDate = NSDate()
		let formatter = NSDateFormatter()
	#endif

		formatter.dateFormat = Logger.logTimeFormat
	
	#if swift(>=3)
		formatter.timeZone = TimeZone(abbreviation: "GMT")
		return formatter.string(from: currentDate)
	#elseif swift(>=2.2) && os(OSX)
		formatter.timeZone = NSTimeZone(abbreviation: "GMT")
		return formatter.stringFromDate(currentDate)
	#endif
		
	}
	
	public func setupLogger() throws {
		
	#if swift(>=3)
		
		if(!FileManager.default().isWritableFile(atPath: getLogFileFolder())) {
			
			throw LoggerError.FileIsNotWritable
		}
		
		if(FileManager.default().fileExists(atPath: logFilePath)) {
			
			if(FileManager.default().isWritableFile(atPath: logFilePath)) {
				
				logFileDescriptor = FileHandle(forWritingAtPath: logFilePath)
				
				if(logFileDescriptor != nil) {
				#if os(Linux)
					let _ = logFileDescriptor?.seekToEndOfFile()
				#else
					logFileDescriptor?.seekToEndOfFile()
				#endif
					currentLogFileSize = (logFileDescriptor?.offsetInFile)!
				}
			}else{
				throw LoggerError.FileIsNotWritable
			}
			
		}else{
			
		#if os(Linux)
			let _ = FileManager.default().createFile(atPath: logFilePath, contents: nil, attributes: nil)
		#else
			FileManager.default().createFile(atPath: logFilePath, contents: nil, attributes: nil)
		#endif
			logFileDescriptor = FileHandle(forWritingAtPath: logFilePath)
			currentLogFileSize = 0
		}
		
	#else
			
		if(!NSFileManager.defaultManager().isWritableFileAtPath(getLogFileFolder())) {
			
			throw LoggerError.FileIsNotWritable
		}
			
		if(NSFileManager.defaultManager().fileExistsAtPath(logFilePath)) {
			
			if(NSFileManager.defaultManager().isWritableFileAtPath(logFilePath)) {
			
				logFileDescriptor = NSFileHandle(forWritingAtPath: logFilePath)
			
				if(logFileDescriptor != nil) {
			
					logFileDescriptor?.seekToEndOfFile()
					currentLogFileSize = (logFileDescriptor?.offsetInFile)!
				}
			}else{
				throw LoggerError.FileIsNotWritable
			}
			
		}else{
			
			NSFileManager.defaultManager().createFileAtPath(logFilePath, contents: nil, attributes: nil)
			logFileDescriptor = NSFileHandle(forWritingAtPath: logFilePath)
			currentLogFileSize = 0
		}

	#endif
	}
	
	public func writeLog(level: LogLevels, message: String) {
		
		if(logFileDescriptor == nil && !debugMode) {
			return
		}
		
		if(level.rawValue <= self.logLevel) {
			
			if(debugMode) {
			
			#if os(Linux)
				let logString = String(format: Logger.logDebugFormat, arguments: [level.getNameForLevel() as! CVarArg, message as! CVarArg])
			#else
				let logString = String(format: Logger.logDebugFormat, level.getNameForLevel(), message)
			#endif
				print(logString)
			}else{
				
			#if os(Linux)
				let logString = String(format: Logger.logFormat, arguments: [currentLoggerTime() as! CVarArg, level.getNameForLevel() as! CVarArg, message as! CVarArg])
			#else
				let logString = String(format: Logger.logFormat, currentLoggerTime(), level.getNameForLevel(), message)
			#endif
				let logStringSize = logString.characters.count
				currentLogFileSize += UInt64(logStringSize)
			#if swift(>=3)
				logFileDescriptor?.write(logString.data(using: String.Encoding.utf8)!)
			#elseif swift(>=2.2) && os(OSX)
				
				logFileDescriptor?.writeData(logString.dataUsingEncoding(NSUTF8StringEncoding)!)
			#endif
			
				if(currentLogFileSize >= maxLogFileSize) {
					createNewLogFile()
				}
			}
		}
	}
	
	private func createNewLogFile() {
		
		closeLogFile()
		let logFileFolder = getLogFileFolder()

	#if swift(>=3)
		
		
		if(FileManager.default().isWritableFile(atPath: logFileFolder)) {

			if let dirFiles = try? FileManager.default().contentsOfDirectory(atPath: logFileFolder) {

				var lastLogNumber = 0
				for currentFile in dirFiles {

					let splittedFileNamePath = currentFile.characters.split(separator: ".").map(String.init)
					if(splittedFileNamePath.count >= 3) {

						let fileNumberIdx = splittedFileNamePath.count - 1
						let fileExtensionIdx = splittedFileNamePath.count - 2

						if(splittedFileNamePath[fileExtensionIdx] == "log") {

							if let logNumberInt = Int(splittedFileNamePath[fileNumberIdx]) {

								if(lastLogNumber < logNumberInt) {
									lastLogNumber = logNumberInt
								}
							}
						}
					}
				}

				lastLogNumber += 1
				let newLogFile = logFilePath + ".\(lastLogNumber)"
				let _ = try? FileManager.default().moveItem(atPath: logFilePath, toPath: newLogFile)
			#if os(Linux)
				let _ = FileManager.default().createFile(atPath: logFilePath, contents: nil, attributes: nil)
			#else
				FileManager.default().createFile(atPath: logFilePath, contents: nil, attributes: nil)
			#endif
				logFileDescriptor = FileHandle(forWritingAtPath: logFilePath)
				currentLogFileSize = 0
			}
		}

	#else
			
		if(NSFileManager.defaultManager().isWritableFileAtPath(logFileFolder)) {
		
			if let dirFiles = try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(logFileFolder) {
			
				var lastLogNumber = 0
				for currentFile in dirFiles {
		
					let splittedFileNamePath = currentFile.characters.split(".").map(String.init)
					if(splittedFileNamePath.count >= 3) {
		
						let fileNumberIdx = splittedFileNamePath.count - 1
						let fileExtensionIdx = splittedFileNamePath.count - 2
		
						if(splittedFileNamePath[fileExtensionIdx] == "log") {
		
							if let logNumberInt = Int(splittedFileNamePath[fileNumberIdx]) {
		
								if(lastLogNumber < logNumberInt) {
		
									lastLogNumber = logNumberInt
								}
							}
						}
					}
				}
		
				lastLogNumber += 1
				let newLogFile = logFilePath + ".\(lastLogNumber)"
				let _ = try? NSFileManager.defaultManager().moveItemAtPath(logFilePath, toPath: newLogFile)
				NSFileManager.defaultManager().createFileAtPath(logFilePath, contents: nil, attributes: nil)
				logFileDescriptor = NSFileHandle(forWritingAtPath: logFilePath)
				currentLogFileSize = 0
			}
		}
	#endif
	}
	
	public func closeLogFile() {
		
		logFileDescriptor?.closeFile()
		logFileDescriptor = nil
	}
	
	private func getLogFileFolder() -> String {
		
		#if swift(>=3)
			
			let splittedLogPath = logFilePath.characters.split(separator: "/").map(String.init)
		#else
			
			let splittedLogPath = logFilePath.characters.split("/").map(String.init)
		#endif

		var logFileFolder = ""
		
		for i in 0..<(splittedLogPath.count - 1) {
			
			logFileFolder += "/"
			logFileFolder += splittedLogPath[i]
		}
		
		return logFileFolder
	}

}
