//
//  BackgroundWidget.swift
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

public struct BackgroundWidget {
	
	
#if swift(>=3)
	
	private var mainWindow: OpaquePointer
	
#if os(Linux)
	private var mainBgWindow: UnsafeMutablePointer<WINDOW>!
#else
	private var mainBgWindow: OpaquePointer!
#endif
	
	public init(mainWindow: OpaquePointer) {
		
		self.mainWindow = mainWindow
		initWindows()
	}
#elseif swift(>=2.2) && os(OSX)
	
	private var mainWindow: COpaquePointer
	
	private var mainBgWindow: COpaquePointer!
	
	public init(mainWindow: COpaquePointer) {
	
		self.mainWindow = mainWindow
		initWindows()
	}
#endif
	
	mutating func initWindows() {
		
	#if os(Linux)
		wmove(UnsafeMutablePointer<WINDOW>(mainWindow), 0, 0)
		self.mainBgWindow = subwin(UnsafeMutablePointer<WINDOW>(mainWindow), LINES, COLS, 0, 0)
	#else
		wmove(mainWindow, 0, 0)
		self.mainBgWindow = subwin(mainWindow, LINES, COLS, 0, 0)
	#endif
		
	#if os(Linux)
		wbkgd(self.mainBgWindow, UInt(COLOR_PAIR(WidgetUIColor.CyanBackground.rawValue)))
	#else
		wbkgd(self.mainBgWindow, UInt32(COLOR_PAIR(WidgetUIColor.CyanBackground.rawValue)))
	#endif
		keypad(self.mainBgWindow, true)
	}
	
	mutating func draw() {
		
		if(self.mainBgWindow == nil) {
			
			return
		}
		
		wmove(self.mainBgWindow, 0, 0)
		wborder(self.mainBgWindow, 0, 0, 0, 0, 0, 0, 0, 0)
		touchwin(self.mainBgWindow)
		wrefresh(self.mainBgWindow)
	}
	
	mutating func resize() {
		
		deinitWidget()
		initWindows()
		draw()
	}
	
	mutating func deinitWidget() {
		
		if(self.mainBgWindow != nil) {
			
			wclear(mainBgWindow)
			delwin(mainBgWindow)
			self.mainBgWindow = nil
		}
		
	#if os(Linux)
		wrefresh(UnsafeMutablePointer<WINDOW>(mainWindow))
	#else
		wrefresh(mainWindow)
	#endif
	}
}
