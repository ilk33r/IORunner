//
//  ModulesWidget.swift
//  IORunner/IOGUI
//
//  Created by ilker özcan on 15/07/16.
//
//

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif
import Foundation

public struct GUIModulesChoices {
	
	var choiceName: String
	var choiceCode: Int
	var isActive: Bool
	
	public init(choiceName: String, choiceCode: Int, isActive: Bool) {
		
		self.choiceName = choiceName
		self.choiceCode = choiceCode
		self.isActive = isActive
	}
}

#if swift(>=3)
public typealias ModuleChoicesSelectionDelegate = (_ selectedChoiceIdx: Int, _ isActive: Bool) -> ()
#else
public typealias ModuleChoicesSelectionDelegate = (selectedChoiceIdx: Int, isActive: Bool) -> ()
#endif

public struct ModulesWidget {
	
	public var widgetRows: Int
	
	private var startRow: Int
#if swift(>=3)
#if os(Linux)
	private var mainWindow: UnsafeMutablePointer<WINDOW>
#else
	private var mainWindow: OpaquePointer
#endif
#elseif swift(>=2.2) && os(OSX)
	
	private var mainWindow: COpaquePointer
#endif
	private var choices: [GUIModulesChoices]
	private var selectionDelegate: ModuleChoicesSelectionDelegate
	private var menuAreaWidth: Int32
	private var leftSideTitle: String
	private var rightSideTitle: String
	
#if swift(>=3)
#if os(Linux)
	private var modulesTitleWindow: UnsafeMutablePointer<WINDOW>!
	private var modulesPassiveWindow: UnsafeMutablePointer<WINDOW>!
	private var modulesActiveWindow: UnsafeMutablePointer<WINDOW>!
#else
	private var modulesTitleWindow: OpaquePointer!
	private var modulesPassiveWindow: OpaquePointer!
	private var modulesActiveWindow: OpaquePointer!
#endif
#elseif swift(>=2.2) && os(OSX)
	
	private var modulesTitleWindow: COpaquePointer!
	private var modulesPassiveWindow: COpaquePointer!
	private var modulesActiveWindow: COpaquePointer!
#endif
	private var moduleWinColumnSize: Int32 = 0
	private var leftModulesLineCount = 0
	private var firstLeftChoiceIdx = 0
	private var selectedLeftChoiceCode = -1
	private var currentLeftChoiceIdx = -1
	private var rightModulesLineCount = 0
	private var firstRightChoiceIdx = 0
	private var selectedRightChoiceCode = -1
	private var currentRightChoiceIdx = -1
	private var cursorIsLeftSide = true
	private var widgetInited = false
	
#if swift(>=3)
#if os(Linux)
	public init(startRow: Int, widgetSize: Int, leftSideTitle: String, rightSideTitle: String, choices: [GUIModulesChoices], delegate: ModuleChoicesSelectionDelegate, mainWindow: UnsafeMutablePointer<WINDOW>) {
	
		self.startRow = startRow
		self.widgetRows = widgetSize
		self.leftSideTitle = leftSideTitle
		self.rightSideTitle = rightSideTitle
		self.choices = choices
		self.selectionDelegate = delegate
		self.mainWindow = mainWindow
		self.menuAreaWidth = 2
		currentLeftChoiceIdx = 0
	
		initWindows()
	}
#else
	public init(startRow: Int, widgetSize: Int, leftSideTitle: String, rightSideTitle: String, choices: [GUIModulesChoices], delegate: ModuleChoicesSelectionDelegate, mainWindow: OpaquePointer) {
		
		self.startRow = startRow
		self.widgetRows = widgetSize
		self.leftSideTitle = leftSideTitle
		self.rightSideTitle = rightSideTitle
		self.choices = choices
		self.selectionDelegate = delegate
		self.mainWindow = mainWindow
		self.menuAreaWidth = 2
		currentLeftChoiceIdx = 0
		
		initWindows()
	}
#endif
#elseif swift(>=2.2) && os(OSX)
	
	public init(startRow: Int, widgetSize: Int, leftSideTitle: String, rightSideTitle: String, choices: [GUIModulesChoices], delegate: ModuleChoicesSelectionDelegate, mainWindow: COpaquePointer) {
	
		self.startRow = startRow
		self.widgetRows = widgetSize
		self.leftSideTitle = leftSideTitle
		self.rightSideTitle = rightSideTitle
		self.choices = choices
		self.selectionDelegate = delegate
		self.mainWindow = mainWindow
		self.menuAreaWidth = 2
		currentLeftChoiceIdx = 0
	
		initWindows()
	}
#endif
	
