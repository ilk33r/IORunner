//
//  InputPopupWidget.swift
//  IORunner/IOGUI
//
//  Created by ilker özcan on 18/07/16.
//
//

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif
import Foundation

#if swift(>=3)
public typealias InputPopupDelegate = (_ selectedChoiceIdx: Int, _ inputData: String) -> ()
#else
public typealias InputPopupDelegate = (selectedChoiceIdx: Int, inputData: String) -> ()
#endif

public struct InputPopupWidget {
	
	public let widgetRows: Int = 0
	
	private var popupContent: String
	private var popupButtons: [String]
	private var popupDelegate: InputPopupDelegate
#if swift(>=3)
#if os(Linux)
	private var mainWindow: UnsafeMutablePointer<WINDOW>
	
	private var shadowWindow: UnsafeMutablePointer<WINDOW>?
	
	private var popupWindow: UnsafeMutablePointer<WINDOW>!
#else
	private var mainWindow: OpaquePointer
	
	private var shadowWindow: OpaquePointer?
	
	private var popupWindow: OpaquePointer!
#endif
#elseif swift(>=2.2) && os(OSX)
	
	private var mainWindow: COpaquePointer
	
	private var shadowWindow: COpaquePointer?
	
	private var popupWindow: COpaquePointer!
#endif
	private var popupWidth: Int32 = 0
	private var popupHeight: Int32 = 0
	private var popupTop: Int32 = 0
	private var popupLeft: Int32 = 0
	private var currentSelectedButtonIdx = 0
	private var hasShadow = false
#if swift(>=3)
#if os(Linux)
	private var buttonWindows: [UnsafeMutablePointer<WINDOW>]!
	private var inputWindow: UnsafeMutablePointer<WINDOW>?
#else
	private var buttonWindows: [OpaquePointer]!
	private var inputWindow: OpaquePointer?
#endif
#elseif swift(>=2.2) && os(OSX)
	
	private var buttonWindows: [COpaquePointer]!
	private var inputWindow: COpaquePointer?
#endif
	private var currentInputValue: String
	
#if swift(>=3)
#if os(Linux)
	public init(defaultValue: String, popupContent: String, popupButtons: [String], hasShadow: Bool, popupDelegate: InputPopupDelegate, mainWindow: UnsafeMutablePointer<WINDOW>) {
	
		self.popupContent = popupContent
		self.popupButtons = popupButtons
		self.popupDelegate = popupDelegate
		self.mainWindow = mainWindow
		self.hasShadow = hasShadow
		self.currentInputValue = defaultValue
		self.initWindows()
	}
#else
	public init(defaultValue: String, popupContent: String, popupButtons: [String], hasShadow: Bool, popupDelegate: InputPopupDelegate, mainWindow: OpaquePointer) {
	
		self.popupContent = popupContent
		self.popupButtons = popupButtons
		self.popupDelegate = popupDelegate
		self.mainWindow = mainWindow
		self.hasShadow = hasShadow
		self.currentInputValue = defaultValue
		self.initWindows()
	}
#endif
#elseif swift(>=2.2) && os(OSX)
	
	public init(defaultValue: String, popupContent: String, popupButtons: [String], hasShadow: Bool, popupDelegate: InputPopupDelegate, mainWindow: COpaquePointer) {
	
		self.popupContent = popupContent
		self.popupButtons = popupButtons
		self.popupDelegate = popupDelegate
		self.mainWindow = mainWindow
		self.hasShadow = hasShadow
		self.currentInputValue = defaultValue
		self.initWindows()
	}
#endif
	
