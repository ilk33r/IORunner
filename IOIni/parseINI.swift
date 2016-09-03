//
//  parseINI.swift
//  IORunner/IOIni
//
//  Created by ilker özcan on 22/07/16.
//
//

import Foundation

public struct Section {
	
	public let name: String
	public let settings: [String: String]
	
	init(name: String, settings: [String: String]) {
		self.name = name
		self.settings = settings
	}
	
	public subscript(key: String) -> String? {
		return settings[key]
	}
	
	public func bool(key: String) -> Bool {
		return ["1", "true", "yes"].contains(settings[key] ?? "")
	}
}

public struct Config {
	
	public let sections: [Section]
	
	public subscript(key: String) -> Section? {
		return sections.filter { $0.name == key }.first
	}
}

public class parseINI {
	
	var iniString: String
	var configData: Config? = nil
	
	private enum INI_TOKENS: Character {
		
		case SECTION_START = "["
		case SECTION_END = "]"
		case EMPTY_SPACE = " "
		case EMPTY_LINE = "\n"
		case EMPTY_CR = "\r"
		case EMPTY_TAB = "\t"
		case COMMENT_START = ";"
		case VALUE_START = "="
		case STRING_VALUE_ESCAPE = "\""
	}
	
	private enum SCAN_STATUS {
		
		case INITIAL_STATE
		case SCANING_SECTION_NAME
		case SCANNED_SECTION_NAME
		case SCANNING_KEY
		case SCANNED_KEY
		case SCANNING_VALUE
		case SCANNED_VALUE
		case SCANNING_VALUE_WITH_ESCAPE
		case SCANNED_VALUE_WITH_ESCAPE
		case SCANNING_COMMENT
	}
	
	private var currentScanning = SCAN_STATUS.INITIAL_STATE
	private var lastSectionName: String = ""
	private var lastKey: String?
	private var lastValue: String?
	private var currentLine = 0
	private var currentSection = 0
	private var scannedSectionCount = -1
	private var currentScanningSection = 0
	
	public init (withString string: String) throws {
	
		self.iniString = string
		try self.parseData()
	}
	
	public init (withFile filename: String) throws {
		
		#if os(Linux)
			let configFileLinuxContent = try NSString(contentsOfFile: filename, encoding: String.Encoding.utf8.rawValue)
			self.iniString = String(describing: configFileLinuxContent)
		#else
			self.iniString = try String(contentsOfFile: filename)
		#endif

		try self.parseData()
	}
	
	private func parseData() throws {
		
		if(iniString.characters.count > 0) {
		
			var sections = [Section]()
			var currentSettings: [String: String]?
			
			for character in iniString.characters {
				
				self.currentSection += 1
				
				switch currentScanning {
				case .SCANING_SECTION_NAME:
					
					if(currentSettings == nil) {
						
						currentSettings = [String: String]()
					}else{
						
						if(lastSectionName.characters.count > 0 && currentSettings != nil && scannedSectionCount > currentScanningSection) {
							
							self.currentScanningSection += 1
							sections.append(Section(name: lastSectionName, settings: currentSettings!))
							currentSettings = [String: String]()
							lastSectionName = ""
						}
					}
					break
				case .SCANNED_SECTION_NAME:
					
					currentScanning = SCAN_STATUS.INITIAL_STATE
					break
				case .SCANNED_KEY:
					
					currentScanning = SCAN_STATUS.INITIAL_STATE
					break
				case .SCANNED_VALUE:
					
					if(currentSettings == nil) {
						
						throw ParseError.UnsupportedToken(err: "INI Parse error on line \(currentLine + 1) Section \(currentSection)")
					}else{
						
						currentSettings![lastKey!] = lastValue!
						lastKey = nil
						lastValue = nil
						currentScanning = SCAN_STATUS.INITIAL_STATE
					}
					break
				case .SCANNED_VALUE_WITH_ESCAPE:
					
					if(currentSettings == nil) {
						
						throw ParseError.UnsupportedToken(err: "INI Parse error on line \(currentLine + 1) Section \(currentSection)")
					}else{
						currentSettings![lastKey!] = lastValue!
						lastKey = nil
						lastValue = nil
						currentScanning = SCAN_STATUS.INITIAL_STATE
					}
					break
				default:
					// pass
					break
				}
				
			#if swift(>=3)
				try updateScanStatus(scannedCharacter: character)
			#elseif swift(>=2.2) && os(OSX)
				try updateScanStatus(character)
			#endif
			}
			
			if(currentSettings == nil) {
				
				throw ParseError.UnsupportedToken(err: "INI Parse error. Unresolved error!")
			}else{
			
				if(lastKey != nil && lastValue != nil) {
					
					currentSettings![lastKey!] = lastValue!
					lastKey = nil
					lastValue = nil
					currentScanning = SCAN_STATUS.INITIAL_STATE
				}
				
				if(lastSectionName.characters.count > 0 && currentSettings != nil) {
					
					sections.append(Section(name: lastSectionName, settings: currentSettings!))
					lastSectionName = ""
				}
			}
			
			self.configData = Config(sections: sections)
		}else{
			throw ParseError.UnsupportedToken(err: "INI Parse error. File or String is empty.")
		}
	}
	
