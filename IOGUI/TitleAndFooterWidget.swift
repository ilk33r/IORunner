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
#if os(Linux)
	private var mainWindow: UnsafeMutablePointer<WINDOW>
	
	private var titleWindow: UnsafeMutablePointer<WINDOW>!
	private var footerWindow: UnsafeMutablePointer<WINDOW>!
#else
	private var mainWindow: OpaquePointer
	
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
#if os(Linux)
	public init(title: String, copyright: String, keyControls: (String, String), mainWindow: UnsafeMutablePointer<WINDOW>) {
	
		self.title = title
		self.copyright = copyright
		self.keyControls = keyControls
		self.mainWindow = mainWindow
		self.initWindows()
	}
#else
	public init(title: String, copyright: String, keyControls: (String, String), mainWindow: OpaquePointer) {
		
		self.title = title
		self.copyright = copyright
		self.keyControls = keyControls
		self.mainWindow = mainWindow
		self.initWindows()
	}
#endif
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
	
		wmove(mainWindow, 0, 0)
		self.titleWindow = subwin(mainWindow, 1, COLS, 0, 0)
	#if os(Linux)
		wbkgd(titleWindow, UInt(COLOR_PAIR(WidgetUIColor.Title.rawValue)))
	#else
		wbkgd(titleWindow, UInt32(COLOR_PAIR(WidgetUIColor.Title.rawValue)))
	#endif
		keypad(titleWindow, true)
		
		self.footerWindow = subwin(mainWindow, 3, COLS, LINES - 3, 0)
	#if os(Linux)
		wbkgd(footerWindow, UInt(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
	#else
		wbkgd(footerWindow, UInt32(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
	#endif
		keypad(footerWindow, true)
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
		AddStringToWindow(normalString: titleString, window: titleWindow)
		wrefresh(titleWindow)
	}
	
	private func drawKeyboardInfo() {
		
		if(self.footerWindow == nil) {
			return
		}
		
		wclear(footerWindow)
		wattrset(footerWindow, COLOR_PAIR(WidgetUIColor.Background.rawValue))
		wmove(footerWindow, 0, 0)
		AddStringToWindow(normalString: "\(keyControls.0) \n", window: footerWindow)
		wmove(footerWindow, 1, 0)
		AddStringToWindow(normalString: keyControls.1, window: footerWindow)
	}
	
	private func drawFooter() {
		
		if(self.footerWindow == nil) {
			return
		}
		
		wmove(footerWindow, 2, 0)
		wattrset(footerWindow, COLOR_PAIR(WidgetUIColor.FooterBackground.rawValue))
		AddStringToWindow(paddingString: self.copyright, textWidth: Int(COLS), textStartSpace: 3, window: footerWindow)
		
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
	
		wrefresh(mainWindow)
	}
	
	func keyEvent(keyCode: Int32) {
		// pass
	}
}
