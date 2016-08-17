//
//  NginxHandler.swift
//  IORunner/Extensions/NginxHandler
//
//  Created by ilker özcan on 10/08/16.
//
//

import Foundation
import IOIni
import IORunnerExtension

public class NginxHandler: AppHandlers {

	private var processStatus: [Int] = [Int]()
	private var checkingFrequency: Int = 60
#if swift(>=3)
	private var lastCheckDate: Date?
#endif
	
	public required init(logger: Logger, moduleConfig: Section?) {

		super.init(logger: logger, moduleConfig: moduleConfig)
		
		if let currentProcessFrequency = moduleConfig?["ProcessFrequency"] {
		
			if let frequencyInt = Int(currentProcessFrequency) {
				
				self.checkingFrequency = frequencyInt
			}
		}
	}

	public override func forStart() {
		
		if(!self.checkNginxProcess()) {
			
			self.restartNginx()
		}
	}

	public override func inLoop() {
		
	#if swift(>=3)
	
		if(lastCheckDate != nil) {
			
			let currentDate = Int(Date().timeIntervalSince1970)
			let lastCheckDif = currentDate - Int(lastCheckDate!.timeIntervalSince1970)
			
			if(lastCheckDif >= self.checkingFrequency) {
				
				if(!self.checkNginxProcess()) {
					
					self.restartNginx()
				}
			}
		}
	#endif
	}

	private func checkNginxProcess() -> Bool {
		
		if let currentProcessName = moduleConfig?["ProcessName"] {
		#if swift(>=3)
			self.processStatus = self.checkProcess(processName: currentProcessName)
			self.lastCheckDate = Date()
			if(self.processStatus.count > 0) {
				return true
			}else{
				
				self.logger.writeLog(level: Logger.LogLevels.ERROR, message: "Warning Process NGINX does not working!")
				return false
			}
		#endif
		}
		
		return true
	}
	
	private func restartNginx() {
	#if swift(>=3)
		self.logger.writeLog(level: Logger.LogLevels.ERROR, message: "Restarting NGINX ...")
			
		if let processStopCommand = moduleConfig?["ProcessStopCommand"] {
				
			self.executeTask(command: processStopCommand)
		}
			
		if let processStartCommand = moduleConfig?["ProcessStartCommand"] {
				
			self.executeTask(command: processStartCommand)
		}
	#endif
	}
}