	private func updateScanStatus(scannedCharacter: Character) throws {
		
		switch scannedCharacter {
		case INI_TOKENS.SECTION_START.rawValue:
			
			if(self.currentScanning == SCAN_STATUS.INITIAL_STATE) {
				
				self.scannedSectionCount += 1
				self.currentScanning = SCAN_STATUS.SCANING_SECTION_NAME
			}else{
				
				if(self.currentScanning == SCAN_STATUS.SCANNING_VALUE_WITH_ESCAPE) {
					
					lastValue! += "\(scannedCharacter)"
				}else{
				
					if(self.currentScanning != SCAN_STATUS.INITIAL_STATE && self.currentScanning != SCAN_STATUS.SCANNING_COMMENT) {
						
						throw ParseError.InvalidSyntax(err: "INI Syntax error. Line \(currentLine + 1) Section \(currentSection)")
					}
				}
			}
			break
		case INI_TOKENS.SECTION_END.rawValue:
			
			if(self.currentScanning == SCAN_STATUS.SCANING_SECTION_NAME) {
				
				self.currentScanning = SCAN_STATUS.SCANNED_SECTION_NAME
			}else{
				
				if(self.currentScanning == SCAN_STATUS.SCANNING_VALUE_WITH_ESCAPE) {
					
					lastValue! += "\(scannedCharacter)"
				}else{
					
					if(self.currentScanning != SCAN_STATUS.INITIAL_STATE && self.currentScanning != SCAN_STATUS.SCANNING_COMMENT) {
						
						throw ParseError.InvalidSyntax(err: "INI Syntax error. Line \(currentLine + 1) Section \(currentSection)")
					}
				}
			}
			break
		case INI_TOKENS.EMPTY_SPACE.rawValue:
			
			if(self.currentScanning == SCAN_STATUS.SCANING_SECTION_NAME) {
				
				if(self.lastSectionName.characters.count > 0) {
					self.currentScanning = SCAN_STATUS.SCANNED_SECTION_NAME
				}
			}else if(self.currentScanning == SCAN_STATUS.SCANNING_KEY) {
				
				if(self.lastKey != nil && (self.lastKey?.characters.count)! > 0) {
					self.currentScanning = SCAN_STATUS.SCANNED_KEY
				}
			}else if(self.currentScanning == SCAN_STATUS.SCANNING_VALUE) {
			
				if(self.lastValue != nil && (self.lastValue?.characters.count)! > 0) {
					self.currentScanning = SCAN_STATUS.SCANNED_VALUE
				}
			}else if(self.currentScanning == SCAN_STATUS.SCANNING_VALUE_WITH_ESCAPE) {
				
				lastValue! += "\(scannedCharacter)"
			}
			break
		case INI_TOKENS.EMPTY_LINE.rawValue:
			
			if(self.currentScanning == SCAN_STATUS.INITIAL_STATE) {
				
				currentLine += 1
				currentSection = 0
			}else if(self.currentScanning == SCAN_STATUS.SCANNING_VALUE) {
				
				if(self.lastValue != nil && (self.lastValue?.characters.count)! > 0) {
					currentLine += 1
					currentSection = 0
					self.currentScanning = SCAN_STATUS.SCANNED_VALUE
				}else{
					throw ParseError.UnsupportedToken(err: "INI Parse error on Line \(currentLine + 1) Section \(currentSection)")
				}
			}else if(self.currentScanning == SCAN_STATUS.SCANNING_COMMENT) {
				
				currentLine += 1
				currentSection = 0
				self.currentScanning = SCAN_STATUS.INITIAL_STATE
			}else{
				throw ParseError.UnsupportedToken(err: "INI Parse error on Line \(currentLine + 1) Section \(currentSection)")
			}
			break
		case INI_TOKENS.EMPTY_CR.rawValue:
			
			if(self.currentScanning == SCAN_STATUS.SCANNING_VALUE) {
				
				if(self.lastValue != nil && (self.lastValue?.characters.count)! > 0) {
					currentLine += 1
					currentSection = 0
					self.currentScanning = SCAN_STATUS.SCANNED_VALUE
				}else{
					throw ParseError.UnsupportedToken(err: "INI Parse error on Line \(currentLine + 1) Section \(currentSection)")
				}
			}else{
				throw ParseError.UnsupportedToken(err: "INI Parse error on Line \(currentLine + 1) Section \(currentSection)")
			}
			break
		case INI_TOKENS.EMPTY_TAB.rawValue:
			
			if(self.currentScanning == SCAN_STATUS.INITIAL_STATE) {
				
				// pass
			}else if(self.currentScanning == SCAN_STATUS.SCANING_SECTION_NAME) {
				
				if(self.lastSectionName.characters.count > 0) {
					self.currentScanning = SCAN_STATUS.SCANNED_SECTION_NAME
				}
			}else if(self.currentScanning == SCAN_STATUS.SCANNING_KEY) {
				
				if(self.lastKey != nil && (self.lastKey?.characters.count)! > 0) {
					self.currentScanning = SCAN_STATUS.SCANNED_KEY
				}
			}else if(self.currentScanning == SCAN_STATUS.SCANNING_VALUE) {
				
				if(self.lastValue != nil && (self.lastValue?.characters.count)! > 0) {
					self.currentScanning = SCAN_STATUS.SCANNED_VALUE
				}
				
			}else if(self.currentScanning == SCAN_STATUS.SCANNING_VALUE_WITH_ESCAPE) {
				
				self.lastValue! += "\(scannedCharacter)"
			}else{
				throw ParseError.UnsupportedToken(err: "INI Parse error on Line \(currentLine + 1) Section \(currentSection)")
			}
			break
		case INI_TOKENS.COMMENT_START.rawValue:
			
			if(self.currentScanning == SCAN_STATUS.INITIAL_STATE) {
				
				self.currentScanning = SCAN_STATUS.SCANNING_COMMENT
			}else if(self.currentScanning == SCAN_STATUS.SCANNING_VALUE_WITH_ESCAPE) {
				
				self.lastValue! += "\(scannedCharacter)"
			}else{
				
				throw ParseError.UnsupportedToken(err: "INI Parse error on Line \(currentLine + 1) Section \(currentSection)")
			}
			break
		case INI_TOKENS.VALUE_START.rawValue:
			
			if(self.currentScanning == SCAN_STATUS.SCANNING_VALUE_WITH_ESCAPE) {
			
				self.lastValue! += "\(scannedCharacter)"
			}else{
				if(self.lastKey != nil && (self.lastKey?.characters.count)! > 0) {
				
					self.lastValue = ""
					self.currentScanning = SCAN_STATUS.SCANNING_VALUE
				}else{
				
					if(self.currentScanning != SCAN_STATUS.SCANNING_COMMENT) {
						throw ParseError.UnsupportedToken(err: "INI Parse error on Line \(currentLine + 1) Section \(currentSection)")
					}
				}
			}
			break
		case INI_TOKENS.STRING_VALUE_ESCAPE.rawValue:
			
			if(self.currentScanning == SCAN_STATUS.SCANNING_VALUE) {
				
				self.currentScanning = SCAN_STATUS.SCANNING_VALUE_WITH_ESCAPE
				
			}else if(self.currentScanning == SCAN_STATUS.SCANNING_VALUE_WITH_ESCAPE) {
				
				self.currentScanning = SCAN_STATUS.SCANNED_VALUE_WITH_ESCAPE
			}
			break
		default:
			
			if(self.currentScanning == SCAN_STATUS.INITIAL_STATE) {
				
				if(self.lastSectionName.characters.count > 0) {
					
					self.lastKey = "\(scannedCharacter)"
					self.currentScanning = SCAN_STATUS.SCANNING_KEY
				}else{
					
					throw ParseError.UnsupportedToken(err: "INI Parse error on Line \(currentLine + 1) Section \(currentSection)")
				}
			}else if(self.currentScanning == SCAN_STATUS.SCANING_SECTION_NAME) {
				
				self.lastSectionName += "\(scannedCharacter)"
			}else if(self.currentScanning == SCAN_STATUS.SCANNING_KEY) {
				
				self.lastKey! += "\(scannedCharacter)"
			}else if(self.currentScanning == SCAN_STATUS.SCANNING_VALUE) {
				
				self.lastValue! += "\(scannedCharacter)"
			}else if(self.currentScanning == SCAN_STATUS.SCANNING_VALUE_WITH_ESCAPE) {
				
				self.lastValue! += "\(scannedCharacter)"
			}else if(self.currentScanning == SCAN_STATUS.SCANNING_COMMENT) {
				
				// pass
			}else{
				
				throw ParseError.UnsupportedToken(err: "INI Parse error on Line \(currentLine + 1) Section \(currentSection)")
			}
			
			break
		}
	}
	
	public func getConfigData() throws -> Config {
		
		if(self.configData == nil) {
			throw ParseError.UnsupportedToken(err: "INI Parse error. Unresolved error!")
		}else{
			return self.configData!
		}
	}
}

