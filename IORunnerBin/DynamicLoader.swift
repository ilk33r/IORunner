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
		
	#if swift(>=3)
		
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Extensions loading")
		self.enabledExtensionsDir = getEnabledExtensionsDir(extensionsDir: extensionsDir)
	#elseif swift(>=2.2) && os(OSX)
			
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Extensions loading")
		self.enabledExtensionsDir = getEnabledExtensionsDir(extensionsDir)
	#else
		
		return
	#endif
		self.extensions = createExtensionsPath()
		self.loadedLibs = loadAllLibs()
	}
	
	private mutating func getEnabledExtensionsDir(extensionsDir: String) -> String {
	
		let strEndIdx = extensionsDir.endIndex
	#if swift(>=3)
			
		let _startIdx = extensionsDir.index(strEndIdx, offsetBy: -1)
		let _endIdx = extensionsDir.index(strEndIdx, offsetBy: 0)
	#else
		
		let _startIdx = strEndIdx.advancedBy(-1)
		let _endIdx = strEndIdx.advancedBy(0)
	#endif
		let rangeString = Range<String.Index>(_startIdx..<_endIdx)
	#if swift(>=3)
			
		let selectedCharacter = extensionsDir.substring(with: rangeString)
	#else
			
		let selectedCharacter = extensionsDir.substringWithRange(rangeString)
	#endif
		
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
			
		#if swift(>=3)
		#if os(Linux)
			dirFiles = try NSFileManager.defaultManager().contentsOfDirectory(atPath: self.enabledExtensionsDir)
		#else
			dirFiles = try FileManager.default().contentsOfDirectory(atPath: self.enabledExtensionsDir)
		#endif
		#elseif swift(>=2.2) && os(OSX)
			
			dirFiles = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.enabledExtensionsDir)
		#endif
		} catch _ {
			return retval
		}
		
		for libFile in dirFiles {
			
			let strStartIdx = libFile.startIndex
			let strEndIdx = libFile.endIndex
		#if swift(>=3)
				
			let _startExtensionIdx = libFile.index(strEndIdx, offsetBy: -5)
			let _endExtensionIdx = libFile.index(strEndIdx, offsetBy: 0)
			let extensionRangeString = Range<String.Index>(_startExtensionIdx..<_endExtensionIdx)
			
			let _startLibNameIdx = libFile.index(strStartIdx, offsetBy: 3)
			let _endLibNameIdx = libFile.index(strEndIdx, offsetBy: -6)
			let libNameRangeString = Range<String.Index>(_startLibNameIdx..<_endLibNameIdx)
			
			let libFileExtension = libFile.substring(with: extensionRangeString)
			let libFileName = libFile.substring(with: libNameRangeString)
		#else
			
			let _startExtensionIdx = strEndIdx.advancedBy(-5)
			let _endExtensionIdx = strEndIdx.advancedBy(0)
			let extensionRangeString = Range<String.Index>(_startExtensionIdx..<_endExtensionIdx)
			
			let _startLibNameIdx = strStartIdx.advancedBy(3)
			let _endLibNameIdx = strEndIdx.advancedBy(-6)
			let libNameRangeString = Range<String.Index>(_startLibNameIdx..<_endLibNameIdx)
			
			let libFileExtension = libFile.substringWithRange(extensionRangeString)
			let libFileName = libFile.substringWithRange(libNameRangeString)
		#endif
			
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
				
			#if swift(>=3)
			#if os(Linux)
				extensionRealPath = try NSFileManager.defaultManager().destinationOfSymbolicLink(atPath: extensionPath)
			#else
				extensionRealPath = try FileManager.default().destinationOfSymbolicLink(atPath: extensionPath)
			#endif
			#elseif swift(>=2.2) && os(OSX)
					
				extensionRealPath = try NSFileManager.defaultManager().destinationOfSymbolicLinkAtPath(extensionPath)
			#endif
			} catch _ {
				
			#if swift(>=3)
				
				self.logger.writeLog(level: Logger.LogLevels.ERROR, message: "Extension not found at path \(extensionPath)")
			#elseif swift(>=2.2) && os(OSX)
				
				self.logger.writeLog(Logger.LogLevels.ERROR, message: "Extension not found at path \(extensionPath)")
			#endif
				continue
			}
			
			let epathStartIdx = extensionRealPath.startIndex
		#if swift(>=3)
				
			let _startExtensionRealPathIdx = extensionRealPath.index(epathStartIdx, offsetBy: 0)
			let _endExtensionRealPathIdx_1 = extensionRealPath.index(epathStartIdx, offsetBy: 1)
			let _endExtensionRealPathIdx_2 = extensionRealPath.index(epathStartIdx, offsetBy: 2)
			let _endExtensionRealPathIdx_3 = extensionRealPath.index(epathStartIdx, offsetBy: 3)
		#else
			
			let _startExtensionRealPathIdx = epathStartIdx.advancedBy(0)
			let _endExtensionRealPathIdx_1 = epathStartIdx.advancedBy(1)
			let _endExtensionRealPathIdx_2 = epathStartIdx.advancedBy(2)
			let _endExtensionRealPathIdx_3 = epathStartIdx.advancedBy(3)
		#endif
			
			let extensionRealPathRange_1 = Range<String.Index>(_startExtensionRealPathIdx..<_endExtensionRealPathIdx_1)
			let extensionRealPathRange_2 = Range<String.Index>(_startExtensionRealPathIdx..<_endExtensionRealPathIdx_2)
			let extensionRealPathRange_3 = Range<String.Index>(_startExtensionRealPathIdx..<_endExtensionRealPathIdx_3)
		
		#if swift(>=3)
				
			let extensionRealPathSubStr_1 = extensionRealPath.substring(with: extensionRealPathRange_1)
			let extensionRealPathSubStr_2 = extensionRealPath.substring(with: extensionRealPathRange_2)
			let extensionRealPathSubStr_3 = extensionRealPath.substring(with: extensionRealPathRange_3)
		#else
			
			let extensionRealPathSubStr_1 = extensionRealPath.substringWithRange(extensionRealPathRange_1)
			let extensionRealPathSubStr_2 = extensionRealPath.substringWithRange(extensionRealPathRange_2)
			let extensionRealPathSubStr_3 = extensionRealPath.substringWithRange(extensionRealPathRange_3)
		#endif
			
			let extensionRealAbsolutePath: String
			if(extensionRealPathSubStr_1 == "/") {
				
				extensionRealAbsolutePath = extensionRealPath
			}else{
				
				let epathEndIdx = extensionRealPath.endIndex
			#if swift(>=3)
					
				let _endExtensionRealPathIdx = extensionRealPath.index(epathEndIdx, offsetBy: 0)
			#else
					
				let _endExtensionRealPathIdx = epathEndIdx.advancedBy(0)
			#endif
				
				if(extensionRealPathSubStr_2 == "./") {
					
					let tmpExtensionPathRange_2 = Range<String.Index>(_endExtensionRealPathIdx_2..<_endExtensionRealPathIdx)
				#if swift(>=3)
					
					let tmpExtensionPath_2 = extensionRealPath.substring(with: tmpExtensionPathRange_2)
				#else
					
					let tmpExtensionPath_2 = extensionRealPath.substringWithRange(tmpExtensionPathRange_2)
				#endif
					extensionRealAbsolutePath = self.extensionsAbsoluteDir + "enabled/" + tmpExtensionPath_2
				}else if(extensionRealPathSubStr_3 == "../") {
					
					let tmpExtensionPathRange_3 = Range<String.Index>(_endExtensionRealPathIdx_3..<_endExtensionRealPathIdx)
				#if swift(>=3)
					
					let tmpExtensionPath_3 = extensionRealPath.substring(with: tmpExtensionPathRange_3)
				#else
					
					let tmpExtensionPath_3 = extensionRealPath.substringWithRange(tmpExtensionPathRange_3)
				#endif
					extensionRealAbsolutePath = self.extensionsAbsoluteDir + tmpExtensionPath_3
				}else{
					extensionRealAbsolutePath = extensionRealPath
				}
			}
			
		#if swift(>=3)
			
			guard let openRes = dlopen(extensionRealAbsolutePath, RTLD_NOW|RTLD_LOCAL) else {
				
				self.logger.writeLog(level: Logger.LogLevels.ERROR, message: "\(String(validatingUTF8: dlerror())!)   \(extensionRealAbsolutePath)")
				continue
			}
		#else
			
			let openRes = dlopen(extensionRealAbsolutePath, RTLD_NOW|RTLD_LOCAL)
			if openRes == nil {
			
				self.logger.writeLog(Logger.LogLevels.ERROR, message: "\(String(UTF8String: dlerror())!)   \(extensionRealAbsolutePath)")
				continue
			}
		#endif
			
			let extensionName = extensionLib.2
		#if swift(>=3)
			
			let moduleName_1 = extensionName.replacingOccurrences(of: "-", with: "_")
			let moduleName = moduleName_1.replacingOccurrences(of: " ", with: "_")
		#else
			
			let moduleName_1 = extensionName.stringByReplacingOccurrencesOfString("-", withString: "_")
			let moduleName = moduleName_1.stringByReplacingOccurrencesOfString(" ", withString: "_")
		#endif

			let symbolName = "_TMC\(moduleName.characters.count)\(moduleName)\(moduleName.characters.count)\(moduleName)"
			let sym = dlsym(openRes, symbolName)
			
			guard sym != nil else {
			#if swift(>=3)
				
				self.logger.writeLog(level: Logger.LogLevels.ERROR, message: "\(extensionName) init error at path \(extensionRealAbsolutePath)")
			#elseif swift(>=2.2) && os(OSX)
				
				self.logger.writeLog(Logger.LogLevels.ERROR, message: "\(extensionName) init error at path \(extensionRealAbsolutePath)")
			#endif
				dlclose(openRes)
				continue
			}
			
		#if swift(>=3)
			
			let libClass: InitFunction = unsafeBitCast(sym, to: InitFunction.self)
		#else
			
			let libClass: InitFunction = unsafeBitCast(sym, InitFunction.self)
		#endif
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
			
		#if swift(>=3)
		#if os(Linux)
			let enabledExtensionsdirFiles = try NSFileManager.defaultManager().contentsOfDirectory(atPath: self.enabledExtensionsDir)
		#else
			let enabledExtensionsdirFiles = try FileManager.default().contentsOfDirectory(atPath: self.enabledExtensionsDir)
		#endif
		#else
			
			let enabledExtensionsdirFiles = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.enabledExtensionsDir)
		#endif
			
			for enabledExtensionFile in enabledExtensionsdirFiles {
				
				let strEndIdx = enabledExtensionFile.endIndex
			#if swift(>=3)
				
				let _startExtensionIdx = enabledExtensionFile.index(strEndIdx, offsetBy: -5)
				let _endExtensionIdx = enabledExtensionFile.index(strEndIdx, offsetBy: 0)
				let extensionRangeString = Range<String.Index>(_startExtensionIdx..<_endExtensionIdx)
				let libFileExtension = enabledExtensionFile.substring(with: extensionRangeString)
			#else
				
				let _startExtensionIdx = strEndIdx.advancedBy(-5)
				let _endExtensionIdx = strEndIdx.advancedBy(0)
				let extensionRangeString = Range<String.Index>(_startExtensionIdx..<_endExtensionIdx)
				let libFileExtension = enabledExtensionFile.substringWithRange(extensionRangeString)
			#endif
				
				if(libFileExtension == "dylib") {
					
					enabledExtensionsCount += 1
				}
			}
		} catch _ {
			enabledExtensionsCount = 0
		}
		
		var availabledExtensionsCount = 0
		do {
			
		#if swift(>=3)
		#if os(Linux)
			let availabledExtensionsDirFile = try NSFileManager.defaultManager().contentsOfDirectory(atPath: self.extensionsAbsoluteDir + "available")
		#else
			let availabledExtensionsDirFile = try FileManager.default().contentsOfDirectory(atPath: self.extensionsAbsoluteDir + "available")
		#endif
		#else
			
			let availabledExtensionsDirFile = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.extensionsAbsoluteDir + "available")
		#endif
			for availableExtensionFile in availabledExtensionsDirFile {
				
				let strEndIdx = availableExtensionFile.endIndex
			#if swift(>=3)
				
				let _startExtensionIdx = availableExtensionFile.index(strEndIdx, offsetBy: -5)
				let _endExtensionIdx = availableExtensionFile.index(strEndIdx, offsetBy: 0)
				let extensionRangeString = Range<String.Index>(_startExtensionIdx..<_endExtensionIdx)
				let libFileExtension = availableExtensionFile.substring(with: extensionRangeString)
			#else
				
				let _startExtensionIdx = strEndIdx.advancedBy(-5)
				let _endExtensionIdx = strEndIdx.advancedBy(0)
				let extensionRangeString = Range<String.Index>(_startExtensionIdx..<_endExtensionIdx)
				let libFileExtension = availableExtensionFile.substringWithRange(extensionRangeString)
			#endif
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
		#if swift(>=3)
		#if os(Linux)
			let enabledExtensionsdirFiles = try NSFileManager.defaultManager().contentsOfDirectory(atPath: self.enabledExtensionsDir)
		#else
			let enabledExtensionsdirFiles = try FileManager.default().contentsOfDirectory(atPath: self.enabledExtensionsDir)
		#endif
		#else
			
			let enabledExtensionsdirFiles = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.enabledExtensionsDir)
		#endif
			for enabledExtensionFile in enabledExtensionsdirFiles {
				
				let strEndIdx = enabledExtensionFile.endIndex
			#if swift(>=3)
					
				let _startExtensionIdx = enabledExtensionFile.index(strEndIdx, offsetBy: -5)
				let _endExtensionIdx = enabledExtensionFile.index(strEndIdx, offsetBy: 0)
				let extensionRangeString = Range<String.Index>(_startExtensionIdx..<_endExtensionIdx)
				let libFileExtension = enabledExtensionFile.substring(with: extensionRangeString)
			#else
				
				let _startExtensionIdx = strEndIdx.advancedBy(-5)
				let _endExtensionIdx = strEndIdx.advancedBy(0)
				let extensionRangeString = Range<String.Index>(_startExtensionIdx..<_endExtensionIdx)
				let libFileExtension = enabledExtensionFile.substringWithRange(extensionRangeString)
			#endif
				
				if(libFileExtension == "dylib") {
					
					let strStartIdx = enabledExtensionFile.startIndex
				#if swift(>=3)
					
					let _startExtensionNameIdx = enabledExtensionFile.index(strStartIdx, offsetBy: 3)
					let _endExtensionNameIdx = enabledExtensionFile.index(strEndIdx, offsetBy: -6)
					let extensionNameRangeString = Range<String.Index>(_startExtensionNameIdx..<_endExtensionNameIdx)
					retval.append((enabledExtensionFile.substring(with: extensionNameRangeString), true))
				#else
					
					let _startExtensionNameIdx = strStartIdx.advancedBy(3)
					let _endExtensionNameIdx = strEndIdx.advancedBy(-6)
					let extensionNameRangeString = Range<String.Index>(_startExtensionNameIdx..<_endExtensionNameIdx)
					retval.append((enabledExtensionFile.substringWithRange(extensionNameRangeString), true))
				#endif
				}
			}
		} catch _ {
			// pass
		}
		
		do {
		#if swift(>=3)
		#if os(Linux)
			let availabledExtensionsDirFile = try NSFileManager.defaultManager().contentsOfDirectory(atPath: self.extensionsAbsoluteDir + "available")
		#else
			let availabledExtensionsDirFile = try FileManager.default().contentsOfDirectory(atPath: self.extensionsAbsoluteDir + "available")
		#endif
		#else
			
			let availabledExtensionsDirFile = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.extensionsAbsoluteDir + "available")
		#endif
			for availableExtensionFile in availabledExtensionsDirFile {
				
				let strEndIdx = availableExtensionFile.endIndex
			#if swift(>=3)
				
				let _startExtensionIdx = availableExtensionFile.index(strEndIdx, offsetBy: -5)
				let _endExtensionIdx = availableExtensionFile.index(strEndIdx, offsetBy: 0)
				let extensionRangeString = Range<String.Index>(_startExtensionIdx..<_endExtensionIdx)
				let libFileExtension = availableExtensionFile.substring(with: extensionRangeString)
			#else
				
				let _startExtensionIdx = strEndIdx.advancedBy(-5)
				let _endExtensionIdx = strEndIdx.advancedBy(0)
				let extensionRangeString = Range<String.Index>(_startExtensionIdx..<_endExtensionIdx)
				let libFileExtension = availableExtensionFile.substringWithRange(extensionRangeString)
			#endif
				if(libFileExtension == "dylib") {
					
					let strStartIdx = availableExtensionFile.startIndex
				#if swift(>=3)
					
					let _startExtensionNameIdx = availableExtensionFile.index(strStartIdx, offsetBy: 3)
					let _endExtensionNameIdx = availableExtensionFile.index(strEndIdx, offsetBy: -6)
					let extensionNameRangeString = Range<String.Index>(_startExtensionNameIdx..<_endExtensionNameIdx)
					let availableExtensionName = availableExtensionFile.substring(with: extensionNameRangeString)
				#else
					
					let _startExtensionNameIdx = strStartIdx.advancedBy(3)
					let _endExtensionNameIdx = strEndIdx.advancedBy(-6)
					let extensionNameRangeString = Range<String.Index>(_startExtensionNameIdx..<_endExtensionNameIdx)
					let availableExtensionName = availableExtensionFile.substringWithRange(extensionNameRangeString)
				#endif
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
		#if swift(>=3)
		#if os(Linux)
			let enabledExtensionsdirFiles = try NSFileManager.defaultManager().contentsOfDirectory(atPath: self.enabledExtensionsDir)
		#else
			let enabledExtensionsdirFiles = try FileManager.default().contentsOfDirectory(atPath: self.enabledExtensionsDir)
		#endif
		#else
			
			let enabledExtensionsdirFiles = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.enabledExtensionsDir)
		#endif
			var currentIdx = 0
			
			for enabledExtensionFile in enabledExtensionsdirFiles {
				
				let strEndIdx = enabledExtensionFile.endIndex
			#if swift(>=3)
				
				let _startExtensionIdx = enabledExtensionFile.index(strEndIdx, offsetBy: -5)
				let _endExtensionIdx = enabledExtensionFile.index(strEndIdx, offsetBy: 0)
				let extensionRangeString = Range<String.Index>(_startExtensionIdx..<_endExtensionIdx)
				let libFileExtension = enabledExtensionFile.substring(with: extensionRangeString)
			#else
				
				let _startExtensionIdx = strEndIdx.advancedBy(-5)
				let _endExtensionIdx = strEndIdx.advancedBy(0)
				let extensionRangeString = Range<String.Index>(_startExtensionIdx..<_endExtensionIdx)
				let libFileExtension = enabledExtensionFile.substringWithRange(extensionRangeString)
			#endif
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
		#if swift(>=3)
		#if os(Linux)
			try NSFileManager.defaultManager().removeItem(atPath: enabledExtensionsDir + "/" + moduleFileName)
		#else
			try FileManager.default().removeItem(atPath: enabledExtensionsDir + "/" + moduleFileName)
		#endif
		#elseif swift(>=2.2) && os(OSX)
			
			try NSFileManager.defaultManager().removeItemAtPath(enabledExtensionsDir + "/" + moduleFileName)
		#endif
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
		#if swift(>=3)
		#if os(Linux)
			try NSFileManager.defaultManager().createSymbolicLink(atPath: moduleDestinationFile, withDestinationPath: moduleSourceFile)
		#else
			try FileManager.default().createSymbolicLink(atPath: moduleDestinationFile, withDestinationPath: moduleSourceFile)
		#endif
		#elseif swift(>=2.2) && os(OSX)
			
			try NSFileManager.defaultManager().createSymbolicLinkAtPath(moduleDestinationFile, withDestinationPath: moduleSourceFile)
		#endif
		} catch _ {
			return false
		}
		
		return true
	}
}
