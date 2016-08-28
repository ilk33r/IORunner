//
//  PopupWidget.swift
//  IORunner/IOGUI
//
//  Created by ilker özcan on 14/07/16.
//
//

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif
import Foundation

public struct PopupWidget {
	
	public let widgetRows: Int = 0
	
	public enum GUIPopupTypes {
		case CONFIRM
		case SYNC_WAIT
		case PROGRESS
	}
	
	private var popuptype: GUIPopupTypes
	private var popupContent: String
	private var popupButtons: [String]
	private var popupDelegate: MenuChoicesSelectionDelegate
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
	private var progressSize: Int32 = 0
	private var progressPercent: UInt = 0
	
#if swift(>=3)
	
#if os(Linux)
	private var buttonWindows: [UnsafeMutablePointer<WINDOW>]!
	
	public init(popuptype: GUIPopupTypes, popupContent: String, popupButtons: [String], hasShadow: Bool, popupDelegate: MenuChoicesSelectionDelegate, mainWindow: UnsafeMutablePointer<WINDOW>) {
	
		self.popuptype = popuptype
		self.popupContent = popupContent
		self.popupButtons = popupButtons
		self.popupDelegate = popupDelegate
		self.mainWindow = mainWindow
		self.hasShadow = hasShadow
		self.initWindows()
	}
#else
	private var buttonWindows: [OpaquePointer]!

	public init(popuptype: GUIPopupTypes, popupContent: String, popupButtons: [String], hasShadow: Bool, popupDelegate: MenuChoicesSelectionDelegate, mainWindow: OpaquePointer) {
		
		self.popuptype = popuptype
		self.popupContent = popupContent
		self.popupButtons = popupButtons
		self.popupDelegate = popupDelegate
		self.mainWindow = mainWindow
		self.hasShadow = hasShadow
		self.initWindows()
	}
#endif
#elseif swift(>=2.2) && os(OSX)
	
	private var buttonWindows: [COpaquePointer]!
	
	public init(popuptype: GUIPopupTypes, popupContent: String, popupButtons: [String], hasShadow: Bool, popupDelegate: MenuChoicesSelectionDelegate, mainWindow: COpaquePointer) {
		
		self.popuptype = popuptype
		self.popupContent = popupContent
		self.popupButtons = popupButtons
		self.popupDelegate = popupDelegate
		self.mainWindow = mainWindow
		self.hasShadow = hasShadow
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
		
		if(popuptype == .PROGRESS) {
		#if swift(>=3)
		#if os(Linux)
			self.buttonWindows = [UnsafeMutablePointer<WINDOW>]()
		#else
			self.buttonWindows = [OpaquePointer]()
		#endif
		#elseif swift(>=2.2) && os(OSX)
			
			self.buttonWindows = [COpaquePointer]()
		#endif
		}
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
		
		drawButtons()
		drawProgress()
	}
	
