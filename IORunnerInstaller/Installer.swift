//
//  Installer.swift
//  IORunner/Installer
//
//  Created by ilker özcan on 18/07/16.
//
//

import Foundation
import IOGUI

class Installer {
	
	private var mainGUI: GUIWidgets!
	private var inGuiLoop = false
	private var selectedPath = "/usr/local/\(Constants.APP_PACKAGE_NAME)"
	
	init() {
		
		self.mainGUI = GUIWidgets() { (action) in
			
			/* ## Swift 3
			self.setGuiAction(action: action)
			*/
			self.setGuiAction(action)
		}
		inGuiLoop = true
		onGUI()
	}
	
	private func setGuiAction(action: MainGuiActions) {
		
		switch action {
		case .EXIT:
			inGuiLoop = false
			break
		case .BACK:
			break
		default:
			break
		}
	}
	
	private func onGUI() {
		
		let backgroundWidget = BackgroundWidget(mainWindow: self.mainGUI.mainWindow)
		/* ## Swift 3
		self.mainGUI.initBackgroundWidget(widget: backgroundWidget)
		*/
		self.mainGUI.initBackgroundWidget(backgroundWidget)
		
		let copyrightText = "\(Constants.APP_CREDITS)\t\t\t\tVersion: \(Constants.APP_VERSION)"
		let titleWidget = TitleAndFooterWidget(title: "Install \(Constants.APP_NAME)", copyright: copyrightText, keyControls: (GUIConstants.MenuButtons, GUIConstants.ArrowsLeftRight), mainWindow: self.mainGUI.mainWindow)
		/* ## Swift 3
		self.mainGUI.initTitleWidget(widget: titleWidget)
		*/
		self.mainGUI.initTitleWidget(titleWidget)
		self.step1()
		
		/* ## Swift 3
		let runLoop = RunLoop.current()
		*/
		let runLoop = NSRunLoop.currentRunLoop()
		repeat {
			self.mainGUI.onGUI()
			
			usleep(Constants.GuiRefreshRate)
		
		/* ## Swift 3
		} while (inGuiLoop && runLoop.run(mode: RunLoopMode.defaultRunLoopMode, before: Date().addingTimeInterval(-1 * Constants.CpuSleepMsec)))
		
		self.mainGUI.exitGui(status: 0)
		*/
		} while (inGuiLoop && runLoop.runMode(NSDefaultRunLoopMode, beforeDate: NSDate().dateByAddingTimeInterval(-1 * Constants.CpuSleepMsec)))
		
		self.mainGUI.exitGui(0)
	}
	
