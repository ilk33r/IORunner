//
//  main.swift
//  IOIniTest
//
//  Created by ilker özcan on 28/07/16.
//
//

import IOIni

print("Start IOIni test")

let tmpIniFile = "[Daemonize]\nDaemonize=1\nPid=/Users/ilk3r/Desktop/temp/IOProcessChecker/IOProcessChecker.pid\n\n[Logging]\n; 0 (minimal), 1 (errors), 2 (errors + warnings)\nLogLevel=2\n; extension must be logfiles\nLogFile=/Users/ilk3r/Desktop/temp/IOProcessChecker/IOProcessChecker.log\nMaxLogSize=100000000\n\n[Extensions]\nExtensionsDir=/Users/ilk3r/Desktop/temp/IOProcessChecker/extensions\n\n[TestHandler]\nTestHandlerConfig1=Value1\nTestHandlerConfig2=Value2\nTestHandlerConfig3=Value3\n\n\n[  iniTest  ]\n    LoremIpsum = Dolor\n  KeyEscaped = \"Hello World!\" \n KeyNew = Value\n  \tKeyNew2 = Value2"

do {
	let iniData = try parseINI(withString: tmpIniFile)
	let configData = try iniData.getConfigData()
	
	for sectionData in configData.sections {
		
		print("Section: \(sectionData.name)")
		
		for configData in sectionData.settings {
			
			print("\(configData.key) = \(configData.value)")
		}
		
		print("\n")
	}
	
} catch (let e) {
	print(e)
}



