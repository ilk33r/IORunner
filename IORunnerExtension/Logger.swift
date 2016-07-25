//
//  Logger.swift
//  IORunner/IORunnerExtension
//
//  Created by ilker özcan on 04/07/16.
//
//

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
	
	/* ## Swift 3
	public enum LoggerError: ErrorProtocol {
		case FileSizeTooSmall
		case FileIsNotWritable
	}
	*/
	public enum LoggerError: ErrorType {
		case FileSizeTooSmall
		case FileIsNotWritable
	}
	
	private static let logFormat = "[%@] - %@ %@\n"
	private static let logDebugFormat = "%@: %@\n"
	private static let logTimeFormat = "yyyy-LL-dd HH:mm:ss"
	
	private var logLevel: Int
	private var logFilePath: String
	private var maxLogFileSize: UInt64
	private var logFileInitialized = false
	private var currentLogFileSize: UInt64 = 0
	private var debugMode = false
	/* ## Swift 3
	private var logFileDescriptor: FileHandle?
	*/
	private var logFileDescriptor: NSFileHandle?
	
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
		
		/* ## Swift 3
		let currentDate = Date()
		let formatter = DateFormatter()
		formatter.dateFormat = Logger.logTimeFormat
		formatter.timeZone = TimeZone(abbreviation: "GMT")
		*/
		let currentDate = NSDate()
		let formatter = NSDateFormatter()
		formatter.dateFormat = Logger.logTimeFormat
		formatter.timeZone = NSTimeZone(abbreviation: "GMT")
		/* ## Swift 3
		return formatter.string(from: currentDate)
		*/
		return formatter.stringFromDate(currentDate)
	}
	
	public func setupLogger() throws {
		
		/* ## Swift 3
		if(!FileManager.default().isWritableFile(atPath: getLogFileFolder())) {
			throw LoggerError.FileIsNotWritable
		}
		
		if(FileManager.default().fileExists(atPath: logFilePath)) {
			
			if(FileManager.default().isWritableFile(atPath: logFilePath)) {
				
				logFileDescriptor = FileHandle(forWritingAtPath: logFilePath)
				
				if(logFileDescriptor != nil) {
					logFileDescriptor?.seekToEndOfFile()
					currentLogFileSize = (logFileDescriptor?.offsetInFile)!
				}
			}else{
				throw LoggerError.FileIsNotWritable
			}
				
		}else{
			
			FileManager.default().createFile(atPath: logFilePath, contents: nil, attributes: nil)
			logFileDescriptor = FileHandle(forWritingAtPath: logFilePath)
			currentLogFileSize = 0
		}
		*/
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

	}
	
	public func writeLog(level: LogLevels, message: String) {
		
		if(logFileDescriptor == nil && !debugMode) {
			return
		}
		
		if(level.rawValue <= self.logLevel) {
			
			if(debugMode) {
				
				let logString = String(format: Logger.logDebugFormat, level.getNameForLevel(), message)
				print(logString)
			}else{
				
				let logString = String(format: Logger.logFormat, currentLoggerTime(), level.getNameForLevel(), message)
				let logStringSize = logString.characters.count
				currentLogFileSize += UInt64(logStringSize)
				logFileDescriptor?.writeData(logString.dataUsingEncoding(NSUTF8StringEncoding)!)
				/* ## Swift 3
				logFileDescriptor?.write(logString.data(using: String.Encoding.utf8)!)
				*/
			
				if(currentLogFileSize >= maxLogFileSize) {
					createNewLogFile()
				}
			}
		}
	}
	
	private func createNewLogFile() {
		
		closeLogFile()
		let logFileFolder = getLogFileFolder()
		/* ## Swift 3
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
				FileManager.default().createFile(atPath: logFilePath, contents: nil, attributes: nil)
				logFileDescriptor = FileHandle(forWritingAtPath: logFilePath)
				currentLogFileSize = 0
			}
		}
		*/
		
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
	}
	
	public func closeLogFile() {
		
		logFileDescriptor?.closeFile()
		logFileDescriptor = nil
	}
	
	private func getLogFileFolder() -> String {
		
		/* ## Swift 3
		let splittedLogPath = logFilePath.characters.split(separator: "/").map(String.init)
		*/
		let splittedLogPath = logFilePath.characters.split("/").map(String.init)
		var logFileFolder = ""
		
		for i in 0..<(splittedLogPath.count - 1) {
			
			logFileFolder += "/"
			logFileFolder += splittedLogPath[i]
		}
		
		return logFileFolder
	}

}
