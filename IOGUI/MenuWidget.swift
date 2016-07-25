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

public typealias MenuChoicesSelectionDelegate = (selectedChoiceIdx: Int) -> ()

public struct MenuWidget {
	
	var widgetRows: Int
	
	private var startRow: Int
	/* ## Swift 3
	private var mainWindow: OpaquePointer
	*/
	private var mainWindow: COpaquePointer
	private var choices: [GUIMenuChoices]
	private var selectionDelegate: MenuChoicesSelectionDelegate
	private var menuAreaWidth: Int32
	
	/* ## Swift 3
	private var menuWindow: OpaquePointer!
	*/
	private var menuWindow: COpaquePointer!
	private var currentChoiceIdx = 0
	private var firstChoiceIdx = 0
	private var choicesLineCount = 0
	private var selectedChoiceCode = -1
	
	/* ## Swift 3
	public init(startRow: Int, widgetSize: Int, choices: [GUIMenuChoices], delegate: MenuChoicesSelectionDelegate, mainWindow: OpaquePointer) {
	*/
	public init(startRow: Int, widgetSize: Int, choices: [GUIMenuChoices], delegate: MenuChoicesSelectionDelegate, mainWindow: COpaquePointer) {
		self.startRow = startRow
		self.widgetRows = widgetSize
		self.choices = choices
		self.selectionDelegate = delegate
		self.mainWindow = mainWindow
		self.menuAreaWidth = 2
		initWindows()
	}
	
	mutating func initWindows() {
		
		wmove(mainWindow, 0, 0)
		self.menuWindow = subwin(self.mainWindow, LINES - Int32(self.widgetRows), COLS - menuAreaWidth, Int32(startRow), 1)
		wbkgd(self.menuWindow,UInt32(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
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
			
			var paddingSize = COLS - menuAreaWidth - choices[idx].choiceName.characters.count - 7
			if paddingSize < 0 {
				paddingSize = 0
			}
			let choiceStringPadding = String(count: Int(paddingSize), repeatedValue: Character(" "))
			let choiceString: String
			if(currentChoiceIdx == idx) {
				choiceString = " \u{2192} \(choices[idx].choiceName)\(choiceStringPadding)\n"
			}else{
				choiceString = "   \(choices[idx].choiceName)\(choiceStringPadding)\n"
			}
			
			waddstr(menuWindow, choiceString)
			currentLine += 1
			
			lineLeft -= 1
			choicesLineCount += 1
		}
		
		wattrset(menuWindow, COLOR_PAIR(WidgetUIColor.Background.rawValue))
		waddstr(menuWindow, "\t")
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
		
		selectionDelegate(selectedChoiceIdx: selectedChoiceCode)
	}
	
	mutating func keyEvent(keyCode: Int32) {
		
		
		switch keyCode {
		case KEY_ENTER, 13:
			self.choiceSelected()
			break
		case KEY_UP:
			/* ## Swift 3
			self.updateSelectedChoice(isUp: true)
			*/
			self.updateSelectedChoice(true)
			break
		case KEY_DOWN:
			self.updateSelectedChoice()
			break
		default:
			break
		}
	}
}
