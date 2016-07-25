//
//  DynamicLoader.swift
//  IORunner
//
//  Created by ilker özcan on 12/07/16.
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

typealias InitFunction = AppHandlers.Type

internal struct DynamicLoader {
	
	private var logger: Logger
	private var extensionsDir: String
	private var appConfig: Config
	private var extensionsAbsoluteDir: String!
	private var enabledExtensionsDir: String!
	private var extensions: [(String, String, String)]!
	private var loadedLibs: [AppHandlers]!
	
	init(logger: Logger, extensionsDir: String, appConfig: Config) {
		
		self.logger = logger
		self.extensionsDir = extensionsDir
		self.appConfig = appConfig
		
		/* ## Swift 3
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Extensions loading")
		self.enabledExtensionsDir = getEnabledExtensionsDir(extensionsDir: extensionsDir)
		*/
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Extensions loading")
		self.enabledExtensionsDir = getEnabledExtensionsDir(extensionsDir)
		self.extensions = createExtensionsPath()
		self.loadedLibs = loadAllLibs()
	}
	
	private mutating func getEnabledExtensionsDir(extensionsDir: String) -> String {
	
		let strEndIdx = extensionsDir.endIndex
		
		/* ## Swift 3
		let _startIdx = extensionsDir.index(strEndIdx, offsetBy: -1)
		let _endIdx = extensionsDir.index(strEndIdx, offsetBy: 0)
		*/
		let _startIdx = strEndIdx.advancedBy(-1)
		let _endIdx = strEndIdx.advancedBy(0)
		let rangeString = Range<String.Index>(_startIdx..<_endIdx)
		/* ## Swift 3
		let selectedCharacter = extensionsDir.substring(with: rangeString)
		*/
		let selectedCharacter = extensionsDir.substringWithRange(rangeString)
		
		let enabledExtensionDir: String
		if(selectedCharacter == "/") {
			
			enabledExtensionDir = extensionsDir + "enabled"
			extensionsAbsoluteDir = extensionsDir
		}else{
			enabledExtensionDir = extensionsDir + "/enabled"
			extensionsAbsoluteDir = extensionsDir + "/"
		}
		
		return enabledExtensionDir
	}

	private mutating func createExtensionsPath() -> [(String, String, String)] {
		
		var retval = [(String, String, String)]()
		
		let dirFiles: [String]
		do {
			
			/* ## Swift 3
			dirFiles = try FileManager.default().contentsOfDirectory(atPath: self.enabledExtensionsDir)
			*/
			dirFiles = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.enabledExtensionsDir)
		} catch _ {
			return retval
		}
		
		for libFile in dirFiles {
			
			let strStartIdx = libFile.startIndex
			let strEndIdx = libFile.endIndex
			
			/* ## Swift 3
			let _startExtensionIdx = libFile.index(strEndIdx, offsetBy: -5)
			let _endExtensionIdx = libFile.index(strEndIdx, offsetBy: 0)
			*/
			let _startExtensionIdx = strEndIdx.advancedBy(-5)
			let _endExtensionIdx = strEndIdx.advancedBy(0)
			let extensionRangeString = Range<String.Index>(_startExtensionIdx..<_endExtensionIdx)
			
			/* ## Swift 3
			let _startLibNameIdx = libFile.index(strStartIdx, offsetBy: 3)
			let _endLibNameIdx = libFile.index(strEndIdx, offsetBy: -6)
			*/
			let _startLibNameIdx = strStartIdx.advancedBy(3)
			let _endLibNameIdx = strEndIdx.advancedBy(-6)
			let libNameRangeString = Range<String.Index>(_startLibNameIdx..<_endLibNameIdx)
			
			/* ## Swift 3
			let libFileExtension = libFile.substring(with: extensionRangeString)
			let libFileName = libFile.substring(with: libNameRangeString)
			*/
			let libFileExtension = libFile.substringWithRange(extensionRangeString)
			let libFileName = libFile.substringWithRange(libNameRangeString)
			
			if(libFileExtension == "dylib") {
				
				let libFilePath = self.enabledExtensionsDir + "/" + libFile
				let appendVal = (libFile, libFilePath, libFileName)
				retval.append(appendVal)
			}
		}
		
