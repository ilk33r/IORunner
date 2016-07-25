//
//  Arguments.swift
//  IORunner
//
//  Created by ilker özcan on 03/07/16.
//
//

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
		["--signal", "-s", "signalname", "String", "If only using arguments send signal.\n(start|stop|restart|force-stop)\n", "2"]
	]
	
	#if os(OSX)
	private static let appNameHeader = "\n\u{001B}[31m %@ \u{001B}[0m"
	#else
	private static let appNameHeader = "\n%@"
	#endif
	private static let usageString = "\n\nUsage: %@ -arg1 value -arg2 value -arg3  value ...\nArguments: \n\n"
	
	var appPath: String
	var config: String?
	var debug: Bool = false
	var helpMode: Bool = false
	var versionMode: Bool = false
	var buildinfoMode: Bool = false
	var configDumpMode: Bool = false
	var textMode: Bool = false
	var signalName: String?
	
	init(appPath: String) {
		
		self.appPath = appPath
	}
	
	internal mutating func setStringValue(key: String, value: String) {
		
		switch key {
		case "config":
			self.config = value
			break
		case "signalname":
			/* ## Swift 3
			self.signalName = value.lowercased()
			*/
			self.signalName = value.lowercaseString
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
		default:
			break
		}
	}
	
	static func getUsage() -> String {
		
		var currentUsageString = String(format: Arguments.appNameHeader, Constants.APP_NAME) + String(format: Arguments.usageString, Constants.APP_PACKAGE_NAME)
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
		
		let currentUsageString = String(format: Arguments.appNameHeader, Constants.APP_NAME) + "\n" + Constants.APP_VERSION + "\n" + Constants.APP_CREDITS
		return currentUsageString
	}
	
	static func getBuildInfo() -> String {
		
		var currentUsageString = String(format: Arguments.appNameHeader, Constants.APP_NAME) + "\nOS\t\t\t: "
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
