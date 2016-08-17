//
//  Application.swift
//  IORunner
//
//  Created by ilker özcan on 04/07/16.
//
//

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif

import IOIni
import Foundation
import IORunnerExtension
import IOGUI

internal final class Application {
	
	private var logger: Logger!
	private var appConfig: Config
	private var appArguments: Arguments
	
	private var worker: AppWorker!
	private var appExtensions: DynamicLoader!
	private var signalHandler: SignalHandler!
	private var mainGUI: GUIWidgets!
	private var inGuiLoop = false
	private var isModuleWidgetActive = false
	
	init(appConfig: Config, appArguments: Arguments) {
		
		self.appConfig = appConfig
		self.appArguments = appArguments
		
		let currentLogLevel: Int
		if let logLevel = appConfig["Logging"]?["LogLevel"] {
			currentLogLevel = Int(logLevel)!
		}else{
			currentLogLevel = 2
		}
		
		let currentLogFilePath: String
		if let logFile = appConfig["Logging"]?["LogFile"] {
			currentLogFilePath = logFile
		}else{
			currentLogFilePath = "./" + Constants.APP_PACKAGE_NAME + ".log"
		}
		
		let maxLogFileSize: Int
		if let maxSize = appConfig["Logging"]?["MaxLogSize"] {
			maxLogFileSize = Int(maxSize)!
		}else{
			maxLogFileSize = 100000000
		}
		
		do {
			logger = try Logger(logLevel: currentLogLevel, logFilePath: currentLogFilePath, maxLogFileSize: maxLogFileSize, debugMode: appArguments.debug)
			
		} catch Logger.LoggerError.FileIsNotWritable {
			print("Error: Log file is not writable at \(currentLogFilePath).\n")
		#if swift(>=3)
			
			AppExit.Exit(parent: true, status: AppExit.EXIT_STATUS.FAILURE)
		#elseif swift(>=2.2) && os(OSX)
			
			AppExit.Exit(true, status: AppExit.EXIT_STATUS.FAILURE)
		#endif
			return
		} catch Logger.LoggerError.FileSizeTooSmall {
			print("Error: Max log file size \(maxLogFileSize) is too small.\n")
		#if swift(>=3)
			
			AppExit.Exit(parent: true, status: AppExit.EXIT_STATUS.FAILURE)
		#elseif swift(>=2.2) && os(OSX)
			
			AppExit.Exit(true, status: AppExit.EXIT_STATUS.FAILURE)
		#endif
			return
		} catch {
			print("Error: An error occured for opening log file.\n")
		#if swift(>=3)
			
			AppExit.Exit(parent: true, status: AppExit.EXIT_STATUS.FAILURE)
		#elseif swift(>=2.2) && os(OSX)
			
			AppExit.Exit(true, status: AppExit.EXIT_STATUS.FAILURE)
		#endif
			return
		}
		
	#if swift(>=3)
		
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "The main process started.")
	#elseif swift(>=2.2) && os(OSX)
		
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "The main process started.")
	#endif
		
		let currentExtensionDir: String
		if let extensionsDir = appConfig["Extensions"]?["ExtensionsDir"] {
			currentExtensionDir = extensionsDir
		}else{
			print("Could not find ExtensionsDir value in config file.")
		#if swift(>=3)
			
			AppExit.Exit(parent: false, status: AppExit.EXIT_STATUS.FAILURE)
		#elseif swift(>=2.2) && os(OSX)
				
			AppExit.Exit(false, status: AppExit.EXIT_STATUS.FAILURE)
		#endif
			return
		}
		
		let currentPidFile: String
		if let pidFilePath = appConfig["Daemonize"]?["Pid"] {
			currentPidFile = pidFilePath
		}else{
			currentPidFile = "./" + Constants.APP_PACKAGE_NAME + ".pid"
		}
		
		appExtensions = DynamicLoader(logger: logger, extensionsDir: currentExtensionDir, appConfig: appConfig)
		worker = AppWorker(handlers: appExtensions.getLoadedHandlers(), pidFile: currentPidFile, logger: logger, appArguments: appArguments)
		
		if(appArguments.debug || appArguments.textMode) {
		
			if(appArguments.signalName == nil) {
				print("Error: invalid signal!")
			#if swift(>=3)
				
				AppExit.Exit(parent: false, status: AppExit.EXIT_STATUS.FAILURE)
			#elseif swift(>=2.2) && os(OSX)
				
				AppExit.Exit(false, status: AppExit.EXIT_STATUS.FAILURE)
			#endif
			}
			
			switch appArguments.signalName! {
			case "start":
				print("Starting application.")
			#if swift(>=3)
				
				startHandlers(isChildProcess: false)
			#elseif swift(>=2.2) && os(OSX)
				
				startHandlers(false)
			#endif
				print("OK!")
				break
			case "stop":
				print("Stopping application.")
			#if swift(>=3)
				
				stopHandlers(forceStop: false)
			#elseif swift(>=2.2) && os(OSX)
				
				stopHandlers(false)
			#endif
				print("OK!")
				break
			case "restart":
				print("Restarting ....")
			#if swift(>=3)
				
				stopHandlers(forceStop: false)
			#elseif swift(>=2.2) && os(OSX)
				
				stopHandlers(false)
			#endif
				print("Stopped!")
				print("Starting ...")
			#if swift(>=3)
				
				startHandlers(isChildProcess: false)
			#elseif swift(>=2.2) && os(OSX)
				
				startHandlers(false)
			#endif
				print("OK!")
				break
			case "force-stop":
				print("Force stopping application.")
			#if swift(>=3)
				
				stopHandlers(forceStop: true)
			#elseif swift(>=2.2) && os(OSX)
				
				stopHandlers(true)
			#endif
				print("OK!")
				break
			case "environ":
			#if swift(>=3)
			#if os(Linux)
				let environments = ProcessInfo.processInfo().environment
			#else
				let environments = ProcessInfo().environment
			#endif
				if let envSignal = environments["IO_RUNNER_SN"] {
					
					if(envSignal == "child-start") {
						
						startHandlers(isChildProcess: true)
					}
				}else{
				
					logger.writeLog(level: Logger.LogLevels.MINIMAL, message: "Application enviroments could not readed!")
				}
			#else
				
				let environments = NSProcessInfo().environment
				if let envSignal = environments["IO_RUNNER_SN"] {
			
					if(envSignal == "child-start") {
						startHandlers(true)
					}
				}else{
					logger.writeLog(Logger.LogLevels.MINIMAL, message: "Application enviroments could not readed!")
				}
			#endif
				break
			default:
				print("Error: invalid signal \(appArguments.signalName)!")
			#if swift(>=3)
				
				AppExit.Exit(parent: false, status: AppExit.EXIT_STATUS.FAILURE)
			#elseif swift(>=2.2) && os(OSX)
				
				AppExit.Exit(false, status: AppExit.EXIT_STATUS.FAILURE)
			#endif
			}
			
		#if swift(>=3)
			
			AppExit.Exit(parent: true, status: AppExit.EXIT_STATUS.SUCCESS)
		#elseif swift(>=2.2) && os(OSX)
			
			AppExit.Exit(true, status: AppExit.EXIT_STATUS.SUCCESS)
		#endif
		}else{
		
		#if swift(>=3)
			if(appArguments.keepalive){
				
				self.startHandlers(isChildProcess: true)
			}else{
				self.startGUI()
			}
		#else
			self.startGUI()
		#endif
		}
		
	#if swift(>=3)
		
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "The main process stopped.")
	#elseif swift(>=2.2) && os(OSX)
			
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "The main process stopped.")
	#endif
		logger.closeLogFile()
	}

	private func startGUI() {
		
		self.mainGUI = GUIWidgets() { (action) in
			
			#if swift(>=3)
				
				self.setGuiAction(action: action)
			#elseif swift(>=2.2) && os(OSX)
				
				self.setGuiAction(action)
			#endif
		}
		inGuiLoop = true
		onGUI()
	}

	private func startHandlers(isChildProcess: Bool) {
		
		let daemonize: Int
		if let daemonizeStatus = appConfig["Daemonize"]?["Daemonize"] {
			daemonize = Int(daemonizeStatus)!
		}else{
			daemonize = 1
		}
		
		var damonizeMode = false
		if(daemonize == 1 && !appArguments.debug) {
			damonizeMode = true
		}
		
		do {
		#if swift(>=3)
			
			try worker.run(daemonize: damonizeMode, isChildProcess: isChildProcess)
		#elseif swift(>=2.2) && os(OSX)
			
			try worker.run(damonizeMode, isChildProcess: isChildProcess)
		#endif
		} catch AppWorker.AppWorkerError.DaemonizeFailed {
			
			if(appArguments.textMode || appArguments.debug) {
				print("Daemonize failed!")
			#if swift(>=3)
				
				AppExit.Exit(parent: false, status: AppExit.EXIT_STATUS.FAILURE)
			#elseif swift(>=2.2) && os(OSX)
				
				AppExit.Exit(false, status: AppExit.EXIT_STATUS.FAILURE)
			#endif
			}
			
		#if swift(>=3)
			
			logger.writeLog(level: Logger.LogLevels.ERROR, message: "Daemonize failed!")
		#elseif swift(>=2.2) && os(OSX)
			
			logger.writeLog(Logger.LogLevels.ERROR, message: "Daemonize failed!")
		#endif
		} catch AppWorker.AppWorkerError.PidFileExists {
			
			if(appArguments.textMode || appArguments.debug) {
				print("Pid file exists!")
			#if swift(>=3)
				
				AppExit.Exit(parent: false, status: AppExit.EXIT_STATUS.FAILURE)
			#elseif swift(>=2.2) && os(OSX)
				
				AppExit.Exit(false, status: AppExit.EXIT_STATUS.FAILURE)
			#endif
			}
			
		#if swift(>=3)
			
			logger.writeLog(level: Logger.LogLevels.ERROR, message: "Pid file exists!")
		#elseif swift(>=2.2) && os(OSX)
			
			logger.writeLog(Logger.LogLevels.ERROR, message: "Pid file exists!")
		#endif
		} catch AppWorker.AppWorkerError.PidFileIsNotWritable {
			
			if(appArguments.textMode || appArguments.debug) {
				print("Pid file is not writable!")
			#if swift(>=3)
				
				AppExit.Exit(parent: false, status: AppExit.EXIT_STATUS.FAILURE)
			#elseif swift(>=2.2) && os(OSX)
				
				AppExit.Exit(false, status: AppExit.EXIT_STATUS.FAILURE)
			#endif
			}
		#if swift(>=3)
			
			logger.writeLog(level: Logger.LogLevels.ERROR, message: "Pid file is not writable!")
		#elseif swift(>=2.2) && os(OSX)
			
			logger.writeLog(Logger.LogLevels.ERROR, message: "Pid file is not writable!")
		#endif
		} catch _ {
			
			if(appArguments.textMode || appArguments.debug) {
				print("An error occured for running application")
			#if swift(>=3)
				
				AppExit.Exit(parent: false, status: AppExit.EXIT_STATUS.FAILURE)
			#elseif swift(>=2.2) && os(OSX)
					
				AppExit.Exit(false, status: AppExit.EXIT_STATUS.FAILURE)
			#endif
			}
		#if swift(>=3)
			
			logger.writeLog(level: Logger.LogLevels.ERROR, message: "An error occured for running application")
		#elseif swift(>=2.2) && os(OSX)
			
			logger.writeLog(Logger.LogLevels.ERROR, message: "An error occured for running application")
		#endif
		}
	}
	
	private func stopHandlers(forceStop: Bool) {
		
		if(forceStop) {
		#if swift(>=3)
			
			worker.stop(graceful: false)
		#elseif swift(>=2.2) && os(OSX)
			
			worker.stop(false)
		#endif
		}else{
			worker.stop()
		}
	}
	
	private func registerGuiSignals() {
		
		signalHandler = SignalHandler()
	#if swift(>=3)
		
		signalHandler.register(signal: .Interrupt, handleGUIQuit)
		signalHandler.register(signal: .Quit, handleGUIQuit)
		signalHandler.register(signal: .Terminate, handleGUIQuit)
		SignalHandler.registerSignals()
		
		logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Signals registered")
	#elseif swift(>=2.2) && os(OSX)
		
		signalHandler.register(.Interrupt, handleGUIQuit)
		signalHandler.register(.Quit, handleGUIQuit)
		signalHandler.register(.Terminate, handleGUIQuit)
		SignalHandler.registerSignals()
		
		logger.writeLog(Logger.LogLevels.WARNINGS, message: "Signals registered")
	#endif
	}
	
	private func getWorkerStatus() -> UInt {
		
		// 0 running, 1 not running, 2 dead
		if(worker != nil) {
			
			let pidStatus = worker.checkPid()
			if(pidStatus == -1) {
				return 1
			}else{
				if(kill(pidStatus, 0) == 0) {
					return 0
				}else{
					return 2
				}
			}
			
		}else{
			return 1
		}
	}
	
	func handleGUIQuit() {
		inGuiLoop = false
	}
	
	private func setGuiAction(action: MainGuiActions) {
		
		switch action {
		case .EXIT:
			handleGUIQuit()
			break
		case .BACK:
			if(isModuleWidgetActive) {
				
				isModuleWidgetActive = false
				self.mainGUI.deinitModuleWidget()
				guiMainMenu()
			}
		default:
			break
		}
	}
	
	private func generateAppInfoData() -> [GUIAppInfo] {
		
		let appStatus = getWorkerStatus()
		var appInfoData = [GUIAppInfo]()
		switch appStatus {
		case 0:
			appInfoData.append(GUIAppInfo(infoKey: "Status:\t\t", infoVal: "Running", infoType: GUIAppInfo.InfoType.SUCCESS))
			break
		case 1:
			appInfoData.append(GUIAppInfo(infoKey: "Status:\t\t", infoVal: "Not Running", infoType: GUIAppInfo.InfoType.DANGER))
			break
		case 2:
			appInfoData.append(GUIAppInfo(infoKey: "Status:\t\t", infoVal: "Process Dead", infoType: GUIAppInfo.InfoType.DANGER))
			break
		default:
			appInfoData.append(GUIAppInfo(infoKey: "Status:\t\t", infoVal: "Not Determined", infoType: GUIAppInfo.InfoType.NORMAL))
			break
		}
		let loadedModulesInfo = appExtensions.getLoadedModuleInfo()
		appInfoData.append(GUIAppInfo(infoKey: "Modules:\t\t", infoVal: "\(loadedModulesInfo.0)", infoType: GUIAppInfo.InfoType.NORMAL))
		appInfoData.append(GUIAppInfo(infoKey: "Installed Modules:\t", infoVal: "\(loadedModulesInfo.1)", infoType: GUIAppInfo.InfoType.SUCCESS))

		return appInfoData
	}
	
	private func guiMainMenu() {
		
		var choices = [GUIMenuChoices]()
		choices.append(GUIMenuChoices(choiceName: "Start Application", choiceCode: 0))
		choices.append(GUIMenuChoices(choiceName: "Stop Application", choiceCode: 1))
		choices.append(GUIMenuChoices(choiceName: "Restart Application", choiceCode: 2))
		choices.append(GUIMenuChoices(choiceName: "Force Stop Application", choiceCode: 3))
		choices.append(GUIMenuChoices(choiceName: "Module Settings", choiceCode: 4))
		choices.append(GUIMenuChoices(choiceName: "List Config Directives", choiceCode: 5))
		choices.append(GUIMenuChoices(choiceName: "Build Info", choiceCode: 6))
		choices.append(GUIMenuChoices(choiceName: "Version Info", choiceCode: 7))
		choices.append(GUIMenuChoices(choiceName: "Exit", choiceCode: 8))
		
		var startRow = 0
		var widgetSize = 2
		
		if(self.mainGUI.hasTitleWidget()) {
			
			startRow = 2
			widgetSize += (self.mainGUI.titleAndFooter?.widgetRows)!
		#if swift(>=3)
			
			self.mainGUI.titleAndFooter?.updateKeyboardInfo(keyControls: (GUIConstants.MenuButtons, GUIConstants.ArrowsUpDown))
		#elseif swift(>=2.2) && os(OSX)
			
			self.mainGUI.titleAndFooter?.updateKeyboardInfo((GUIConstants.MenuButtons, GUIConstants.ArrowsUpDown))
		#endif
		}
		
		if(self.mainGUI.hasAppInfoWidget()) {
			
			widgetSize += (self.mainGUI.appInfo?.widgetRows)!
		}
		
		let menuWidget = MenuWidget(startRow: startRow, widgetSize: Int(widgetSize), choices: choices, delegate: { (selectedChoiceIdx) in
			
				switch(selectedChoiceIdx) {
				case 0:
					self.startApplicationOnGUI()
					break
				case 1:
					self.stopApplicationOnGUI()
					break
				case 2:
					self.restartApplicationOnGUI()
					break
				case 3:
					self.forceStopApplicationOnGUI()
					break
				case 4:
					self.guiModulesMenu()
				case 5:
					self.generateGuiConfigDirectives()
					break
				case 6:
					var buildString = Constants.APP_NAME + "\n\tOS\t\t: "
					#if os(OSX)
						buildString += "Mac OS X"
					#elseif os(Linux)
						buildString += "Linux"
					#else
						buildString += "Other"
					#endif
				
					buildString += "\n\tArch\t\t: "
					#if arch(x86_64)
						buildString += "x86_64"
					#elseif arch(arm) || arch(arm64)
						buildString += "arm (64)"
					#elseif arch(i386)
						buildString += "i386"
					#else
						buildString += "Other"
					#endif
					
					buildString += "\n\tSwift Version\t: "
					#if swift(>=2.2)
						buildString += ">= 2.2"
					#elseif swift(>=2.0)
						buildString += ">= 2.0"
					#else
						buildString += "Unkown"
					#endif
						
				
					let popup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "\tBuild:\n\t\(buildString)", popupButtons: ["OK"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
						
							self.mainGUI.deinitPopupWidget()
						}, mainWindow: self.mainGUI.mainWindow)
					
				#if swift(>=3)
					
					self.mainGUI.initPopupWidget(widget: popup)
				#elseif swift(>=2.2) && os(OSX)
					
					self.mainGUI.initPopupWidget(popup)
				#endif
					break
				case 7:
					let popup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "\tVersion:\n\t\(Constants.APP_NAME) \(Constants.APP_VERSION)\n\t\(Constants.APP_CREDITS)", popupButtons: ["OK"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
						
							self.mainGUI.deinitPopupWidget()
						}, mainWindow: self.mainGUI.mainWindow)
					
				#if swift(>=3)
					
					self.mainGUI.initPopupWidget(widget: popup)
				#elseif swift(>=2.2) && os(OSX)
						
					self.mainGUI.initPopupWidget(popup)
				#endif
					break
				case 8:
					self.handleGUIQuit()
					break
				default:
					break
				}

			
			}, mainWindow: self.mainGUI.mainWindow)

	#if swift(>=3)
		
		self.mainGUI.initMenuWidget(widget: menuWidget)
	#elseif swift(>=2.2) && os(OSX)
		
		self.mainGUI.initMenuWidget(menuWidget)
	#endif
	}
	
	private func onGUI() {
	
		registerGuiSignals()
		
		let copyrightText = "\(Constants.APP_CREDITS)\t\t\t\tVersion: \(Constants.APP_VERSION)"
		let titleWidget = TitleAndFooterWidget(title: Constants.APP_NAME, copyright: copyrightText, keyControls: (GUIConstants.MenuButtons, GUIConstants.ArrowsUpDown), mainWindow: self.mainGUI.mainWindow)
	#if swift(>=3)
		
		self.mainGUI.initTitleWidget(widget: titleWidget)
	#elseif swift(>=2.2) && os(OSX)
		
		self.mainGUI.initTitleWidget(titleWidget)
	#endif
		
		var startRow = 0
		let appInfoData = generateAppInfoData()
		if(self.mainGUI.hasTitleWidget()) {
			
			startRow += (self.mainGUI.titleAndFooter?.widgetRows)!
		}
		
		startRow += appInfoData.count
		let appInfoWidget = AppInfoWidget(appInfo: appInfoData, startRow: Int32(startRow), mainWindow: self.mainGUI.mainWindow)
	#if swift(>=3)
		
		self.mainGUI.initAppInfoWidget(widget: appInfoWidget)
	#elseif swift(>=2.2) && os(OSX)
		
		self.mainGUI.initAppInfoWidget(appInfoWidget)
	#endif
		
		guiMainMenu()
		
	#if swift(>=3)
		
		var loopStartDate: UInt = UInt(Date().timeIntervalSince1970)
		let runLoop = RunLoop.current()
		
	#if os(Linux)

		repeat {
			
			let _ = signalHandler.process()
			self.mainGUI.onGUI()
			
			let curDate: UInt = UInt(Date().timeIntervalSince1970)
			let dateDif = curDate - loopStartDate
			if(dateDif > 30) {
				loopStartDate = curDate
				
				if(self.mainGUI.hasAppInfoWidget()) {
					
					self.mainGUI.appInfo?.updateAppInfo(appInfo: generateAppInfoData())
				}
			}
			
			usleep(Constants.GuiRefreshRate)
			let _ = runLoop.run(mode: RunLoopMode.defaultRunLoopMode, before: NSDate().addingTimeInterval(-1 * Constants.CpuSleepMsec))
			
		} while (inGuiLoop)
	#else
		
		repeat {
			let _ = signalHandler.process()
			self.mainGUI.onGUI()
			
			let curDate: UInt = UInt(Date().timeIntervalSince1970)
			let dateDif = curDate - loopStartDate
			if(dateDif > 30) {
				logger.writeLog(level: Logger.LogLevels.WARNINGS, message: "Updating info data")
				loopStartDate = curDate
				
				if(self.mainGUI.hasAppInfoWidget()) {
					
					self.mainGUI.appInfo?.updateAppInfo(appInfo: generateAppInfoData())
				}
			}
			
			usleep(Constants.GuiRefreshRate)
			
		} while (inGuiLoop && runLoop.run(mode: RunLoopMode.defaultRunLoopMode, before: Date().addingTimeInterval(-1 * Constants.CpuSleepMsec)))
	#endif
		
		self.mainGUI.exitGui(status: 0)
		
	#else
		
		var loopStartDate: UInt = UInt(NSDate().timeIntervalSince1970)
		let runLoop = NSRunLoop.currentRunLoop()
		repeat {
			let _ = signalHandler.process()
			self.mainGUI.onGUI()
		
			let curDate: UInt = UInt(NSDate().timeIntervalSince1970)
			let dateDif = curDate - loopStartDate
			if(dateDif > 30) {
				logger.writeLog(Logger.LogLevels.WARNINGS, message: "Updating info data")
				loopStartDate = curDate
				
				if(self.mainGUI.hasAppInfoWidget()) {
		
					self.mainGUI.appInfo?.updateAppInfo(generateAppInfoData())
				}
			}
			
			usleep(Constants.GuiRefreshRate)
		
		} while (inGuiLoop && runLoop.runMode(NSDefaultRunLoopMode, beforeDate: NSDate().dateByAddingTimeInterval(-1 * Constants.CpuSleepMsec)))
		
		self.mainGUI.exitGui(0)
	#endif
	}

	private func startApplicationOnGUI() {
		
		let appStatus = self.getWorkerStatus()
		
		if(appStatus == 0) {
			
			let popup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "Warning!\n   Application is already running.", popupButtons: ["OK"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
				
					self.mainGUI.deinitPopupWidget()
				}, mainWindow: self.mainGUI.mainWindow)
			
		#if swift(>=3)
			
			self.mainGUI.initPopupWidget(widget: popup)
		#elseif swift(>=2.2) && os(OSX)
			
			self.mainGUI.initPopupWidget(popup)
		#endif
		}else if(appStatus == 1) {
			
			let popup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "Are you sure want to START application ?", popupButtons: ["No", "Yes"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
				
				
				if(selectedChoiceIdx == 1) {
					
					self.mainGUI.deinitPopupWidget()
				#if swift(>=3)
					
					self.startHandlers(isChildProcess: false)
				#elseif swift(>=2.2) && os(OSX)
					
					self.startHandlers(false)
				#endif
					
					let waitPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.SYNC_WAIT, popupContent: "Please wait ...", popupButtons: [], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
						
						}, mainWindow: self.mainGUI.mainWindow)
				#if swift(>=3)
					
					self.mainGUI.initPopupWidget(widget: waitPopup)
					self.mainGUI.waitPopup(waitForSecond: 5)
				#elseif swift(>=2.2) && os(OSX)
					
					self.mainGUI.initPopupWidget(waitPopup)
					self.mainGUI.waitPopup(5)
				#endif
					
					self.mainGUI.deinitPopupWidget()
					
					let endPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "Application started!", popupButtons: ["OK"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
						
							self.mainGUI.deinitPopupWidget()
							if(self.mainGUI.hasAppInfoWidget()) {
							#if swift(>=3)
								
								self.mainGUI.appInfo?.updateAppInfo(appInfo: self.generateAppInfoData())
							#elseif swift(>=2.2) && os(OSX)
								
								self.mainGUI.appInfo?.updateAppInfo(self.generateAppInfoData())
							#endif
							}
						
						}, mainWindow: self.mainGUI.mainWindow)
					
				#if swift(>=3)
					
					self.mainGUI.initPopupWidget(widget: endPopup)
				#elseif swift(>=2.2) && os(OSX)
					
					self.mainGUI.initPopupWidget(endPopup)
				#endif
				}else{
					self.mainGUI.deinitPopupWidget()
				}
				
				}, mainWindow: self.mainGUI.mainWindow)
			
		#if swift(>=3)
			
			self.mainGUI.initPopupWidget(widget: popup)
		#elseif swift(>=2.2) && os(OSX)
			
			self.mainGUI.initPopupWidget(popup)
		#endif
			
		}else{
			
			let popup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "Warning!\n   Application is not running but pid file exists.\nUse force stop option.", popupButtons: ["OK"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
				
				self.mainGUI.deinitPopupWidget()
				}, mainWindow: self.mainGUI.mainWindow)
			
		#if swift(>=3)
			
			self.mainGUI.initPopupWidget(widget: popup)
		#elseif swift(>=2.2) && os(OSX)
			
			self.mainGUI.initPopupWidget(popup)
		#endif
		}
	}
	
	private func stopApplicationOnGUI() {
		
		let appStatus = self.getWorkerStatus()
		
		if(appStatus == 0) {
			
			let popup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "Are you sure want to STOP application ?", popupButtons: ["No", "Yes"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
				
				if(selectedChoiceIdx == 1) {
					
					self.mainGUI.deinitPopupWidget()
				#if swift(>=3)
					
					self.stopHandlers(forceStop: false)
				#elseif swift(>=2.2) && os(OSX)
					
					self.stopHandlers(false)
				#endif
					let waitPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.SYNC_WAIT, popupContent: "Please wait ...", popupButtons: [], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
						
						}, mainWindow: self.mainGUI.mainWindow)
				#if swift(>=3)
					
					self.mainGUI.initPopupWidget(widget: waitPopup)
					self.mainGUI.waitPopup(waitForSecond: 5)
				#elseif swift(>=2.2) && os(OSX)
					
					self.mainGUI.initPopupWidget(waitPopup)
					self.mainGUI.waitPopup(5)
				#endif
					
					self.mainGUI.deinitPopupWidget()
					
					let resultPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "Application stopped!", popupButtons: ["OK"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
						
						self.mainGUI.deinitPopupWidget()
						if(self.mainGUI.hasAppInfoWidget()) {
							
						#if swift(>=3)
							
							self.mainGUI.appInfo?.updateAppInfo(appInfo: self.generateAppInfoData())
						#elseif swift(>=2.2) && os(OSX)
							
							self.mainGUI.appInfo?.updateAppInfo(self.generateAppInfoData())
						#endif
						}
						
						}, mainWindow: self.mainGUI.mainWindow)
					
				#if swift(>=3)
					
					self.mainGUI.initPopupWidget(widget: resultPopup)
				#elseif swift(>=2.2) && os(OSX)
					
					self.mainGUI.initPopupWidget(resultPopup)
				#endif
				}else{
					self.mainGUI.deinitPopupWidget()
				}
				
				}, mainWindow: self.mainGUI.mainWindow)
			
		#if swift(>=3)
			
			self.mainGUI.initPopupWidget(widget: popup)
		#elseif swift(>=2.2) && os(OSX)
			
			self.mainGUI.initPopupWidget(popup)
		#endif
			
		}else if(appStatus == 1) {
			
			let popup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "Warning!\n   Application is not running.", popupButtons: ["OK"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
				
				self.mainGUI.deinitPopupWidget()
				
				}, mainWindow: self.mainGUI.mainWindow)
		#if swift(>=3)
			
			self.mainGUI.initPopupWidget(widget: popup)
		#elseif swift(>=2.2) && os(OSX)
			
			self.mainGUI.initPopupWidget(popup)
		#endif
		}else{
			
			let popup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "Warning!\n   Application is not running but pid file exists.\nUse force stop option.", popupButtons: ["OK"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
				
				self.mainGUI.deinitPopupWidget()
				
				}, mainWindow: self.mainGUI.mainWindow)
			
		#if swift(>=3)
			
			self.mainGUI.initPopupWidget(widget: popup)
		#elseif swift(>=2.2) && os(OSX)
			
			self.mainGUI.initPopupWidget(popup)
		#endif
		}
	}
	
	private func restartApplicationOnGUI() {
		
		let appStatus = self.getWorkerStatus()
		
		if(appStatus == 0) {
			
			let popup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "Are you sure want to RE-START application ?", popupButtons: ["No", "Yes"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
				
				if(selectedChoiceIdx == 1) {
					
					self.mainGUI.deinitPopupWidget()
				#if swift(>=3)
					
					self.stopHandlers(forceStop: false)
				#elseif swift(>=2.2) && os(OSX)
					
					self.stopHandlers(false)
				#endif
					
					let waitPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.SYNC_WAIT, popupContent: "Please wait ...", popupButtons: [], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
						}, mainWindow: self.mainGUI.mainWindow)
				#if swift(>=3)
					
					self.mainGUI.initPopupWidget(widget: waitPopup)
					
					self.mainGUI.waitPopup(waitForSecond: 5)
					self.startHandlers(isChildProcess: false)
					self.mainGUI.waitPopup(waitForSecond: 5)
				#elseif swift(>=2.2) && os(OSX)
						
					self.mainGUI.initPopupWidget(waitPopup)
					
					self.mainGUI.waitPopup(5)
					self.startHandlers(false)
					self.mainGUI.waitPopup(5)
				#endif
			
					self.mainGUI.deinitPopupWidget()
					self.mainGUI.waitPopup(waitForSecond: 1)
					
					let resultPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.SYNC_WAIT, popupContent: "Application restarted!", popupButtons: ["OK"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
						
						self.mainGUI.deinitPopupWidget()
						
						if(self.mainGUI.hasAppInfoWidget()) {
							
						#if swift(>=3)
							
							self.mainGUI.appInfo?.updateAppInfo(appInfo: self.generateAppInfoData())
						#elseif swift(>=2.2) && os(OSX)
							
							self.mainGUI.appInfo?.updateAppInfo(self.generateAppInfoData())
						#endif
						}
						
						}, mainWindow: self.mainGUI.mainWindow)
					
				#if swift(>=3)
					
					self.mainGUI.initPopupWidget(widget: resultPopup)
				#elseif swift(>=2.2) && os(OSX)
					
					self.mainGUI.initPopupWidget(resultPopup)
				#endif
					
				}else{
					self.mainGUI.deinitPopupWidget()
				}
				
				}, mainWindow: self.mainGUI.mainWindow)
			
		#if swift(>=3)
			
			self.mainGUI.initPopupWidget(widget: popup)
		#elseif swift(>=2.2) && os(OSX)
			
			self.mainGUI.initPopupWidget(popup)
		#endif
		}else if(appStatus == 1) {
			
			let popup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "Warning!\n   Application is not running.", popupButtons: ["OK"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
				
				self.mainGUI.deinitPopupWidget()
				
				}, mainWindow: self.mainGUI.mainWindow)
			
		#if swift(>=3)
			
			self.mainGUI.initPopupWidget(widget: popup)
		#elseif swift(>=2.2) && os(OSX)
			
			self.mainGUI.initPopupWidget(popup)
		#endif
		}else{
			
			let popup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "Warning!\n   Application is not running but pid file exists.\nUse force stop option.", popupButtons: ["OK"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
				
				self.mainGUI.deinitPopupWidget()
				
				}, mainWindow: self.mainGUI.mainWindow)
		#if swift(>=3)
			
			self.mainGUI.initPopupWidget(widget: popup)
		#elseif swift(>=2.2) && os(OSX)
			
			self.mainGUI.initPopupWidget(popup)
		#endif
		}
	}
	
	private func forceStopApplicationOnGUI() {
		
		let popup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "Are you sure want to FORCE-STOP application ?", popupButtons: ["No", "Yes"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
			
			if(selectedChoiceIdx == 1) {
				
				self.mainGUI.deinitPopupWidget()
			#if swift(>=3)
				
				self.stopHandlers(forceStop: true)
			#elseif swift(>=2.2) && os(OSX)
				
				self.stopHandlers(true)
			#endif
				
				let waitPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.SYNC_WAIT, popupContent: "Please wait ...", popupButtons: [], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
					}, mainWindow: self.mainGUI.mainWindow)
			#if swift(>=3)
				
				self.mainGUI.initPopupWidget(widget: waitPopup)
				self.mainGUI.waitPopup(waitForSecond: 5)
			#elseif swift(>=2.2) && os(OSX)
				
				self.mainGUI.initPopupWidget(waitPopup)
				self.mainGUI.waitPopup(5)
			#endif
				
				self.mainGUI.deinitPopupWidget()
				
				let resultPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "Application stopped!", popupButtons: ["OK"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
					
					self.mainGUI.deinitPopupWidget()
					if(self.mainGUI.hasAppInfoWidget()) {
					#if swift(>=3)
						
						self.mainGUI.appInfo?.updateAppInfo(appInfo: self.generateAppInfoData())
					#elseif swift(>=2.2) && os(OSX)
						
						self.mainGUI.appInfo?.updateAppInfo(self.generateAppInfoData())
					#endif
					}
					
					}, mainWindow: self.mainGUI.mainWindow)
			#if swift(>=3)
				
				self.mainGUI.initPopupWidget(widget: resultPopup)
			#elseif swift(>=2.2) && os(OSX)
				
				self.mainGUI.initPopupWidget(resultPopup)
			#endif
				
			}else{
				self.mainGUI.deinitPopupWidget()
			}
			
			}, mainWindow: self.mainGUI.mainWindow)
	#if swift(>=3)
		
		self.mainGUI.initPopupWidget(widget: popup)
	#elseif swift(>=2.2) && os(OSX)
		
		self.mainGUI.initPopupWidget(popup)
	#endif
	}
	
	private func generateGuiConfigDirectives() {
		
		
		var choices = [GUIMenuChoices]()
		
		var menuIdx = 1
		for sectionIdx in 0..<self.appConfig.sections.count {
			
			let sectionData = self.appConfig.sections[sectionIdx]
			choices.append(GUIMenuChoices(choiceName: "[\(sectionData.name)]", choiceCode: menuIdx))
			menuIdx += 1
			
			for sectionConfig in sectionData.settings {
				
				choices.append(GUIMenuChoices(choiceName: " \(sectionConfig.0)", choiceCode: menuIdx))
				menuIdx += 1
				choices.append(GUIMenuChoices(choiceName: "   \(sectionConfig.1)", choiceCode: menuIdx))
				menuIdx += 1
			}
			
			choices.append(GUIMenuChoices(choiceName: " ", choiceCode: menuIdx))
			menuIdx += 1
		}
		
		choices.append(GUIMenuChoices(choiceName: "BACK TO THE MAIN MENU", choiceCode: 0))
		
		self.mainGUI.deinitMenuWidget()
		
		var startRow = 0
		var widgetSize = 2
		
		if(self.mainGUI.hasTitleWidget()) {
			
			startRow = 2
			widgetSize += (self.mainGUI.titleAndFooter?.widgetRows)!
		#if swift(>=3)
			
			self.mainGUI.titleAndFooter?.updateKeyboardInfo(keyControls: (GUIConstants.MenuButtons, GUIConstants.ArrowsUpDown))
		#elseif swift(>=2.2) && os(OSX)
			
			self.mainGUI.titleAndFooter?.updateKeyboardInfo((GUIConstants.MenuButtons, GUIConstants.ArrowsUpDown))
		#endif
		}
		
		if(self.mainGUI.hasAppInfoWidget()) {
			
			widgetSize += (self.mainGUI.appInfo?.widgetRows)!
		}
		
		let menuWidget = MenuWidget(startRow: startRow, widgetSize: widgetSize, choices: choices, delegate: { (selectedChoiceIdx) in
			
			self.mainGUI.deinitMenuWidget()
			self.guiMainMenu()
			
			}, mainWindow: self.mainGUI.mainWindow)
	#if swift(>=3)
		
		self.mainGUI.initMenuWidget(widget: menuWidget)
	#elseif swift(>=2.2) && os(OSX)
		
		self.mainGUI.initMenuWidget(menuWidget)
	#endif
	}
	
	private func guiModulesMenu() {
		
		var choices = [GUIModulesChoices]()
		let moduleList = self.appExtensions.getModulesList()
		
		
		var choiceIdx = 0
		for module in moduleList {
			
			choices.append(GUIModulesChoices(choiceName: module.0, choiceCode: choiceIdx, isActive: module.1))
			choiceIdx += 1
		}
		
		self.mainGUI.deinitMenuWidget()
		isModuleWidgetActive = true
		var startRow = 0
		var widgetSize = 2
		
		if(self.mainGUI.hasTitleWidget()) {
			
			startRow = 2
			widgetSize += (self.mainGUI.titleAndFooter?.widgetRows)!
		#if swift(>=3)
			
			self.mainGUI.titleAndFooter?.updateKeyboardInfo(keyControls: (GUIConstants.ModuleButtons, GUIConstants.ArrowsAll))
		#elseif swift(>=2.2) && os(OSX)
			
			self.mainGUI.titleAndFooter?.updateKeyboardInfo((GUIConstants.ModuleButtons, GUIConstants.ArrowsAll))
		#endif
		}
		
		if(self.mainGUI.hasAppInfoWidget()) {
			
			widgetSize += (self.mainGUI.appInfo?.widgetRows)!
		}
		
		
		let modulesWidget = ModulesWidget(startRow: startRow, widgetSize: widgetSize, leftSideTitle: "Installed Modules", rightSideTitle: "Available modules", choices: choices, delegate: { (selectedChoiceIdx, isActive) in
			
			if(selectedChoiceIdx == -1) {
				return
			}
			
			if(isActive) {
				
				let popup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "Are you sure want to REMOVE this module ?", popupButtons: ["No", "Yes"], hasShadow: false, popupDelegate: { (popupSelectedChoiceIdx) in
					
					self.mainGUI.deinitPopupWidget()
					if(popupSelectedChoiceIdx == 1) {
						
					#if swift(>=3)

						if(self.appExtensions.deactivateModule(moduleIdx: selectedChoiceIdx)) {
							
							let subPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "   Module removed!\n   Changes will be save when application restarted.", popupButtons: ["OK"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
								self.mainGUI.deinitPopupWidget()
								}, mainWindow: self.mainGUI.mainWindow)
							self.mainGUI.initPopupWidget(widget: subPopup)
							
							if(self.mainGUI.hasModuleWidget()) {
								
								var choices = [GUIModulesChoices]()
								let moduleList = self.appExtensions.getModulesList()
								
								
								var choiceIdx = 0
								for module in moduleList {
									
									choices.append(GUIModulesChoices(choiceName: module.0, choiceCode: choiceIdx, isActive: module.1))
									choiceIdx += 1
								}
								
								self.mainGUI.modules?.updateModuleList(modules: choices)
							}
							
						}else{
							let subPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "An error occured for deactivating module.", popupButtons: ["OK"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
								self.mainGUI.deinitPopupWidget()
								}, mainWindow: self.mainGUI.mainWindow)
							self.mainGUI.initPopupWidget(widget: subPopup)
						}
					#elseif swift(>=2.2) && os(OSX)
						
						if(self.appExtensions.deactivateModule(selectedChoiceIdx)) {
							
							let subPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "   Module removed!\n   Changes will be save when application restarted.", popupButtons: ["OK"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
								self.mainGUI.deinitPopupWidget()
								}, mainWindow: self.mainGUI.mainWindow)
							self.mainGUI.initPopupWidget(subPopup)
							
							if(self.mainGUI.hasModuleWidget()) {
								
								var choices = [GUIModulesChoices]()
								let moduleList = self.appExtensions.getModulesList()
								
								
								var choiceIdx = 0
								for module in moduleList {
									
									choices.append(GUIModulesChoices(choiceName: module.0, choiceCode: choiceIdx, isActive: module.1))
									choiceIdx += 1
								}
								
								self.mainGUI.modules?.updateModuleList(choices)
							}
							
						}else{
							let subPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "An error occured for deactivating module.", popupButtons: ["OK"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
								self.mainGUI.deinitPopupWidget()
								}, mainWindow: self.mainGUI.mainWindow)
							self.mainGUI.initPopupWidget(subPopup)
						}
					#endif
					}
					
					}, mainWindow: self.mainGUI.mainWindow)
			#if swift(>=3)
				
				self.mainGUI.initPopupWidget(widget: popup)
			#elseif swift(>=2.2) && os(OSX)
					
				self.mainGUI.initPopupWidget(popup)
			#endif
			}else{

				let popup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "Are you sure want to INSTALL this module ?", popupButtons: ["No", "Yes"], hasShadow: false, popupDelegate: { (popupSelectedChoiceIdx) in
					
					self.mainGUI.deinitPopupWidget()
					if(popupSelectedChoiceIdx == 1) {
						
					#if swift(>=3)
						
						if(self.appExtensions.activateModule(moduleIdx: selectedChoiceIdx)) {
							
							let subPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "   Module installed!\n   Changes will be save when application restarted.", popupButtons: ["OK"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
								self.mainGUI.deinitPopupWidget()
								}, mainWindow: self.mainGUI.mainWindow)
						
							self.mainGUI.initPopupWidget(widget: subPopup)
							
							if(self.mainGUI.hasModuleWidget()) {
								
								var choices = [GUIModulesChoices]()
								let moduleList = self.appExtensions.getModulesList()
								
								
								var choiceIdx = 0
								for module in moduleList {
									
									choices.append(GUIModulesChoices(choiceName: module.0, choiceCode: choiceIdx, isActive: module.1))
									choiceIdx += 1
								}
								
								self.mainGUI.modules?.updateModuleList(modules: choices)
							}
							
						}else{
							let subPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "An error occured for activating module.", popupButtons: ["OK"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
								self.mainGUI.deinitPopupWidget()
								}, mainWindow: self.mainGUI.mainWindow)
							
								self.mainGUI.initPopupWidget(widget: subPopup)
						}
					#elseif swift(>=2.2) && os(OSX)
						
						if(self.appExtensions.activateModule(selectedChoiceIdx)) {
							
							let subPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "   Module installed!\n   Changes will be save when application restarted.", popupButtons: ["OK"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
								self.mainGUI.deinitPopupWidget()
								}, mainWindow: self.mainGUI.mainWindow)

							self.mainGUI.initPopupWidget(subPopup)
							
							if(self.mainGUI.hasModuleWidget()) {
								
								var choices = [GUIModulesChoices]()
								let moduleList = self.appExtensions.getModulesList()
								
								
								var choiceIdx = 0
								for module in moduleList {
									
									choices.append(GUIModulesChoices(choiceName: module.0, choiceCode: choiceIdx, isActive: module.1))
									choiceIdx += 1
								}
								
								self.mainGUI.modules?.updateModuleList(choices)
							}
							
						}else{
							let subPopup = PopupWidget(popuptype: PopupWidget.GUIPopupTypes.CONFIRM, popupContent: "An error occured for activating module.", popupButtons: ["OK"], hasShadow: false, popupDelegate: { (selectedChoiceIdx) in
								self.mainGUI.deinitPopupWidget()
								}, mainWindow: self.mainGUI.mainWindow)
						
							
							self.mainGUI.initPopupWidget(subPopup)
						}
					#endif
					}
					
					}, mainWindow: self.mainGUI.mainWindow)
			#if swift(>=3)
				
				self.mainGUI.initPopupWidget(widget: popup)
			#elseif swift(>=2.2) && os(OSX)
				
				self.mainGUI.initPopupWidget(popup)
			#endif
			}
			
			}, mainWindow: self.mainGUI.mainWindow)
	#if swift(>=3)
		
		self.mainGUI.initModuleWidget(widget: modulesWidget)
	#elseif swift(>=2.2) && os(OSX)
		
		self.mainGUI.initModuleWidget(modulesWidget)
	#endif
	}
}