	mutating func initWindows() {
		
		wmove(mainWindow, 0, 0)
		self.modulesTitleWindow = subwin(self.mainWindow, 1, COLS - menuAreaWidth, Int32(startRow), 1)
	#if os(Linux)
		wbkgd(self.modulesTitleWindow, UInt(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
	#else
		wbkgd(self.modulesTitleWindow, UInt32(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
	#endif
		
		keypad(self.modulesTitleWindow, true)
		
		let rowCount = LINES - Int32(self.widgetRows) - 1
		moduleWinColumnSize = (COLS - menuAreaWidth) / 2
		let windowStartRow = Int32(startRow) + 1
		
		self.modulesActiveWindow = subwin(self.mainWindow, rowCount, moduleWinColumnSize, windowStartRow, 1)
	#if os(Linux)
		wbkgd(self.modulesActiveWindow, UInt(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
	#else
		wbkgd(self.modulesActiveWindow, UInt32(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
	#endif
		keypad(self.modulesActiveWindow, true)
		
		self.modulesPassiveWindow = subwin(self.mainWindow, rowCount, moduleWinColumnSize, windowStartRow, moduleWinColumnSize + 1)
	#if os(Linux)
		wbkgd(self.modulesPassiveWindow, UInt(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
	#else
		wbkgd(self.modulesPassiveWindow, UInt32(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
	#endif
		keypad(self.modulesPassiveWindow, true)
	}
	
	mutating func draw() {
		
		if(self.modulesTitleWindow == nil) {
			return
		}
		
		drawTitleArea()
		drawLeftModulesArea()
		drawRightModulesArea()
	}
	
	mutating func resize() {
		
		deinitWidget()
		initWindows()
		draw()
	}
	
	mutating func deinitWidget() {
		
		if(self.modulesTitleWindow != nil) {
			
			wclear(self.modulesTitleWindow)
			delwin(self.modulesTitleWindow)
			self.modulesTitleWindow = nil
		}
		
		if(self.modulesPassiveWindow != nil) {
			
			wclear(modulesPassiveWindow)
			delwin(modulesPassiveWindow)
			self.modulesPassiveWindow = nil
		}
		
		if(self.modulesActiveWindow != nil) {
			
			wclear(modulesActiveWindow)
			delwin(modulesActiveWindow)
			self.modulesActiveWindow = nil
		}
		
		wrefresh(mainWindow)
	}
	
	private mutating func drawTitleArea() {
		
		wmove(modulesTitleWindow, 0, 0)
		wattrset(modulesTitleWindow, COLOR_PAIR(WidgetUIColor.Background.rawValue))
		waddch(modulesTitleWindow, 32)
		waddch(modulesTitleWindow, 32)
		wattrset(modulesTitleWindow, COLOR_PAIR(WidgetUIColor.WarningLevelSuccess.rawValue))
		AddStringToWindow(normalString: leftSideTitle, window: modulesTitleWindow)
		
		wattrset(modulesTitleWindow, COLOR_PAIR(WidgetUIColor.Background.rawValue))
		let rightColumnStart = 2 + leftSideTitle.characters.count
		let appendCharacter = moduleWinColumnSize + 2 - rightColumnStart
		for _ in 0...appendCharacter {
			waddch(modulesTitleWindow, 32)
		}
		
		wattrset(modulesTitleWindow, COLOR_PAIR(WidgetUIColor.WarningLevelDanger.rawValue))
		AddStringToWindow(normalString: rightSideTitle, window: modulesTitleWindow)
		wrefresh(modulesTitleWindow)
	}
	
	private mutating func drawLeftModulesArea() {
		
		var currentLine: Int32 = 1
		var lineLeft = LINES - widgetRows - 4
		leftModulesLineCount = -2
		
		var realIdx = -1
		for idx in 0..<choices.count {
			
			realIdx += 1
			if(!choices[idx].isActive) {
				continue
			}
			
			if(realIdx < firstLeftChoiceIdx) {
				continue
			}
			
			if(lineLeft <= 0) {
				break
			}
			
			wmove(modulesActiveWindow, currentLine, 2)
			if(currentLeftChoiceIdx == idx) {
				selectedLeftChoiceCode = choices[idx].choiceCode
				wattrset(modulesActiveWindow, COLOR_PAIR(WidgetUIColor.FooterBackground.rawValue))
			}else{
				wattrset(modulesActiveWindow, COLOR_PAIR(WidgetUIColor.Background.rawValue))
			}
			
			let choiceStringWidth = Int(moduleWinColumnSize) - 1
			//var paddingSize = moduleWinColumnSize - choices[idx].choiceName.characters.count - 7

			let choiceString: String
			if(currentLeftChoiceIdx == idx) {
				choiceString = " \u{2192} \(choices[idx].choiceName)"
			}else{
				choiceString = "   \(choices[idx].choiceName)"
			}
			
			AddStringToWindow(paddingString: choiceString, textWidth: choiceStringWidth, textStartSpace: 1, window: modulesActiveWindow)
			AddStringToWindow(normalString: "\n", window: modulesActiveWindow)
			currentLine += 1
			
			lineLeft -= 1
			leftModulesLineCount += 1
		}
		
		wattrset(modulesActiveWindow, COLOR_PAIR(WidgetUIColor.Background.rawValue))
		AddStringToWindow(normalString: "\t", window: modulesActiveWindow)
		wborder(modulesActiveWindow, 0, 0, 0, 0, 0, 0, 0, 0)
		touchwin(modulesActiveWindow)
		wrefresh(modulesActiveWindow)
	}
	
	private mutating func drawRightModulesArea() {
		
		var currentLine: Int32 = 1
		var lineLeft = LINES - widgetRows - 4
		rightModulesLineCount = -2
		
		var realIdx = -1
		for idx in 0..<choices.count {
			
			realIdx += 1
			
			if(choices[idx].isActive) {
				continue
			}
			
			if(realIdx < firstRightChoiceIdx) {
				continue
			}
			
			if(lineLeft <= 0) {
				break
			}
			
			wmove(modulesPassiveWindow, currentLine, 2)
			if(currentRightChoiceIdx == idx) {
				selectedRightChoiceCode = choices[idx].choiceCode
				wattrset(modulesPassiveWindow, COLOR_PAIR(WidgetUIColor.FooterBackground.rawValue))
			}else{
				wattrset(modulesPassiveWindow, COLOR_PAIR(WidgetUIColor.Background.rawValue))
			}
			
			let choiceStringWidth = Int(moduleWinColumnSize) - 1
			//var paddingSize = moduleWinColumnSize - choices[idx].choiceName.characters.count - 7

			let choiceString: String
			if(currentRightChoiceIdx == idx) {
				choiceString = " \u{2192} \(choices[idx].choiceName)"
			}else{
				choiceString = "   \(choices[idx].choiceName)"
			}
			
			AddStringToWindow(paddingString: choiceString, textWidth: choiceStringWidth, textStartSpace: 1, window: modulesPassiveWindow)
			AddStringToWindow(normalString: "\n", window: modulesPassiveWindow)
			currentLine += 1
			
			lineLeft -= 1
			rightModulesLineCount += 1
		}
		
		wattrset(modulesPassiveWindow, COLOR_PAIR(WidgetUIColor.Background.rawValue))
		AddStringToWindow(normalString: "\n", window: modulesPassiveWindow)
		wborder(modulesPassiveWindow, 0, 0, 0, 0, 0, 0, 0, 0)
		touchwin(modulesPassiveWindow)
		wrefresh(modulesPassiveWindow)
	}
	
	mutating func updateSelectedChoice(isUp: Bool = false) {
		
		var leftModuleCount = 0
		var leftModuleFirstIdx = -1
		var rightModuleCount = 0
		var rightModuleFirstIdx = -1
		
		for idx in 0..<choices.count {
			
			if(choices[idx].isActive) {
				
				leftModuleCount += 1
				
				if(leftModuleFirstIdx == -1) {
					leftModuleFirstIdx = idx
				}
			}else{
				
				rightModuleCount += 1
				
				if(rightModuleFirstIdx == -1) {
					rightModuleFirstIdx = idx
				}
			}
		}
		
		if(cursorIsLeftSide) {
			
			if(isUp) {
			
				if(currentLeftChoiceIdx > leftModuleFirstIdx) {
			
					currentLeftChoiceIdx -= 1
					if(currentLeftChoiceIdx < firstLeftChoiceIdx) {
						firstLeftChoiceIdx -= 1
					}
			
					wclear(modulesActiveWindow)
					drawLeftModulesArea()
				}
			
			}else{
			
				if(currentLeftChoiceIdx < leftModulesLineCount) {
					
					currentLeftChoiceIdx += 1
					wclear(modulesActiveWindow)
					drawLeftModulesArea()
				}else{
					
					if(currentLeftChoiceIdx >= leftModulesLineCount && currentLeftChoiceIdx < (leftModuleCount - 1)) {
						
						firstLeftChoiceIdx += 1
						currentLeftChoiceIdx += 1
						wclear(modulesActiveWindow)
						drawLeftModulesArea()
					}
				}
			}
		}else{
			
			if(isUp) {
				
				if(currentRightChoiceIdx > rightModuleFirstIdx) {
					
					currentRightChoiceIdx -= 1
					if(currentRightChoiceIdx < firstRightChoiceIdx) {
						firstRightChoiceIdx -= 1
					}
					
					wclear(modulesPassiveWindow)
					drawRightModulesArea()
				}
				
			}else{
				
				if(currentRightChoiceIdx < (rightModulesLineCount + leftModuleCount)) {
					
					currentRightChoiceIdx += 1
					wclear(modulesPassiveWindow)
					drawRightModulesArea()
				}else{
					
					if(currentRightChoiceIdx >= (leftModuleCount + rightModulesLineCount) && currentRightChoiceIdx < (leftModuleCount + rightModuleCount - 1)) {
						
						firstRightChoiceIdx += 1
						currentRightChoiceIdx += 1
						wclear(modulesPassiveWindow)
						drawRightModulesArea()
					}
				}
			}
		}
	}
	
	func choiceSelected() {
		
	#if swift(>=3)
		if(cursorIsLeftSide) {
			
			selectionDelegate(selectedLeftChoiceCode, true)
		}else{
			selectionDelegate(selectedRightChoiceCode, false)
		}
	#else
		if(cursorIsLeftSide) {
			
			selectionDelegate(selectedChoiceIdx: selectedLeftChoiceCode, isActive: true)
		}else{
			selectionDelegate(selectedChoiceIdx: selectedRightChoiceCode, isActive: false)
		}
	#endif
		
	}
	
	private mutating func changeCursor() {
		
		selectedLeftChoiceCode = -1
		currentLeftChoiceIdx = -1
		selectedRightChoiceCode = -1
		currentRightChoiceIdx = -1
		
		if(cursorIsLeftSide) {
			
			cursorIsLeftSide = false
			
			for idx in 0..<choices.count {
				
				if(choices[idx].isActive) {
					continue
				}
				
				selectedRightChoiceCode = idx
				currentRightChoiceIdx = choices[idx].choiceCode
				break
			}
			
		}else{
			
			cursorIsLeftSide = true
			
			for idx in 0..<choices.count {
				
				if(!choices[idx].isActive) {
					continue
				}
				
				selectedLeftChoiceCode = idx
				currentLeftChoiceIdx = choices[idx].choiceCode
				break
			}
		}
		
		wclear(modulesActiveWindow)
		wclear(modulesPassiveWindow)
		drawLeftModulesArea()
		drawRightModulesArea()
	}
	
	mutating func keyEvent(keyCode: Int32) {
		
		if(!widgetInited) {
			widgetInited = true
			return
		}
		
		switch keyCode {
		case KEY_ENTER, 13:
			self.choiceSelected()
			break
		case KEY_UP:
		#if swift(>=3)
			
			self.updateSelectedChoice(isUp: true)
		#elseif swift(>=2.2) && os(OSX)
			
			self.updateSelectedChoice(true)
		#endif
			break
		case KEY_DOWN:
			self.updateSelectedChoice()
			break
		case KEY_LEFT:
			self.changeCursor()
			break
		case KEY_RIGHT:
			self.changeCursor()
			break
		default:
			break
		}
	}
	
	public mutating func updateModuleList(modules: [GUIModulesChoices]) {
		
		self.choices = modules
		wclear(modulesActiveWindow)
		wclear(modulesPassiveWindow)
	}
}
