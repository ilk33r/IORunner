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
	
	/* ## Swift 3
	private var mainWindow: OpaquePointer
	private var mainBgWindow: OpaquePointer!
	*/
	
	private var mainWindow: COpaquePointer
	private var mainBgWindow: COpaquePointer!

	/* ## Swift 3
	public init(mainWindow: OpaquePointer) {
	*/
	public init(mainWindow: COpaquePointer) {
		
		self.mainWindow = mainWindow
		initWindows()
	}
	
	mutating func initWindows() {
		
		wmove(mainWindow, 0, 0)
		
		self.mainBgWindow = subwin(mainWindow, LINES, COLS, 0, 0)
		wbkgd(self.mainBgWindow, UInt32(COLOR_PAIR(WidgetUIColor.CyanBackground.rawValue)))
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
		
		wrefresh(mainWindow)
	}
}