	private mutating func drawButtons() {
		
		if(popuptype == .CONFIRM) {
		
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
			#if swift(>=3)
				AddStringToWindow(paddingString: "", textWidth: Int(buttonSizes.0) - 1, textStartSpace: 0, window: currentButtonShadowWindow!)
				AddStringToWindow(normalString: "\n", window: currentButtonShadowWindow!)
			#elseif swift(>=2.2) && os(OSX)
				AddStringToWindow(paddingString: "", textWidth: Int(buttonSizes.0) - 1, textStartSpace: 0, window: currentButtonShadowWindow)
				AddStringToWindow(normalString: "\n", window: currentButtonShadowWindow)
			#endif
				touchwin(currentButtonShadowWindow)
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
				
				touchwin(currentButtonWindow)
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
	
	private mutating func drawProgress() {
		
		if(popuptype == .PROGRESS) {
			
		#if swift(>=3)
		#if os(Linux)
			self.buttonWindows = [UnsafeMutablePointer<WINDOW>]()
		#else
			self.buttonWindows = [OpaquePointer]()
		#endif
		#elseif swift(>=2.2) && os(OSX)
			
			self.buttonWindows = [COpaquePointer]()
		#endif
			
			progressSize = popupWidth - 2
			
			if(self.buttonWindows.count == 0) {
				
				let progressTop = popupHeight + popupTop - 4
				let progressLeft = popupLeft + 1
				let progressWindow = subwin(mainWindow, 1, progressSize, progressTop, progressLeft)
			#if os(Linux)
				wbkgd(progressWindow, UInt(COLOR_PAIR(WidgetUIColor.Progress.rawValue)))
			#else
				wbkgd(progressWindow, UInt32(COLOR_PAIR(WidgetUIColor.Progress.rawValue)))
			#endif
				wrefresh(progressWindow)
				
			#if swift(>=3)
				
				self.buttonWindows.append(progressWindow!)
			#elseif swift(>=2.2) && os(OSX)
				
				self.buttonWindows.append(progressWindow)
			#endif
			}else{
				
				wclear(self.buttonWindows[0])
			}
			
			let progressPercentWidth = self.calculateProgressPercentWidth()
			wmove(self.buttonWindows[0], 0, 0)
			wattrset(self.buttonWindows[0], COLOR_PAIR(WidgetUIColor.ProgressBar.rawValue))
			var stringWrited = false
			let percentString = "\(self.progressPercent) %"
			let percentStringStartPos = (progressSize - percentString.characters.count) / 2
			let stringEndPos = percentStringStartPos + percentString.characters.count
			
			for percent in 0..<progressPercentWidth {
				
				wmove(self.buttonWindows[0], 0, percent)
				
				if(percent > percentStringStartPos && percent < stringEndPos) {
					continue
				}
				
				if(percent == percentStringStartPos) {
				
					wattrset(self.buttonWindows[0], COLOR_PAIR(WidgetUIColor.ProgressText.rawValue))
					AddStringToWindow(normalString: percentString, window: self.buttonWindows[0])
					stringWrited = true
				}else{
				
					wattrset(self.buttonWindows[0], COLOR_PAIR(WidgetUIColor.ProgressBar.rawValue))
					waddch(self.buttonWindows[0], 32)
				}
			}
			
			
			if(!stringWrited) {
				
				wattrset(self.buttonWindows[0], COLOR_PAIR(WidgetUIColor.Progress.rawValue))
			#if swift(>=3)
				
				let spaceString = String(repeating: " ", count: Int((percentStringStartPos - progressPercentWidth)))
			#else
				
				let spaceString = String(count: Int((percentStringStartPos - progressPercentWidth)), repeatedValue: Character(" "))
			#endif
				let percentDisplayString = "\(spaceString)\(percentString)"
				AddStringToWindow(normalString: percentDisplayString, window: self.buttonWindows[0])
			}
			wrefresh(self.buttonWindows[0])
		}
	}
	
	private mutating func calculateProgressPercentWidth() -> Int32 {
		
		let currentCalculatesProgressSize = (self.progressPercent * UInt(self.progressSize)) / 100
		let currentProgressSize: Int32
		
		if(currentCalculatesProgressSize > 100) {
			
			currentProgressSize = 100
		}else if(currentCalculatesProgressSize < 0) {
			
			currentProgressSize = 0
		}else{
			
			currentProgressSize = Int32(currentCalculatesProgressSize)
		}
		
		return currentProgressSize
	}
	
	public mutating func setPercent(newPercent: UInt) {
		
		self.progressPercent = newPercent
		drawProgress()
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
			popupDelegate(currentSelectedButtonIdx)
		#else
			popupDelegate(selectedChoiceIdx: currentSelectedButtonIdx)
		#endif
		}else if(keyCode == KEY_LEFT) {
			
			if(popuptype == .CONFIRM) {
				
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
			}
		}else if(keyCode == KEY_RIGHT) {
			
			if(popuptype == .CONFIRM) {
				
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
			}
		}
	}
}
