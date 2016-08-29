//
//  ArgumentParser.swift
//  IORunner
//
//  Created by ilker özcan on 03/07/16.
//
//

import Foundation

internal class ArgumentParser {

	var argumentScheme: Arguments?
	
	init() {
	}
	
	func parseArguments() -> Arguments? {
		
		var parseError = false
		var nextArgIsValue = false
		var nextArgType: String!
		var nextArgName: String!
	
	#if swift(>=3)
	#if os(Linux)
		let processArgs = ProcessInfo.processInfo().arguments
	#else
		let processArgs = ProcessInfo.processInfo.arguments
	#endif
	#else
		// MARK: swift 2.2
		let processArgs = Process.arguments
	#endif
		
		for i in 0..<processArgs.count {
			
			if(i == 0) {
				self.argumentScheme = Arguments(appPath: processArgs[i])
			}else{
				
				if(nextArgIsValue) {
				
					nextArgIsValue = false
					switch nextArgType {
					case "String":
					#if swift(>=3)
						
						self.argumentScheme?.setStringValue(key: nextArgName, value: processArgs[i])
					#elseif swift(>=2.2) && os(OSX)
						
						self.argumentScheme?.setStringValue(nextArgName, value: Process.arguments[i])
					#endif
						break
					default:
						break
					}
				
					nextArgType = nil
					nextArgName = nil
				
				}else{
				
				#if swift(>=3)
					
					let argIdx = findArgument(currentArgument: processArgs[i])
				#else
					
					let argIdx = findArgument(Process.arguments[i])
				#endif
					
					if argIdx == -1 {
						parseError = true
					}else{
				
						let currentArgData = Arguments.ArgumentNames[argIdx]
						if(currentArgData[3] == "String") {
							nextArgIsValue = true
							nextArgType = currentArgData[3]
							nextArgName = currentArgData[2]
						}else if(currentArgData[3] == "Bool") {
							
						#if swift(>=3)
							
							self.argumentScheme?.setBooleanValue(key: currentArgData[2], value: true)
						#elseif swift(>=2.2) && os(OSX)
							
							self.argumentScheme?.setBooleanValue(currentArgData[2], value: true)
						#endif
						}
					}
				}
			}
		}
		
		if(parseError) {
			return nil
		}else{
			return self.argumentScheme!
		}
	}
	
	func findArgument(currentArgument: String) -> Int {
		
		var retval = -1
		
		for i in 0..<Arguments.ArgumentNames.count {
			
			let currentArgData = Arguments.ArgumentNames[i]
			
			if(currentArgument == currentArgData[0] || currentArgument == currentArgData[1]) {
				retval = i
				break
			}
		}
		
		return retval
	}
}