	mutating func initWindows() {
		
		if(!hasShadow) {
			
			wclear(self.mainWindow)
		}
		
		wmove(mainWindow, COLS, LINES)
		popupWidth = (COLS / 4) * 3
		popupHeight = (LINES / 4) * 2
		popupLeft = (COLS - popupWidth) / 2
		popupTop = (LINES - popupHeight) / 2
		
		if(hasShadow) {
			
			self.shadowWindow = subwin(mainWindow, popupHeight, popupWidth, popupTop + 1, popupLeft + 1)
		#if os(Linux)
			wbkgd(self.shadowWindow!, UInt(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
		#else
			wbkgd(self.shadowWindow!, UInt32(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
		#endif
			
			keypad(self.shadowWindow!, true)
			touchwin(self.shadowWindow!)
			wrefresh(self.shadowWindow!)
		}
		
		self.popupWindow = subwin(mainWindow, popupHeight, popupWidth, Int32(popupTop), Int32(popupLeft))
	#if os(Linux)
		wbkgd(self.popupWindow, UInt(COLOR_PAIR(WidgetUIColor.FooterBackground.rawValue)))
	#else
		wbkgd(self.popupWindow, UInt32(COLOR_PAIR(WidgetUIColor.FooterBackground.rawValue)))
	#endif
		keypad(self.popupWindow, true)
		
		self.inputWindow = subwin(mainWindow, 2, popupWidth - 2, popupTop + popupHeight - 7, popupLeft + 1)
	#if os(Linux)
		wbkgd(self.inputWindow!, UInt(COLOR_PAIR(WidgetUIColor.WarningLevelDanger.rawValue)))
	#else
		wbkgd(self.inputWindow!, UInt32(COLOR_PAIR(WidgetUIColor.WarningLevelDanger.rawValue)))
	#endif
		keypad(self.inputWindow!, true)
	}
	
	mutating func draw() {
		
		if(self.popupWindow == nil) {
			
			return
		}
		
		wmove(self.popupWindow, 1, 2)
		AddStringToWindow(normalString: self.popupContent, window: self.popupWindow)
		AddStringToWindow(normalString: "\n", window: self.popupWindow)
		wborder(self.popupWindow, 0, 0, 0, 0, 0, 0, 0, 0)
		touchwin(self.popupWindow)
		wrefresh(self.popupWindow)
		
		drawInputArea()
		drawButtons()
	}
	
	private mutating func drawInputArea() {
		
		if(self.inputWindow == nil) {
			
			return
		}
		
		wmove(self.inputWindow!, 0, 2)
		wattrset(self.inputWindow!, COLOR_PAIR(WidgetUIColor.WarningLevelDanger.rawValue))
		AddStringToWindow(normalString: self.currentInputValue, window: self.inputWindow!)
		mvwhline(self.inputWindow!, 1, 1, 0, popupWidth - 1)
		touchwin(self.inputWindow!)
		wrefresh(self.inputWindow!)
	}
	
	private mutating func drawButtons() {
		
	#if swift(>=3)
	#if os(Linux)
		self.buttonWindows = [UnsafeMutablePointer<WINDOW>]()
	#else
		self.buttonWindows = [OpaquePointer]()
	#endif
	#elseif swift(>=2.2) && os(OSX)
		
		self.buttonWindows = [COpaquePointer]()
	#endif
			
		let buttonSizes = calculatePopupButtonWidth()
			
		let buttonTop = popupHeight + popupTop - 4
		var currentButtonLeft = buttonSizes.1 + popupLeft
		var btnIdx = 0
			
		for buttonData in popupButtons {
			
			let currentButtonShadowWindow = subwin(mainWindow, 2, buttonSizes.0, buttonTop + 1, currentButtonLeft + 1)
		#if os(Linux)
			wbkgd(currentButtonShadowWindow, UInt(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
		#else
			wbkgd(currentButtonShadowWindow, UInt32(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
		#endif

			wrefresh(currentButtonShadowWindow)

			let currentButtonWindow = subwin(mainWindow, 2, buttonSizes.0, buttonTop, currentButtonLeft)
		#if os(Linux)
			wbkgd(currentButtonWindow, UInt(COLOR_PAIR(WidgetUIColor.ButtonDanger.rawValue)))
		#else
			wbkgd(currentButtonWindow, UInt32(COLOR_PAIR(WidgetUIColor.ButtonDanger.rawValue)))
		#endif

			let buttonWidth = (Int(buttonSizes.0) - 2) / 2
			//let buttonSpace = (buttonSizes.0 - Int32(buttonData.characters.count)) / 2
		#if os(OSX)
			wborder(currentButtonWindow, 1, 1, 1, 1, 1, 1, 1, 1)
		#endif
		#if swift(>=3)
			AddStringToWindow(paddingString: buttonData, textWidth: buttonWidth, textStartSpace: buttonWidth, window: currentButtonWindow!)
			AddStringToWindow(normalString: "\n", window: currentButtonWindow!)
		#elseif swift(>=2.2) && os(OSX)
			AddStringToWindow(paddingString: buttonData, textWidth: buttonWidth, textStartSpace: buttonWidth, window: currentButtonWindow)
			AddStringToWindow(normalString: "\n", window: currentButtonWindow)
		#endif
				
			if(currentSelectedButtonIdx == btnIdx) {
				
				wattrset(currentButtonWindow, COLOR_PAIR(WidgetUIColor.ButtonDanger.rawValue))
			}else{
				wattrset(currentButtonWindow, COLOR_PAIR(WidgetUIColor.ButtonDangerSelected.rawValue))
			}
			mvwhline(currentButtonWindow, 1, 1, 0, buttonSizes.0 - 2)
				
				
			wrefresh(currentButtonWindow)
		#if swift(>=3)
			
			self.buttonWindows.append(currentButtonShadowWindow!)
			self.buttonWindows.append(currentButtonWindow!)
		#elseif swift(>=2.2) && os(OSX)
			
			self.buttonWindows.append(currentButtonShadowWindow)
			self.buttonWindows.append(currentButtonWindow)
		#endif
				
			currentButtonLeft += buttonSizes.0 + buttonSizes.1 + buttonSizes.1
			btnIdx += 1
		}
	}
	
	func calculatePopupButtonWidth() -> (Int32, Int32) {
		
		var minTextWidth: Int32 = 0
		for buttonTexts in popupButtons {
			
			let buttonTextCharacterCount = buttonTexts.characters.count
			if(minTextWidth < Int32(buttonTextCharacterCount)) {
				
				minTextWidth = Int32(buttonTextCharacterCount)
			}
		}
		
		minTextWidth += 3
		var buttonSpaces: Int32 = 0
		
		let allButtonWidth: Int32 = Int32(popupButtons.count) * minTextWidth
		if(allButtonWidth < popupWidth) {
			
			let spaceLeft = popupWidth - allButtonWidth
			buttonSpaces = (spaceLeft / Int32(popupButtons.count)) / 2
		}
		
		return (minTextWidth, buttonSpaces)
	}
	
	mutating func resize() {
		
		deinitWidget()
		initWindows()
		draw()
	}
	
	mutating func deinitWidget() {
		
		if(self.popupWindow != nil) {
			
			wclear(popupWindow)
			delwin(popupWindow)
			self.popupWindow = nil
		}
		
		if(self.hasShadow && self.shadowWindow != nil) {
			
			wclear(shadowWindow!)
			delwin(shadowWindow!)
			self.shadowWindow = nil
		}
		
		if(self.buttonWindows != nil) {
			
			for buttonWindow in buttonWindows {
				
				wclear(buttonWindow)
				delwin(buttonWindow)
			}
			
			self.buttonWindows = nil
		}

		wrefresh(mainWindow)
	}
	
	mutating func keyEvent(keyCode: Int32) {
		
		if(keyCode == KEY_ENTER || keyCode == 13) {
			
		#if swift(>=3)
			popupDelegate(currentSelectedButtonIdx, currentInputValue)
		#else
			popupDelegate(selectedChoiceIdx: currentSelectedButtonIdx, inputData: currentInputValue)
		#endif
		}else if(keyCode == KEY_LEFT) {
				
			let newKeyIdx = currentSelectedButtonIdx - 1
			if(newKeyIdx >= 0) {
					
				currentSelectedButtonIdx = newKeyIdx
			}else{
					
				currentSelectedButtonIdx = popupButtons.count - 1
			}
				
			if(self.buttonWindows != nil) {
					
				for buttonWindow in buttonWindows {
						
					wclear(buttonWindow)
					delwin(buttonWindow)
				}
					
				self.buttonWindows = nil
			}
			drawButtons()

		}else if(keyCode == KEY_RIGHT) {
			
			let newKeyIdx = currentSelectedButtonIdx + 1
			if(newKeyIdx < popupButtons.count) {
					
				currentSelectedButtonIdx = newKeyIdx
			}else{
					
				currentSelectedButtonIdx = 0
			}
				
			if(self.buttonWindows != nil) {
					
				for buttonWindow in buttonWindows {
						
					wclear(buttonWindow)
					delwin(buttonWindow)
				}
					
				self.buttonWindows = nil
			}
			drawButtons()
			
		}else if(keyCode > 31 && keyCode < 58){
			
		#if swift(>=3)
			let c = Character(UnicodeScalar(Int(keyCode))!)
		#else
			let c = Character(UnicodeScalar(Int(keyCode)))
		#endif
			currentInputValue += "\(c)"
			refreshInputArea()
		}else if(keyCode > 64 && keyCode < 91){
			
		#if swift(>=3)
			let c = Character(UnicodeScalar(Int(keyCode))!)
		#else
			let c = Character(UnicodeScalar(Int(keyCode)))
		#endif
			currentInputValue += "\(c)"
			refreshInputArea()
		}else if(keyCode > 96 && keyCode < 123){
			
		#if swift(>=3)
			let c = Character(UnicodeScalar(Int(keyCode))!)
		#else
			let c = Character(UnicodeScalar(Int(keyCode)))
		#endif
			currentInputValue += "\(c)"
			refreshInputArea()
			
		// backspace
		}else if(keyCode == 127) {
		
			if(currentInputValue.characters.count > 0) {
				
				let strStartIdx = currentInputValue.startIndex
				let strEndIdx = currentInputValue.endIndex
			
			#if swift(>=3)
				
				let _startIdx = currentInputValue.index(strStartIdx, offsetBy: 0)
				let _endIdx = currentInputValue.index(strEndIdx, offsetBy: -1)
			#else
				
				let _startIdx = strStartIdx.advancedBy(0)
				let _endIdx = strEndIdx.advancedBy(-1)
			#endif
				let newInputValueRange = Range<String.Index>(_startIdx..<_endIdx)
			
			#if swift(>=3)
				
				let newInputValue = currentInputValue.substring(with: newInputValueRange)
			#else
				
				let newInputValue = currentInputValue.substringWithRange(newInputValueRange)
			#endif
				currentInputValue = newInputValue
				refreshInputArea()
			}
			
		// tab
		}else if(keyCode == 9) {
			
		#if swift(>=3)
			
			let splittedFileNamePath = currentInputValue.characters.split(separator: "/").map(String.init)
		#else
			
			let splittedFileNamePath = currentInputValue.characters.split("/").map(String.init)
		#endif
			
			let splittedFileNamePathCount = splittedFileNamePath.count - 1
			
			if(splittedFileNamePathCount >= 0) {
				
				var newPath = ""
				for idx in 0..<(splittedFileNamePathCount) {
					
					if(splittedFileNamePath[idx].characters.count > 0) {
						
						newPath += "/\(splittedFileNamePath[idx])"
					}
				}
				
				do {
					
					let dirList: [String]
				#if swift(>=3)
					
					if(newPath.characters.count == 0) {
						
						dirList = try FileManager.default.contentsOfDirectory(atPath: "/")
					}else{
						dirList = try FileManager.default.contentsOfDirectory(atPath: newPath)
					}
				#elseif swift(>=2.2) && os(OSX)
					
					if(newPath.characters.count == 0) {
						
						dirList = try NSFileManager.defaultManager().contentsOfDirectoryAtPath("/")
					}else{
						dirList = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(newPath)
					}
				#endif
						
					for files in dirList {
						
						let searchLen = splittedFileNamePath[splittedFileNamePathCount].characters.count
						let dataLen = files.characters.count
						
						if(dataLen >= searchLen) {
						
							let startIdx = files.startIndex
						
						#if swift(>=3)
							
							let _startIdx = files.index(startIdx, offsetBy: 0)
							let _endIdx = files.index(startIdx, offsetBy: searchLen)
						#else
							
							let _startIdx = startIdx.advancedBy(0)
							let _endIdx = startIdx.advancedBy(searchLen)
						#endif
							let dataRange = Range<String.Index>(_startIdx..<_endIdx)
						#if swift(>=3)
							
							let dataStr = files.substring(with: dataRange)
						#else
							
							let dataStr = files.substringWithRange(dataRange)
						#endif
						
							if(dataStr == splittedFileNamePath[splittedFileNamePathCount]) {
						
								currentInputValue = "\(newPath)/\(files)"
								refreshInputArea()
								break
							}
						}
					}
					
				} catch _ {
					// pass
				}
				
			}
		}
	}
	
	private mutating func refreshInputArea() {
		
		if(self.inputWindow == nil) {
			
			return
		}
		wclear(self.inputWindow!)
		drawInputArea()
	}
}
