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

public typealias InputPopupDelegate = (selectedChoiceIdx: Int, inputData: String) -> ()

public struct InputPopupWidget {
	
	public let widgetRows: Int = 0
	
	private var popupContent: String
	private var popupButtons: [String]
	private var popupDelegate: InputPopupDelegate
	/* ## Swift 3
	private var mainWindow: OpaquePointer
	private var shadowWindow: OpaquePointer?
	
	private var popupWindow: OpaquePointer!
	*/
	private var mainWindow: COpaquePointer
	private var shadowWindow: COpaquePointer?
	
	private var popupWindow: COpaquePointer!
	private var popupWidth: Int32 = 0
	private var popupHeight: Int32 = 0
	private var popupTop: Int32 = 0
	private var popupLeft: Int32 = 0
	private var currentSelectedButtonIdx = 0
	private var hasShadow = false
	
	/* ## Swift 3
	private var buttonWindows: [OpaquePointer]!
	private var inputWindow: OpaquePointer?
	*/
	private var buttonWindows: [COpaquePointer]!
	private var inputWindow: COpaquePointer?
	
	private var currentInputValue: String
	
	/* ## Swift 3
	public init(defaultValue: String, popupContent: String, popupButtons: [String], hasShadow: Bool, popupDelegate: InputPopupDelegate, mainWindow: OpaquePointer) {
	*/
	public init(defaultValue: String, popupContent: String, popupButtons: [String], hasShadow: Bool, popupDelegate: InputPopupDelegate, mainWindow: COpaquePointer) {
		
		self.popupContent = popupContent
		self.popupButtons = popupButtons
		self.popupDelegate = popupDelegate
		self.mainWindow = mainWindow
		self.hasShadow = hasShadow
		self.currentInputValue = defaultValue
		self.initWindows()
	}
	
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
			
			/* ## Swift 3
			wbkgd(self.shadowWindow, UInt32(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
			keypad(self.shadowWindow, true)
			touchwin(self.shadowWindow)
			wrefresh(self.shadowWindow)
			*/
			wbkgd(self.shadowWindow!, UInt32(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
			keypad(self.shadowWindow!, true)
			touchwin(self.shadowWindow!)
			wrefresh(self.shadowWindow!)
		}
		
		self.popupWindow = subwin(mainWindow, popupHeight, popupWidth, Int32(popupTop), Int32(popupLeft))
		wbkgd(self.popupWindow, UInt32(COLOR_PAIR(WidgetUIColor.FooterBackground.rawValue)))
		keypad(self.popupWindow, true)
		
		self.inputWindow = subwin(mainWindow, 2, popupWidth - 2, popupTop + popupHeight - 7, popupLeft + 1)
		/* ## Swift 3
		wbkgd(self.inputWindow, UInt32(COLOR_PAIR(WidgetUIColor.WarningLevelDanger.rawValue)))
		keypad(self.inputWindow, true)
		*/
		wbkgd(self.inputWindow!, UInt32(COLOR_PAIR(WidgetUIColor.WarningLevelDanger.rawValue)))
		keypad(self.inputWindow!, true)
	}
	
	mutating func draw() {
		
		if(self.popupWindow == nil) {
			
			return
		}
		
		wmove(self.popupWindow, 1, 2)
		waddstr(self.popupWindow, self.popupContent)
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
		
		/* ## Swift 3
		wmove(self.inputWindow, 0, 2)
		wattrset(self.inputWindow, COLOR_PAIR(WidgetUIColor.WarningLevelDanger.rawValue))
		waddstr(self.inputWindow, self.currentInputValue)
		mvwhline(self.inputWindow, 1, 1, 0, popupWidth - 1)
		touchwin(self.inputWindow)
		wrefresh(self.inputWindow)
		*/
		wmove(self.inputWindow!, 0, 2)
		wattrset(self.inputWindow!, COLOR_PAIR(WidgetUIColor.WarningLevelDanger.rawValue))
		waddstr(self.inputWindow!, self.currentInputValue)
		mvwhline(self.inputWindow!, 1, 1, 0, popupWidth - 1)
		touchwin(self.inputWindow!)
		wrefresh(self.inputWindow!)
	}
	
