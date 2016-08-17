//
//  Arguments.swift
//  IORunner
//
//  Created by ilker özcan on 03/07/16.
//
//

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif
import Foundation

internal struct Arguments {
	
	// [name] [short name] [variable name] [type] [description] [tab size]
	static let ArgumentNames = [
		["--config", "-c", "config", "String", "Config file path", "2"],
		["--debug", "-d", "debug", "Bool", "Debug mode", "3"],
		["--help", "-h", "help", "Bool", "Display help", "3"],
		["--version", "-v", "version", "Bool", "Display version", "3"],
		["--buildinfo", "-bi", "buildinfo", "Bool", "Display build info", "2"],
		["--configdump", "-cd", "configdump", "Bool", "Display all configuration", "2"],
		["--onlyusearguments", "-ua", "usetextbased", "Bool", "Only use arguments", "1"],
		["--signal", "-s", "signalname", "String", "If only using arguments send signal.\n\t\t\t\t\t(start|stop|restart|force-stop)", "2"],
		["--keepalive", "-ka", "keepalive", "Bool", "Do not exit after create the child process\n", "2"]
	]
	
	#if os(OSX)
	private static let appNameHeader = "\n\u{001B}[31m %@ \u{001B}[0m"
	#elseif os(Linux)
	private static let appNameHeader = "\n%s"
	#else
	private static let appNameHeader = "\n%@"
	#endif
	
	#if os(OSX)
	private static let usageString = "\n\nUsage: %@ -arg1 value -arg2 value -arg3  value ...\nArguments: \n\n"
	#else
	private static let usageString = "\n\nUsage: %s -arg1 value -arg2 value -arg3  value ...\nArguments: \n\n"
	#endif
	
	var appPath: String
	var config: String?
	var debug: Bool = false
	var helpMode: Bool = false
	var versionMode: Bool = false
	var buildinfoMode: Bool = false
	var configDumpMode: Bool = false
	var textMode: Bool = false
	var signalName: String?
	var keepalive: Bool = false
	
	init(appPath: String) {
		
		self.appPath = appPath
	}
	
	internal mutating func setStringValue(key: String, value: String) {
		
		switch key {
		case "config":
			self.config = value
			break
		case "signalname":
		#if swift(>=3)
			
			self.signalName = value.lowercased()
		#elseif swift(>=2.2) && os(OSX)
				
			self.signalName = value.lowercaseString
		#endif
		default:
			break
		}
	}
	
	internal mutating func setBooleanValue(key: String, value: Bool) {
		
		switch key {
		case "debug":
			self.debug = value
			break
		case "help":
			self.helpMode = true
			break
		case "version":
			self.versionMode = true
			break
		case "buildinfo":
			self.buildinfoMode = true
			break
		case "configdump":
			self.configDumpMode = true
			break
		case "usetextbased":
			self.textMode = true
			break
		case "keepalive":
			self.keepalive = true
			break
		default:
			break
		}
	}
	
	static func getUsage() -> String {
		
	#if os(Linux)
		
		let arg1: UnsafeMutablePointer<CChar> = strdup(Constants.APP_NAME)
		let arg2: UnsafeMutablePointer<CChar> = strdup(Constants.APP_PACKAGE_NAME)
		
		var currentUsageString = String(format: Arguments.appNameHeader, arguments: [arg1]) + String(format: Arguments.usageString, arguments: [arg2])
		arg1.deinitialize()
		arg2.deinitialize()
	#else
		var currentUsageString = String(format: Arguments.appNameHeader, Constants.APP_NAME) + String(format: Arguments.usageString, Constants.APP_PACKAGE_NAME)
	#endif
		for i in 0..<Arguments.ArgumentNames.count {
			
			let currentArgData = Arguments.ArgumentNames[i]
			let tabSize: Int
			if let currentTabSize = Int(currentArgData[5]) {
				tabSize = currentTabSize
			}else{
				tabSize = 3
			}
			
			if(currentArgData[3] == "Bool") {
				currentUsageString += "\(currentArgData[1]) (\(currentArgData[0]))"
				for _ in 0...tabSize {
					currentUsageString += "\t"
				}
				currentUsageString += ": \(currentArgData[4])\n"
			}else{
				currentUsageString += "\(currentArgData[1]) (\(currentArgData[0])) [value]"
				for _ in 0...tabSize {
					currentUsageString += "\t"
				}
				currentUsageString += ": \(currentArgData[4])\n"
			}
		}

		return currentUsageString
	}
	
	static func getVersion() -> String {
		
	#if os(Linux)
		let arg1: UnsafeMutablePointer<CChar> = strdup(Constants.APP_NAME)
		
		let currentUsageString = String(format: Arguments.appNameHeader, arguments: [arg1]) + "\n" + Constants.APP_VERSION + "\n" + Constants.APP_CREDITS
		arg1.deinitialize()
	#else
		let currentUsageString = String(format: Arguments.appNameHeader, Constants.APP_NAME) + "\n" + Constants.APP_VERSION + "\n" + Constants.APP_CREDITS
	#endif
		return currentUsageString
	}
	
	static func getBuildInfo() -> String {
		
	#if os(Linux)
		let arg1: UnsafeMutablePointer<CChar> = strdup(Constants.APP_NAME)
		
		var currentUsageString = String(format: Arguments.appNameHeader, arguments: [arg1]) + "\nOS\t\t\t: "
		arg1.deinitialize()
	#else
		var currentUsageString = String(format: Arguments.appNameHeader, Constants.APP_NAME) + "\nOS\t\t\t: "
	#endif
		#if os(OSX)
		currentUsageString += "Mac OS X"
		#elseif os(Linux)
		currentUsageString += "Linux"
		#else
		currentUsageString += "Other"
		#endif
		
		currentUsageString += "\nArch\t\t\t: "
		#if arch(x86_64)
		currentUsageString += "x86_64"
		#elseif arch(arm) || arch(arm64)
		currentUsageString += "arm (64)"
		#elseif arch(i386)
		currentUsageString += "i386"
		#else
		currentUsageString += "Other"
		#endif
		
		return currentUsageString
	}
}
