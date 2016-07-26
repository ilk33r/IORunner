//
//  TitleAndFooterWidget.swift
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

public struct TitleAndFooterWidget {
	
	static let WidgetHeight = 4
	
	private var title: String
	private var copyright: String
	private var keyControls: (String, String)
#if swift(>=3)
	
	private var mainWindow: OpaquePointer
	
#if os(Linux)
	private var titleWindow: UnsafeMutablePointer<WINDOW>!
	private var footerWindow: UnsafeMutablePointer<WINDOW>!
#else
	private var titleWindow: OpaquePointer!
	private var footerWindow: OpaquePointer!
#endif
#elseif swift(>=2.2) && os(OSX)
	
	private var mainWindow: COpaquePointer
	
	private var titleWindow: COpaquePointer!
	private var footerWindow: COpaquePointer!
#endif
	
	
	public var widgetRows: Int {
		
		get {
			return TitleAndFooterWidget.WidgetHeight
		}
	}
	
#if swift(>=3)

	public init(title: String, copyright: String, keyControls: (String, String), mainWindow: OpaquePointer) {
		
		self.title = title
		self.copyright = copyright
		self.keyControls = keyControls
		self.mainWindow = mainWindow
		self.initWindows()
	}
#elseif swift(>=2.2) && os(OSX)
	
	public init(title: String, copyright: String, keyControls: (String, String), mainWindow: COpaquePointer) {
	
		self.title = title
		self.copyright = copyright
		self.keyControls = keyControls
		self.mainWindow = mainWindow
		self.initWindows()
	}
#endif

	mutating func initWindows() {
	
	#if os(Linux)
		
		wmove(UnsafeMutablePointer<WINDOW>(mainWindow), 0, 0)
		self.titleWindow = subwin(UnsafeMutablePointer<WINDOW>(mainWindow), 1, COLS, 0, 0)
		wbkgd(titleWindow, UInt(COLOR_PAIR(WidgetUIColor.Title.rawValue)))
		keypad(titleWindow, true)
		
		self.footerWindow = subwin(UnsafeMutablePointer<WINDOW>(mainWindow), 3, COLS, LINES - 3, 0)
		wbkgd(footerWindow, UInt(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
		keypad(footerWindow, true)
	#else
		
		wmove(mainWindow, 0, 0)
		self.titleWindow = subwin(mainWindow, 1, COLS, 0, 0)
		wbkgd(titleWindow, UInt32(COLOR_PAIR(WidgetUIColor.Title.rawValue)))
		keypad(titleWindow, true)
		
		self.footerWindow = subwin(mainWindow, 3, COLS, LINES - 3, 0)
		wbkgd(footerWindow, UInt32(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
		keypad(footerWindow, true)
	#endif
	}
	
	func draw() {
		
		drawTitle()
		drawKeyboardInfo()
		drawFooter()
	}
	
	mutating func resize() {
		
		deinitWidget()
		initWindows()
		draw()
	}
	
	private func drawTitle() {
		
		if(self.titleWindow == nil) {
			return
		}
		
		let titleString = "   \(self.title)"
		waddstr(titleWindow, titleString)
		wrefresh(titleWindow)
	}
	
	private func drawKeyboardInfo() {
		
		if(self.footerWindow == nil) {
			return
		}
		
		wclear(footerWindow)
		wattrset(footerWindow, COLOR_PAIR(WidgetUIColor.Background.rawValue))
		wmove(footerWindow, 0, 0)
		waddstr(footerWindow, "\(keyControls.0) \n")
		wmove(footerWindow, 1, 0)
		waddstr(footerWindow, keyControls.1)
	}
	
	private func drawFooter() {
		
		if(self.footerWindow == nil) {
			return
		}
		
		wmove(footerWindow, 2, 0)
		wattrset(footerWindow, COLOR_PAIR(WidgetUIColor.FooterBackground.rawValue))
		
		var paddingSize = Int(COLS) - self.copyright.characters.count - 3
		if paddingSize < 0 {
			paddingSize = 0
		}
	#if swift(>=3)
		
		let copyrightStringPadding = String(repeating: Character(" "), count: paddingSize)
	#else
		
		let copyrightStringPadding = String(count: paddingSize, repeatedValue: Character(" "))
	#endif
		let copyrightString = "   \(self.copyright)\(copyrightStringPadding)"
		waddstr(footerWindow, copyrightString)
		
		wrefresh(footerWindow)
	}
	
	public mutating func updateTitle(titleString: String) {
		
		self.title = titleString
		wclear(titleWindow)
		drawTitle()
	}
	
	public mutating func updateKeyboardInfo(keyControls: (String, String)) {
		
		self.keyControls = keyControls
		wclear(footerWindow)
		drawKeyboardInfo()
		drawFooter()
	}
	
	mutating func deinitWidget() {
		
		if(self.titleWindow != nil) {
			
			wclear(titleWindow)
			delwin(titleWindow)
			self.titleWindow = nil
		}
		
		if(self.footerWindow != nil) {
			
			wclear(footerWindow)
			delwin(footerWindow)
			self.footerWindow = nil
		}
	
	#if os(Linux)
		wrefresh(UnsafeMutablePointer<WINDOW>(mainWindow))
	#else
		wrefresh(mainWindow)
	#endif
	}
	
	func keyEvent(keyCode: Int32) {
		// pass
	}
}