		return retval
	}
	
	private mutating func loadAllLibs() -> [AppHandlers] {
		
		var retval = [AppHandlers]()
		
		for extensionLib in self.extensions {
			
			let extensionPath = extensionLib.1
			let extensionRealPath: String
			do {
				
				/* ## Swift 3
				extensionRealPath = try FileManager.default().destinationOfSymbolicLink(atPath: extensionPath)
				*/
				extensionRealPath = try NSFileManager.defaultManager().destinationOfSymbolicLinkAtPath(extensionPath)
			} catch _ {
				
				/* ## Swift 3
				self.logger.writeLog(level: Logger.LogLevels.ERROR, message: "Extension not found at path \(extensionPath)")
				*/
				self.logger.writeLog(Logger.LogLevels.ERROR, message: "Extension not found at path \(extensionPath)")
				continue
			}
			
			let epathStartIdx = extensionRealPath.startIndex
			
			/* ## Swift 3
			let _startExtensionRealPathIdx = extensionRealPath.index(epathStartIdx, offsetBy: 0)
			let _endExtensionRealPathIdx_1 = extensionRealPath.index(epathStartIdx, offsetBy: 1)
			let _endExtensionRealPathIdx_2 = extensionRealPath.index(epathStartIdx, offsetBy: 2)
			let _endExtensionRealPathIdx_3 = extensionRealPath.index(epathStartIdx, offsetBy: 3)
			*/
			let _startExtensionRealPathIdx = epathStartIdx.advancedBy(0)
			let _endExtensionRealPathIdx_1 = epathStartIdx.advancedBy(1)
			let _endExtensionRealPathIdx_2 = epathStartIdx.advancedBy(2)
			let _endExtensionRealPathIdx_3 = epathStartIdx.advancedBy(3)
			
			let extensionRealPathRange_1 = Range<String.Index>(_startExtensionRealPathIdx..<_endExtensionRealPathIdx_1)
			let extensionRealPathRange_2 = Range<String.Index>(_startExtensionRealPathIdx..<_endExtensionRealPathIdx_2)
			let extensionRealPathRange_3 = Range<String.Index>(_startExtensionRealPathIdx..<_endExtensionRealPathIdx_3)
			
			/* ## Swift 3
			let extensionRealPathSubStr_1 = extensionRealPath.substring(with: extensionRealPathRange_1)
			let extensionRealPathSubStr_2 = extensionRealPath.substring(with: extensionRealPathRange_2)
			let extensionRealPathSubStr_3 = extensionRealPath.substring(with: extensionRealPathRange_3)
			*/
			let extensionRealPathSubStr_1 = extensionRealPath.substringWithRange(extensionRealPathRange_1)
			let extensionRealPathSubStr_2 = extensionRealPath.substringWithRange(extensionRealPathRange_2)
			let extensionRealPathSubStr_3 = extensionRealPath.substringWithRange(extensionRealPathRange_3)
			
			let extensionRealAbsolutePath: String
			if(extensionRealPathSubStr_1 == "/") {
				
				extensionRealAbsolutePath = extensionRealPath
			}else{
				
				let epathEndIdx = extensionRealPath.endIndex
				/* ## Swift 3
				let _endExtensionRealPathIdx = extensionRealPath.index(epathEndIdx, offsetBy: 0)
				*/
				let _endExtensionRealPathIdx = epathEndIdx.advancedBy(0)
				
				if(extensionRealPathSubStr_2 == "./") {
					
					let tmpExtensionPathRange_2 = Range<String.Index>(_endExtensionRealPathIdx_2..<_endExtensionRealPathIdx)
					
					/* ## Swift 3
					let tmpExtensionPath_2 = extensionRealPath.substring(with: tmpExtensionPathRange_2)
					*/
					let tmpExtensionPath_2 = extensionRealPath.substringWithRange(tmpExtensionPathRange_2)
					extensionRealAbsolutePath = self.extensionsAbsoluteDir + "enabled/" + tmpExtensionPath_2
				}else if(extensionRealPathSubStr_3 == "../") {
					
					let tmpExtensionPathRange_3 = Range<String.Index>(_endExtensionRealPathIdx_3..<_endExtensionRealPathIdx)
					/* ## Swift 3
					let tmpExtensionPath_3 = extensionRealPath.substring(with: tmpExtensionPathRange_3)
					*/
					let tmpExtensionPath_3 = extensionRealPath.substringWithRange(tmpExtensionPathRange_3)
					extensionRealAbsolutePath = self.extensionsAbsoluteDir + tmpExtensionPath_3
				}else{
					extensionRealAbsolutePath = extensionRealPath
				}
			}
			
			let openRes = dlopen(extensionRealAbsolutePath, RTLD_NOW|RTLD_LOCAL)
			if openRes == nil {
				self.logger.writeLog(Logger.LogLevels.ERROR, message: "\(String(UTF8String: dlerror())!)   \(extensionRealAbsolutePath)")
				continue
			}
			
			/* ## Swift 3
			guard let openRes = dlopen(extensionRealAbsolutePath, RTLD_NOW|RTLD_LOCAL) else {
			
				self.logger.writeLog(level: Logger.LogLevels.ERROR, message: "\(String(validatingUTF8: dlerror())!)   \(extensionRealAbsolutePath)")
				continue
			}
			*/
			
			let extensionName = extensionLib.2
			/* ## Swift 3
			let moduleName_1 = extensionName.replacingOccurrences(of: "-", with: "_")
			let moduleName = moduleName_1.replacingOccurrences(of: " ", with: "_")
			*/
			let moduleName_1 = extensionName.stringByReplacingOccurrencesOfString("-", withString: "_")
			let moduleName = moduleName_1.stringByReplacingOccurrencesOfString(" ", withString: "_")
			let symbolName = "_TMC\(moduleName.characters.count)\(moduleName)\(moduleName.characters.count)\(moduleName)"
			let sym = dlsym(openRes, symbolName)
			
			guard sym != nil else {
				/* ## Swift 3
				self.logger.writeLog(level: Logger.LogLevels.ERROR, message: "\(extensionName) init error at path \(extensionRealAbsolutePath)")
				*/
				self.logger.writeLog(Logger.LogLevels.ERROR, message: "\(extensionName) init error at path \(extensionRealAbsolutePath)")
				dlclose(openRes)
				continue
			}
			
			/* ## Swift 3
			let libClass: InitFunction = unsafeBitCast(sym, to: InitFunction.self)
			*/
			let libClass: InitFunction = unsafeBitCast(sym, InitFunction.self)
			var currentModuleConfig: Section? = nil
			
			if let libraryConfig = appConfig[extensionName] {
				
				currentModuleConfig = libraryConfig
			}
			
			let currentHandler = libClass.init(logger: self.logger, moduleConfig: currentModuleConfig)
			retval.append(currentHandler)
		}
		
		return retval
	}
	
	func getLoadedHandlers() -> [AppHandlers] {
		
		return self.loadedLibs
	}
	
	func getLoadedModuleInfo() -> (Int, Int) {
		
		var enabledExtensionsCount = 0
		do {
			
			/* ## Swift 3
			let enabledExtensionsdirFiles = try FileManager.default().contentsOfDirectory(atPath: self.enabledExtensionsDir)
			*/
			let enabledExtensionsdirFiles = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.enabledExtensionsDir)
			
			for enabledExtensionFile in enabledExtensionsdirFiles {
				
				let strEndIdx = enabledExtensionFile.endIndex
				
				/* ## Swift 3
				let _startExtensionIdx = enabledExtensionFile.index(strEndIdx, offsetBy: -5)
				let _endExtensionIdx = enabledExtensionFile.index(strEndIdx, offsetBy: 0)
				*/
				let _startExtensionIdx = strEndIdx.advancedBy(-5)
				let _endExtensionIdx = strEndIdx.advancedBy(0)
				let extensionRangeString = Range<String.Index>(_startExtensionIdx..<_endExtensionIdx)
				
				/* ## Swift 3
				let libFileExtension = enabledExtensionFile.substring(with: extensionRangeString)
				*/
				let libFileExtension = enabledExtensionFile.substringWithRange(extensionRangeString)
				
				if(libFileExtension == "dylib") {
					
					enabledExtensionsCount += 1
				}
			}
		} catch _ {
			enabledExtensionsCount = 0
		}
		
		var availabledExtensionsCount = 0
		do {
			
			/* ## Swift 3
			let availabledExtensionsDirFile = try FileManager.default().contentsOfDirectory(atPath: self.extensionsAbsoluteDir + "available")
			*/
			let availabledExtensionsDirFile = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.extensionsAbsoluteDir + "available")
			
			for availableExtensionFile in availabledExtensionsDirFile {
				
				let strEndIdx = availableExtensionFile.endIndex
				
				/* ## Swift 3
				let _startExtensionIdx = availableExtensionFile.index(strEndIdx, offsetBy: -5)
				let _endExtensionIdx = availableExtensionFile.index(strEndIdx, offsetBy: 0)
				*/
				let _startExtensionIdx = strEndIdx.advancedBy(-5)
				let _endExtensionIdx = strEndIdx.advancedBy(0)
				let extensionRangeString = Range<String.Index>(_startExtensionIdx..<_endExtensionIdx)
				
				/* ## Swift 3
				let libFileExtension = availableExtensionFile.substring(with: extensionRangeString)
				*/
				let libFileExtension = availableExtensionFile.substringWithRange(extensionRangeString)
				
				if(libFileExtension == "dylib") {
					
					availabledExtensionsCount += 1
				}
			}
		} catch _ {
			availabledExtensionsCount = 0
		}
		
		return (availabledExtensionsCount, enabledExtensionsCount)
	}
	
	func getModulesList() -> [(String, Bool)] {
		
		var retval = [(String, Bool)]()
		
		do {
			/* ## Swift 3
			let enabledExtensionsdirFiles = try FileManager.default().contentsOfDirectory(atPath: self.enabledExtensionsDir)
			*/
			let enabledExtensionsdirFiles = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.enabledExtensionsDir)
			
			for enabledExtensionFile in enabledExtensionsdirFiles {
				
				let strEndIdx = enabledExtensionFile.endIndex
				
				/* ## Swift 3
				let _startExtensionIdx = enabledExtensionFile.index(strEndIdx, offsetBy: -5)
				let _endExtensionIdx = enabledExtensionFile.index(strEndIdx, offsetBy: 0)
				*/
				let _startExtensionIdx = strEndIdx.advancedBy(-5)
				let _endExtensionIdx = strEndIdx.advancedBy(0)
				let extensionRangeString = Range<String.Index>(_startExtensionIdx..<_endExtensionIdx)
				/* ## Swift 3
				let libFileExtension = enabledExtensionFile.substring(with: extensionRangeString)
				*/
				let libFileExtension = enabledExtensionFile.substringWithRange(extensionRangeString)
				
				if(libFileExtension == "dylib") {
					
					let strStartIdx = enabledExtensionFile.startIndex
					/* ## Swift 3
					let _startExtensionNameIdx = enabledExtensionFile.index(strStartIdx, offsetBy: 3)
					let _endExtensionNameIdx = enabledExtensionFile.index(strEndIdx, offsetBy: -6)
					*/
					let _startExtensionNameIdx = strStartIdx.advancedBy(3)
					let _endExtensionNameIdx = strEndIdx.advancedBy(-6)
					let extensionNameRangeString = Range<String.Index>(_startExtensionNameIdx..<_endExtensionNameIdx)
					/* ## Swift 3
					retval.append((enabledExtensionFile.substring(with: extensionNameRangeString), true))
					*/
					retval.append((enabledExtensionFile.substringWithRange(extensionNameRangeString), true))
				}
			}
		} catch _ {
			// pass
		}
		
		do {
			/* ## Swift 3
			let availabledExtensionsDirFile = try FileManager.default().contentsOfDirectory(atPath: self.extensionsAbsoluteDir + "available")
			*/
			let availabledExtensionsDirFile = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.extensionsAbsoluteDir + "available")
			
			for availableExtensionFile in availabledExtensionsDirFile {
				
				let strEndIdx = availableExtensionFile.endIndex
				
				/* ## Swift 3
				let _startExtensionIdx = availableExtensionFile.index(strEndIdx, offsetBy: -5)
				let _endExtensionIdx = availableExtensionFile.index(strEndIdx, offsetBy: 0)
				*/
				let _startExtensionIdx = strEndIdx.advancedBy(-5)
				let _endExtensionIdx = strEndIdx.advancedBy(0)
				let extensionRangeString = Range<String.Index>(_startExtensionIdx..<_endExtensionIdx)
				
				/* ## Swift 3
				let libFileExtension = availableExtensionFile.substring(with: extensionRangeString)
				*/
				let libFileExtension = availableExtensionFile.substringWithRange(extensionRangeString)
				
				if(libFileExtension == "dylib") {
					
					let strStartIdx = availableExtensionFile.startIndex
					/* ## Swift 3
					let _startExtensionNameIdx = availableExtensionFile.index(strStartIdx, offsetBy: 3)
					let _endExtensionNameIdx = availableExtensionFile.index(strEndIdx, offsetBy: -6)
					*/
					let _startExtensionNameIdx = strStartIdx.advancedBy(3)
					let _endExtensionNameIdx = strEndIdx.advancedBy(-6)
					let extensionNameRangeString = Range<String.Index>(_startExtensionNameIdx..<_endExtensionNameIdx)
					/* ## Swift 3
					let availableExtensionName = availableExtensionFile.substring(with: extensionNameRangeString)
					*/
					let availableExtensionName = availableExtensionFile.substringWithRange(extensionNameRangeString)
					var addToExtensionList = true
					
					for allExtensions in retval {
						
						if(allExtensions.0 == availableExtensionName && allExtensions.1) {
							
							addToExtensionList = false
							break
						}
					}
					
					if(addToExtensionList) {
						retval.append((availableExtensionName, false))
					}
				}
			}
		} catch _ {
			// pass
		}
		
		return retval
	}
	
	func deactivateModule(moduleIdx: Int) -> Bool {
		
		var moduleFileName: String!
		do {
			/* ## Swift 3
			let enabledExtensionsdirFiles = try FileManager.default().contentsOfDirectory(atPath: self.enabledExtensionsDir)
			*/
			let enabledExtensionsdirFiles = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.enabledExtensionsDir)
			var currentIdx = 0
			
			for enabledExtensionFile in enabledExtensionsdirFiles {
				
				let strEndIdx = enabledExtensionFile.endIndex
				
				/* ## Swift 3
				let _startExtensionIdx = enabledExtensionFile.index(strEndIdx, offsetBy: -5)
				let _endExtensionIdx = enabledExtensionFile.index(strEndIdx, offsetBy: 0)
				*/
				let _startExtensionIdx = strEndIdx.advancedBy(-5)
				let _endExtensionIdx = strEndIdx.advancedBy(0)
				let extensionRangeString = Range<String.Index>(_startExtensionIdx..<_endExtensionIdx)
				
				/* ## Swift 3
				let libFileExtension = enabledExtensionFile.substring(with: extensionRangeString)
				*/
				let libFileExtension = enabledExtensionFile.substringWithRange(extensionRangeString)
				
				if(libFileExtension == "dylib") {
					
					if(currentIdx == moduleIdx) {
						
						moduleFileName = enabledExtensionFile
						break
					}
					currentIdx += 1
				}
			}
		} catch _ {
			return false
		}
		
		do {
			/* ## Swift 3
			try FileManager.default().removeItem(atPath: enabledExtensionsDir + "/" + moduleFileName)
			*/
			try NSFileManager.defaultManager().removeItemAtPath(enabledExtensionsDir + "/" + moduleFileName)
		} catch _ {
			return false
		}
		
		return true
	}
	
	func activateModule(moduleIdx: Int) -> Bool {
		
		let moduleList = getModulesList()
		
		let moduleSourceFile = extensionsAbsoluteDir + "available/lib" + moduleList[moduleIdx].0 + ".dylib"
		let moduleDestinationFile = extensionsAbsoluteDir + "enabled/lib" + moduleList[moduleIdx].0 + ".dylib"
		do {
			
			/* ## Swift 3
			try FileManager.default().createSymbolicLink(atPath: moduleDestinationFile, withDestinationPath: moduleSourceFile)
			*/
			try NSFileManager.defaultManager().createSymbolicLinkAtPath(moduleDestinationFile, withDestinationPath: moduleSourceFile)
		} catch _ {
			return false
		}
		
		return true
	}
}