	private func step1() {
		
		let step1Popup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "Welcome to the \(Constants.APP_NAME) installer.", popupButtons: ["Next"], hasShadow: true, popupDelegate: { (selectedChoiceIdx) in
			
			self.mainGUI.deinitPopupWidget()
			self.step2()
			
			}, mainWindow: self.mainGUI.mainWindow)
		/* ## Swift 3
		self.mainGUI.initPopupWidget(widget: step1Popup)
		*/
		self.mainGUI.initPopupWidget(step1Popup)
		self.mainGUI.refreshMainWindow()
	}
	
	private func step2() {
		
		let step2Popup = InputPopupWidget(defaultValue: selectedPath, popupContent: "Install Path: ", popupButtons: ["Next", "Back"], hasShadow: true, popupDelegate: { (selectedChoiceIdx, inputData) in
			
			self.mainGUI.deinitInputPopupWidget()
			if(selectedChoiceIdx == 0) {
				
				self.selectedPath = inputData
				self.checkInstallDir()
				
			}else if(selectedChoiceIdx == 1) {
				
				self.step1()
			}
			
			}, mainWindow: self.mainGUI.mainWindow)
		/* ## Swift 3
		self.mainGUI.initInputPopupWidget(widget: step2Popup)
		*/
		self.mainGUI.initInputPopupWidget(step2Popup)
		self.mainGUI.refreshMainWindow()
	}
	
	private func checkInstallDir() {
		
		if(selectedPath.characters.count == 0) {
			
			let errorPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "   Error\n    Install directory is empty!", popupButtons: ["Back"], hasShadow: true, popupDelegate: { (selectedChoiceIdx) in
				
				self.mainGUI.deinitPopupWidget()
				self.step2()
				
				}, mainWindow: self.mainGUI.mainWindow)
			/* ## Swift 3
			self.mainGUI.initPopupWidget(widget: errorPopup)
			*/
			self.mainGUI.initPopupWidget(errorPopup)
			self.mainGUI.refreshMainWindow()
		}else{
		
			/* ## Swift 3
			let splittedFileNamePath = selectedPath.characters.split(separator: "/").map(String.init)
			*/
			let splittedFileNamePath = selectedPath.characters.split("/").map(String.init)
			let splittedFileNamePathCount = splittedFileNamePath.count
			var errorType = -1
		
			if(splittedFileNamePathCount >= 0) {
			
				var newPath = ""
				for idx in 0..<(splittedFileNamePathCount) {
				
					if(splittedFileNamePath[idx].characters.count > 0) {
					
						newPath += "/\(splittedFileNamePath[idx])"
					}
					
					if(newPath.characters.count > 0) {

						/* ## Swift 3
						let directoryExists = FileManager.default().fileExists(atPath: newPath)
						*/
						let directoryExists = NSFileManager.defaultManager().fileExistsAtPath(newPath)
						if(directoryExists) {
							continue
						}else{
							
							do {
								/* ## Swift 3
								try FileManager.default().createDirectory(atPath: newPath, withIntermediateDirectories: false, attributes: nil)
								*/
								try NSFileManager.defaultManager().createDirectoryAtPath(newPath, withIntermediateDirectories: false, attributes: nil)
								errorType = 0
								
							} catch _ {
								errorType = 2
							}
						}
					}
				}
				
				if(errorType == -1) {
					
					errorType = 0
				}
			}else{
				errorType = 1
			}
			
			var errorMessage = ""
			switch errorType {
			case 0:
				let errorPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "Are you sure want to install \(selectedPath)", popupButtons: ["No", "Yes"], hasShadow: true, popupDelegate: { (selectedChoiceIdx) in
					
					self.mainGUI.deinitPopupWidget()
					if(selectedChoiceIdx == 0) {
						self.step2()
					}else{
						self.step3()
					}
					
					}, mainWindow: self.mainGUI.mainWindow)
				/* ## Swift 3
				self.mainGUI.initPopupWidget(widget: errorPopup)
				*/
				self.mainGUI.initPopupWidget(errorPopup)
				self.mainGUI.refreshMainWindow()
				return
			case 1:
				errorMessage = "   Error\n    Invalid directory!"
				break
			case 2:
				errorMessage = "   Error\n    Permission error!"
				break
			default:
				errorMessage = "   Error\n    Unkown error!"
				break
			}
			
			let errorPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: errorMessage, popupButtons: ["Back"], hasShadow: true, popupDelegate: { (selectedChoiceIdx) in
				
				self.mainGUI.deinitPopupWidget()
				self.step2()
				
				}, mainWindow: self.mainGUI.mainWindow)
			/* ## Swift 3
			self.mainGUI.initPopupWidget(widget: errorPopup)
			*/
			self.mainGUI.initPopupWidget(errorPopup)
			self.mainGUI.refreshMainWindow()
		}
	}
	
	private func step3() {
		
		var progressPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.PROGRESS, popupContent: "Installing ...", popupButtons: [], hasShadow: true, popupDelegate: { (selectedChoiceIdx) in
			
			// pass
			}, mainWindow: self.mainGUI.mainWindow)
		/* ## Swift 3
		self.mainGUI.initPopupWidget(widget: progressPopup)
		*/
		self.mainGUI.initPopupWidget(progressPopup)
		self.mainGUI.refreshMainWindow()
		
		var currentPercent: UInt = 0
		
		// 1%
		self.fixInstallDirectory()
		do {
			
			/* ## Swift 3
			try FileManager.default().createDirectory(atPath: selectedPath + "temp", withIntermediateDirectories: false, attributes: nil)
			*/
			try NSFileManager.defaultManager().createDirectoryAtPath(selectedPath + "temp", withIntermediateDirectories: false, attributes: nil)
		} catch _ {
			
			/* ## Swift 3
			self.abortInstall(message: "Could not create directory \n \(selectedPath)temp")
			*/
			self.abortInstall("Could not create directory \n \(selectedPath)temp")
			return
		}
		
		/* ## Swift 3
		FileManager.default().createFile(atPath: selectedPath + "temp/processCheckerInstall.zip", contents: nil, attributes: nil)
		*/
		NSFileManager.defaultManager().createFileAtPath(selectedPath + "temp/processCheckerInstall.zip", contents: nil, attributes: nil)
		
		currentPercent += 1
		/* ## Swift 3
		progressPopup.setPercent(newPercent: currentPercent)
		*/
		progressPopup.setPercent(currentPercent)
		
		/* ## Swift 3
		if let zipFileFD = FileHandle(forWritingAtPath: selectedPath + "temp/processCheckerInstall.zip") {
		*/
		if let zipFileFD = NSFileHandle(forWritingAtPath: selectedPath + "temp/processCheckerInstall.zip") {
			
			// 2%
			currentPercent += 1
			/* ## Swift 3
			progressPopup.setPercent(newPercent: currentPercent)
			*/
			progressPopup.setPercent(currentPercent)
			
			for idx in 0..<getAssetSize() {
				
				let assetByte = getAssetByte(idx)
				let intVal = [assetByte]
				/* ## Swift 3
				let byteData = Data(bytes: intVal)
				*/
				let byteData = NSData(bytes: intVal, length: 1)
				zipFileFD.writeData(byteData)
				
				let idxPercent = (idx * 75) / getAssetSize()
				if(idxPercent > 0) {
					
					let newPercent = UInt(2 + idxPercent)
					if(currentPercent != newPercent) {
					
						currentPercent = newPercent
						/* ## Swift 3
						progressPopup.setPercent(newPercent: currentPercent)
						*/
						progressPopup.setPercent(currentPercent)
					}
				}
			}
			
			// 77%
			/* ## Swift 3
			let task = Task()
			*/
			let task = NSTask()
			task.launchPath = "/usr/bin/unzip"
			task.arguments = ["-o", "\(selectedPath)temp/processCheckerInstall.zip", "-d", "\(selectedPath)temp"]
			
			/* ## Swift 3
			let pipe = Pipe()
			*/
			let pipe = NSPipe()
			task.standardOutput = pipe
			task.launch()
			task.waitUntilExit()
			/* ## Swift 3
			let _ = try? FileManager.default().removeItem(atPath: "\(selectedPath)temp/processCheckerInstall.zip")
			*/
			let _ = try? NSFileManager.defaultManager().removeItemAtPath("\(selectedPath)temp/processCheckerInstall.zip")
			
			currentPercent += 11
			/* ## Swift 3
			progressPopup.setPercent(newPercent: currentPercent)
			*/
			progressPopup.setPercent(currentPercent)
			
			// 88%
			do {
				try self.moveDirectory("\(selectedPath)temp/Build/bin", toPath: "\(selectedPath)bin")
			} catch _ {
				
				self.abortInstall("Could not create directory \n \(selectedPath)bin")
				return
			}
			
			currentPercent += 1
			/* ## Swift 3
			progressPopup.setPercent(newPercent: currentPercent)
			*/
			progressPopup.setPercent(currentPercent)
			
			// 89%
			do {
				
				/* ## Swift 3
				try FileManager.default().createDirectory(atPath: "\(selectedPath)etc", withIntermediateDirectories: false, attributes: nil)
				*/
				try NSFileManager.defaultManager().createDirectoryAtPath("\(selectedPath)etc", withIntermediateDirectories: false, attributes: nil)
				try self.moveDirectory("\(selectedPath)temp/Build/lib", toPath: "\(selectedPath)lib")
			} catch _ {
				
				self.abortInstall("Could not create directory \(selectedPath)lib")
				return
			}
			
			currentPercent += 4
			/* ## Swift 3
			progressPopup.setPercent(newPercent: currentPercent)
			*/
			progressPopup.setPercent(currentPercent)
			
			// 93%
			do {
				try self.moveDirectory("\(selectedPath)temp/Build/frameworks", toPath: "\(selectedPath)include")
			} catch _ {
				
				self.abortInstall("Could not create directory \(selectedPath)include")
				return
			}
			
			currentPercent += 1
			/* ## Swift 3
			progressPopup.setPercent(newPercent: currentPercent)
			*/
			progressPopup.setPercent(currentPercent)
		
			// 94%
			do {
				
				/* ## Swift 3
				try FileManager.default().createDirectory(atPath: "\(selectedPath)lib/extensions", withIntermediateDirectories: false, attributes: nil)
				try FileManager.default().createDirectory(atPath: "\(selectedPath)lib/extensions/available", withIntermediateDirectories: false, attributes: nil)
				try FileManager.default().createDirectory(atPath: "\(selectedPath)lib/extensions/enabled", withIntermediateDirectories: false, attributes: nil)
				*/
				try NSFileManager.defaultManager().createDirectoryAtPath("\(selectedPath)lib/extensions", withIntermediateDirectories: false, attributes: nil)
				try NSFileManager.defaultManager().createDirectoryAtPath("\(selectedPath)lib/extensions/available", withIntermediateDirectories: false, attributes: nil)
				try NSFileManager.defaultManager().createDirectoryAtPath("\(selectedPath)lib/extensions/enabled", withIntermediateDirectories: false, attributes: nil)
				
				try self.moveDirectory("\(selectedPath)temp/Build/extensions", toPath: "\(selectedPath)lib/extensions/available")
			} catch _ {
				
				self.abortInstall("Could not create directory \n \(selectedPath)extensions")
				return
			}

			currentPercent += 4
			/* ## Swift 3
			progressPopup.setPercent(newPercent: currentPercent)
			*/
			progressPopup.setPercent(currentPercent)

			// 98%
			do {
				try NSFileManager.defaultManager().createDirectoryAtPath("\(selectedPath)var", withIntermediateDirectories: false, attributes: nil)
				try NSFileManager.defaultManager().createDirectoryAtPath("\(selectedPath)var/run", withIntermediateDirectories: false, attributes: nil)
				try NSFileManager.defaultManager().createDirectoryAtPath("\(selectedPath)var/log", withIntermediateDirectories: false, attributes: nil)
			} catch _ {
				
				self.abortInstall("Could not create directory \(selectedPath)var")
				return
			}
			
			currentPercent += 1
			progressPopup.setPercent(currentPercent)
			
			// 99%
			let configData = "\(daemonizeConfigData)\(selectedPath)var/run/\(Constants.APP_PACKAGE_NAME).pid\n\n\(loggingConfigDataStart)\(selectedPath)var/log/\(Constants.APP_PACKAGE_NAME).log\n\(loggingConfigDataEnd)\(extensionsConfigData)\(selectedPath)lib/extensions\n"
			/* ## Swift 3
			FileManager.default().createFile(atPath: "\(selectedPath)etc/Config.ini", contents: configData.data(using: String.Encoding.utf8), attributes: nil)
			*/
			NSFileManager.defaultManager().createFileAtPath("\(selectedPath)etc/Config.ini", contents: configData.dataUsingEncoding(NSUTF8StringEncoding), attributes: nil)
			currentPercent += 1
			progressPopup.setPercent(currentPercent)
			
			// 100%
			let startScript = "#!/bin/sh\n\n\(selectedPath)bin/\(Constants.APP_PACKAGE_NAME) -c \(selectedPath)etc/Config.ini\n"
			NSFileManager.defaultManager().createFileAtPath("/usr/local/bin/\(Constants.APP_PACKAGE_NAME)", contents: startScript.dataUsingEncoding(NSUTF8StringEncoding), attributes: nil)
			currentPercent += 1
			progressPopup.setPercent(currentPercent)
			let task2 = NSTask()
			task2.launchPath = "/bin/chmod"
			task2.arguments = ["+x", "\(selectedPath)bin/\(Constants.APP_PACKAGE_NAME)"]
			
			let pipe2 = NSPipe()
			task2.standardOutput = pipe2
			task2.launch()
			task2.waitUntilExit()
			
			do {
				try NSFileManager.defaultManager().removeItemAtPath("\(selectedPath)temp/Build")
				try NSFileManager.defaultManager().removeItemAtPath("\(selectedPath)temp")
			} catch _ {
				// pass
			}
			
			self.mainGUI.deinitPopupWidget()
			let finishPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "\(Constants.APP_NAME) has been successfully installed on your computer", popupButtons: ["OK"], hasShadow: true, popupDelegate: { (selectedChoiceIdx) in
				
				self.inGuiLoop = false
				
				}, mainWindow: self.mainGUI.mainWindow)
			self.mainGUI.initPopupWidget(finishPopup)
			
		}else{
			
			self.abortInstall("An error occured for creating file \(selectedPath) temp/processCheckerInstall.zip")
		}
	}
	
	private func fixInstallDirectory() {
		
		if(selectedPath.characters.count > 0) {
			
			let endIdx = selectedPath.endIndex
			
			/* ## Swift 3
			let _charStartIdx = selectedPath.index(endIdx, offsetBy: -1)
			let _charEndIdx = selectedPath.index(endIdx, offsetBy: 0)
			*/
			let _charStartIdx = endIdx.advancedBy(-1)
			let _charEndIdx = endIdx.advancedBy(0)
			let lastCharacterRange = Range<String.Index>(_charStartIdx..<_charEndIdx)
			let lastCharacter = selectedPath.substringWithRange(lastCharacterRange)
			
			if(lastCharacter != "/") {
				
				selectedPath += "/"
			}
		}
	}
	
	private func abortInstall(message: String) {
		
		self.mainGUI.deinitPopupWidget()
		let errorPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: message, popupButtons: ["Back"], hasShadow: true, popupDelegate: { (selectedChoiceIdx) in
			
			self.mainGUI.deinitPopupWidget()
			self.step2()
			
			}, mainWindow: self.mainGUI.mainWindow)
		self.mainGUI.initPopupWidget(errorPopup)
	}
	
	private func moveDirectory(fromPath: String, toPath: String) throws {
		
		var isDirectory: ObjCBool = true
		let dirExists = NSFileManager.defaultManager().fileExistsAtPath(toPath, isDirectory: &isDirectory)
		if(!dirExists) {
			try NSFileManager.defaultManager().createDirectoryAtPath(toPath, withIntermediateDirectories: false, attributes: nil)
		}
		
		let sourceDirFiles = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(fromPath)
		for sourceFile in sourceDirFiles {
			
			var isDirectory: ObjCBool = false
			let sourceFilePath = fromPath + "/\(sourceFile)"
			let sourceFileExists = NSFileManager.defaultManager().fileExistsAtPath(sourceFilePath, isDirectory: &isDirectory)
			
			if(sourceFileExists) {
				try NSFileManager.defaultManager().moveItemAtPath(sourceFilePath, toPath: "\(toPath)/\(sourceFile)")
			}else{
				try moveDirectory("\(sourceFilePath)", toPath: "\(toPath)/\(sourceFile)")
			}
		}
		
		try NSFileManager.defaultManager().removeItemAtPath(fromPath)
	}
}