	private mutating func drawButtons() {
		
		/* ## Swift 3
		self.buttonWindows = [OpaquePointer]()
		*/
		self.buttonWindows = [COpaquePointer]()
			
		let buttonSizes = calculatePopupButtonWidth()
			
		let buttonTop = popupHeight + popupTop - 4
		var currentButtonLeft = buttonSizes.1 + popupLeft
		var btnIdx = 0
			
		for buttonData in popupButtons {
				
			let currentButtonShadowWindow = subwin(mainWindow, 2, buttonSizes.0, buttonTop + 1, currentButtonLeft + 1)
			wbkgd(currentButtonShadowWindow, UInt32(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
			wrefresh(currentButtonShadowWindow)
				
			let currentButtonWindow = subwin(mainWindow, 2, buttonSizes.0, buttonTop, currentButtonLeft)
			wbkgd(currentButtonWindow, UInt32(COLOR_PAIR(WidgetUIColor.ButtonDanger.rawValue)))
				
			let buttonSpace = (buttonSizes.0 - Int32(buttonData.characters.count)) / 2
			let buttonSpaceString = String(count: Int(buttonSpace), repeatedValue: Character(" "))
			let buttonText = "\(buttonSpaceString)\(buttonData)\n"
			wborder(currentButtonWindow, 1, 1, 1, 1, 1, 1, 1, 1)
			waddstr(currentButtonWindow, buttonText)
				
			if(currentSelectedButtonIdx == btnIdx) {
				
				wattrset(currentButtonWindow, COLOR_PAIR(WidgetUIColor.ButtonDanger.rawValue))
			}else{
				wattrset(currentButtonWindow, COLOR_PAIR(WidgetUIColor.ButtonDangerSelected.rawValue))
			}
			mvwhline(currentButtonWindow, 1, 1, 0, buttonSizes.0 - 2)
				
				
			wrefresh(currentButtonWindow)
			/* ## Swift 3
			self.buttonWindows.append(currentButtonShadowWindow!)
			self.buttonWindows.append(currentButtonWindow!)
			*/
			self.buttonWindows.append(currentButtonShadowWindow)
			self.buttonWindows.append(currentButtonWindow)
				
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
			
			/* ## Swift 3
			wclear(shadowWindow)
			delwin(shadowWindow)
			*/
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
			
			popupDelegate(selectedChoiceIdx: currentSelectedButtonIdx, inputData: currentInputValue)
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
			
			let c = Character(UnicodeScalar(Int(keyCode)))
			currentInputValue += "\(c)"
			refreshInputArea()
		}else if(keyCode > 64 && keyCode < 91){
			
			let c = Character(UnicodeScalar(Int(keyCode)))
			currentInputValue += "\(c)"
			refreshInputArea()
		}else if(keyCode > 96 && keyCode < 123){
			
			let c = Character(UnicodeScalar(Int(keyCode)))
			currentInputValue += "\(c)"
			refreshInputArea()
			
		// backspace
		}else if(keyCode == 127) {
		
			if(currentInputValue.characters.count > 0) {
				
				let strStartIdx = currentInputValue.startIndex
				let strEndIdx = currentInputValue.endIndex
			
				/* ## Swift 3
				let _startIdx = currentInputValue.index(strStartIdx, offsetBy: 0)
				let _endIdx = currentInputValue.index(strEndIdx, offsetBy: -1)
				*/
				let _startIdx = strStartIdx.advancedBy(0)
				let _endIdx = strEndIdx.advancedBy(-1)
				let newInputValueRange = Range<String.Index>(_startIdx..<_endIdx)
			
				/* ## Swift 3
				let newInputValue = currentInputValue.substring(with: newInputValueRange)
				*/
				let newInputValue = currentInputValue.substringWithRange(newInputValueRange)
				currentInputValue = newInputValue
				refreshInputArea()
			}
			
		// tab
		}else if(keyCode == 9) {
			
			/* ## Swift 3
			let splittedFileNamePath = currentInputValue.characters.split(separator: "/").map(String.init)
			*/
			let splittedFileNamePath = currentInputValue.characters.split("/").map(String.init)
			
			let splittedFileNamePathCount = splittedFileNamePath.count - 1
			
			if(splittedFileNamePathCount >= 0) {
				
				var newPath = ""
				for idx in 0..<(splittedFileNamePathCount) {
					
					if(splittedFileNamePath[idx].characters.count > 0) {
						
						newPath += "/\(splittedFileNamePath[idx])"
					}
				}
				
				do {
					
					/* ## Swift 3
					let dirList: [String]
					
					if(newPath.characters.count == 0) {
						
						dirList = try FileManager.default().contentsOfDirectory(atPath: "/")
					}else{
						dirList = try FileManager.default().contentsOfDirectory(atPath: newPath)
					}
					
					for files in dirList {
						
						let searchLen = splittedFileNamePath[splittedFileNamePathCount].characters.count
						let dataLen = files.characters.count
						
						if(dataLen >= searchLen) {
							
							let startIdx = files.startIndex
							
							let _startIdx = files.index(startIdx, offsetBy: 0)
							let _endIdx = files.index(startIdx, offsetBy: searchLen)
							let dataRange = Range<String.Index>(_startIdx..<_endIdx)
							let dataStr = files.substring(with: dataRange)
							
							if(dataStr == splittedFileNamePath[splittedFileNamePathCount]) {
								
								currentInputValue = "\(newPath)/\(files)"
								refreshInputArea()
								break
							}
						}
					}
					*/
					let dirList: [String]
					
					if(newPath.characters.count == 0) {
						
						dirList = try NSFileManager.defaultManager().contentsOfDirectoryAtPath("/")
					}else{
						dirList = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(newPath)
					}
						
					for files in dirList {
						
						let searchLen = splittedFileNamePath[splittedFileNamePathCount].characters.count
						let dataLen = files.characters.count
						
						if(dataLen >= searchLen) {
						
							let startIdx = files.startIndex
						
							let _startIdx = startIdx.advancedBy(0)
							let _endIdx = startIdx.advancedBy(searchLen)
							let dataRange = Range<String.Index>(_startIdx..<_endIdx)
							let dataStr = files.substringWithRange(dataRange)
						
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
		/* ## Swift 3
		wclear(self.inputWindow)
		*/
		wclear(self.inputWindow!)
		drawInputArea()
	}
}
