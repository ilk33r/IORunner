//
//  MenuWidget.swift
//  IORunner/IOGUI
//
//  Created by ilker özcan on 13/07/16.
//
//

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif
import Foundation

public struct GUIMenuChoices {
	
	var choiceName: String
	var choiceCode: Int
	
	public init(choiceName: String, choiceCode: Int) {
		
		self.choiceName = choiceName
		self.choiceCode = choiceCode
	}
}

#if swift(>=3)
public typealias MenuChoicesSelectionDelegate = (_ selectedChoiceIdx: Int) -> ()
#else
public typealias MenuChoicesSelectionDelegate = (selectedChoiceIdx: Int) -> ()
#endif

public struct MenuWidget {
	
	var widgetRows: Int
	
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
		private var choices: [GUIMenuChoices]
	private var selectionDelegate: MenuChoicesSelectionDelegate
	private var menuAreaWidth: Int32
#if swift(>=3)
#if os(Linux)
	private var menuWindow: UnsafeMutablePointer<WINDOW>!
#else
	private var menuWindow: OpaquePointer!
#endif
#elseif swift(>=2.2) && os(OSX)
	
	private var menuWindow: COpaquePointer!
#endif
	private var currentChoiceIdx = 0
	private var firstChoiceIdx = 0
	private var choicesLineCount = 0
	private var selectedChoiceCode = -1
	
#if swift(>=3)

#if os(Linux)
	public init(startRow: Int, widgetSize: Int, choices: [GUIMenuChoices], delegate: MenuChoicesSelectionDelegate, mainWindow: UnsafeMutablePointer<WINDOW>) {
	
		self.startRow = startRow
		self.widgetRows = widgetSize
		self.choices = choices
		self.selectionDelegate = delegate
		self.mainWindow = mainWindow
		self.menuAreaWidth = 2
		initWindows()
	}
#else
	public init(startRow: Int, widgetSize: Int, choices: [GUIMenuChoices], delegate: MenuChoicesSelectionDelegate, mainWindow: OpaquePointer) {
		
		self.startRow = startRow
		self.widgetRows = widgetSize
		self.choices = choices
		self.selectionDelegate = delegate
		self.mainWindow = mainWindow
		self.menuAreaWidth = 2
		initWindows()
	}
#endif
#elseif swift(>=2.2) && os(OSX)
	
	public init(startRow: Int, widgetSize: Int, choices: [GUIMenuChoices], delegate: MenuChoicesSelectionDelegate, mainWindow: COpaquePointer) {
	
		self.startRow = startRow
		self.widgetRows = widgetSize
		self.choices = choices
		self.selectionDelegate = delegate
		self.mainWindow = mainWindow
		self.menuAreaWidth = 2
		initWindows()
	}
#endif
	
	mutating func initWindows() {
		
		wmove(mainWindow, 0, 0)
		self.menuWindow = subwin(self.mainWindow, LINES - Int32(self.widgetRows), COLS - menuAreaWidth, Int32(startRow), 1)
	#if os(Linux)
		wbkgd(self.menuWindow,UInt(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
	#else
		wbkgd(self.menuWindow,UInt32(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
	#endif
		keypad(self.menuWindow, true)
	}
	
	mutating func draw() {
		
		if(self.menuWindow == nil) {
			return
		}
		
		drawMenuArea()
	}
	
	mutating func resize() {
		
		deinitWidget()
		initWindows()
		draw()
	}
	
	mutating func deinitWidget() {
		
		if(self.menuWindow != nil) {
			
			wclear(menuWindow)
			delwin(menuWindow)
			self.menuWindow = nil
		}
		
		wrefresh(mainWindow)
	}
	
	private mutating func drawMenuArea() {
		
		var currentLine: Int32 = 1
		var lineLeft = LINES - widgetRows - 1
		choicesLineCount = -2
		
		for idx in 0..<choices.count {
			
			if(idx < firstChoiceIdx) {
				continue
			}
			
			if(lineLeft <= 0) {
				break
			}
			
			wmove(menuWindow, currentLine, 2)
			if(currentChoiceIdx == idx) {
				selectedChoiceCode = choices[idx].choiceCode
				wattrset(menuWindow, COLOR_PAIR(WidgetUIColor.FooterBackground.rawValue))
			}else{
				wattrset(menuWindow, COLOR_PAIR(WidgetUIColor.Background.rawValue))
			}
			
			let menuStringWidth = Int(COLS) - Int(menuAreaWidth) - 1

			let choiceString: String
			if(currentChoiceIdx == idx) {
				choiceString = " \u{2192} \(choices[idx].choiceName)"
			}else{
				choiceString = "   \(choices[idx].choiceName)"
			}
			
			AddStringToWindow(paddingString: choiceString, textWidth: menuStringWidth, textStartSpace: 1, window: menuWindow)
			AddStringToWindow(normalString: "\n", window: menuWindow)
			currentLine += 1
			
			lineLeft -= 1
			choicesLineCount += 1
		}
		
		wattrset(menuWindow, COLOR_PAIR(WidgetUIColor.Background.rawValue))
		AddStringToWindow(normalString: "\t", window: menuWindow)
		wborder(menuWindow, 0, 0, 0, 0, 0, 0, 0, 0)
		touchwin(menuWindow)
		wrefresh(menuWindow)
	}
	
	mutating func updateSelectedChoice(isUp: Bool = false) {
		
		if(isUp) {
			
			if(currentChoiceIdx > 0) {
			
				currentChoiceIdx -= 1
				if(currentChoiceIdx < firstChoiceIdx) {
					firstChoiceIdx -= 1
				}
				
				wclear(menuWindow)
				drawMenuArea()
			}
			
		}else{
			
			if(currentChoiceIdx < choicesLineCount) {
				
				currentChoiceIdx += 1
				wclear(menuWindow)
				drawMenuArea()
			}else if(currentChoiceIdx >= choicesLineCount && currentChoiceIdx < (choices.count - 1)) {
				
				firstChoiceIdx += 1
				currentChoiceIdx += 1
				wclear(menuWindow)
				drawMenuArea()
			}
		}
	}
	
	func choiceSelected() {
		
	#if swift(>=3)
		selectionDelegate(selectedChoiceCode)
	#else
		selectionDelegate(selectedChoiceIdx: selectedChoiceCode)
	#endif
	}
	
	mutating func keyEvent(keyCode: Int32) {
		
		
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
		default:
			break
		}
	}
}
