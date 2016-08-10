//
//  AppInfoWidget.swift
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

public struct GUIAppInfo {
	
	public enum InfoType {
		case NORMAL
		case DANGER
		case SUCCESS
	}
	
	var infoKey: String
	var infoVal: String
	var infoType: InfoType
	
	public init(infoKey: String, infoVal: String, infoType: InfoType) {
		
		self.infoKey = infoKey
		self.infoVal = infoVal
		self.infoType = infoType
	}
}

public struct AppInfoWidget {
	
	public var widgetRows: Int
	private var appInfo: [GUIAppInfo]
	private var startRow: Int32
#if swift(>=3)
	
#if os(Linux)
	private var mainWindow: UnsafeMutablePointer<WINDOW>
	
	private var appInfoWindow: UnsafeMutablePointer<WINDOW>!
	
	public init(appInfo: [GUIAppInfo], startRow: Int32, mainWindow: UnsafeMutablePointer<WINDOW>) {
	
		self.widgetRows = appInfo.count + 1
		self.appInfo = appInfo
		self.startRow = startRow
		self.mainWindow = mainWindow
		self.initWindows()
	}
#else
	private var mainWindow: OpaquePointer
	
	private var appInfoWindow: OpaquePointer!
	
	public init(appInfo: [GUIAppInfo], startRow: Int32, mainWindow: OpaquePointer) {
	
		self.widgetRows = appInfo.count + 1
		self.appInfo = appInfo
		self.startRow = startRow
		self.mainWindow = mainWindow
		self.initWindows()
	}
#endif
#elseif swift(>=2.2) && os(OSX)
	
	private var mainWindow: COpaquePointer
	private var appInfoWindow: COpaquePointer!
	
	public init(appInfo: [GUIAppInfo], startRow: Int32, mainWindow: COpaquePointer) {
	
		self.widgetRows = appInfo.count + 1
		self.appInfo = appInfo
		self.startRow = startRow
		self.mainWindow = mainWindow
		self.initWindows()
	}
#endif
	
	mutating func initWindows() {
		
		wmove(mainWindow, 0, 0)
		self.appInfoWindow = subwin(mainWindow, Int32(widgetRows), COLS, LINES - self.startRow, 0)
	#if os(Linux)
		wbkgd(self.appInfoWindow, UInt(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
	#else
		wbkgd(self.appInfoWindow, UInt32(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
	#endif
		keypad(self.appInfoWindow, true)
	}
	
	func draw() {
		
		if(self.appInfoWindow == nil) {
			
			return
		}
		
		var curStartRow = 0
		for appInfoData in appInfo {
			
			wmove(self.appInfoWindow, Int32(curStartRow), 4)
			wattrset(self.appInfoWindow, COLOR_PAIR(WidgetUIColor.Background.rawValue))
			AddStringToWindow(normalString: appInfoData.infoKey, window: self.appInfoWindow)
			wattrset(self.appInfoWindow, 13)
			
			switch appInfoData.infoType {
			case .NORMAL:
				wattrset(self.appInfoWindow, COLOR_PAIR(WidgetUIColor.WarningLevelCool.rawValue))
				AddStringToWindow(normalString: appInfoData.infoVal, window: self.appInfoWindow)
			case .DANGER:
				wattrset(self.appInfoWindow, COLOR_PAIR(WidgetUIColor.WarningLevelDanger.rawValue))
				AddStringToWindow(normalString: appInfoData.infoVal, window: self.appInfoWindow)
				break
			case .SUCCESS:
				wattrset(self.appInfoWindow, COLOR_PAIR(WidgetUIColor.WarningLevelSuccess.rawValue))
				AddStringToWindow(normalString: appInfoData.infoVal, window: self.appInfoWindow)
				break
			}
			
			curStartRow += 1
		}
		
		wattrset(self.appInfoWindow, 0)
		wrefresh(appInfoWindow)
	}
	
	mutating func resize() {
		
		deinitWidget()
		initWindows()
		draw()
	}
	
	public mutating func updateAppInfo(appInfo: [GUIAppInfo]) {
		
		self.appInfo = appInfo
		wclear(appInfoWindow)
		draw()
	}

	mutating func deinitWidget() {
		
		if(self.appInfoWindow != nil) {
			
			wclear(appInfoWindow)
			delwin(appInfoWindow)
			self.appInfoWindow = nil
		}
		
		wrefresh(appInfoWindow)
	}
	
	func keyEvent(keyCode: Int32) {
		// pass
	}

}
