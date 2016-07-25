//
//  GUITypes.swift
//  IORunner/IOGUI
//
//  Created by ilker özcan on 12/07/16.
//
//

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif
import Foundation

enum WidgetUIColor: Int32 {
	
	case Background = 1
	case FooterBackground = 2
	case Title = 3
	case Border = 4
	case WarningLevelSuccess = 5
	case WarningLevelDanger = 6
	case WarningLevelCool = 7
	case ButtonDanger = 8
	case ButtonCool = 9
	case ButtonDangerSelected = 10
	case CyanBackground = 11
	case Progress = 12
	case ProgressBar = 13
	case ProgressText = 14
}

public struct GUIConstants {
	
	public static let MenuButtons = "Q/ESC -- exit                  ENTER   -- select"
	public static let ModuleButtons = "B   -- back                  ENTER   -- select"
	public static let ArrowsUpDown = "Arrow keys move up/down between fields"
	public static let ArrowsLeftRight = "Arrow keys move left/right between fields"
	public static let ArrowsAll = "Arrow keys move left/right within a field, up/down between fields"
}

public enum MainGuiActions {
	case NONE
	case EXIT
	case BACK
}

public typealias MainGuiDelegate = (action: MainGuiActions) -> ()

public struct GUIWidgets {
	
	private var delegate: MainGuiDelegate
	/* ## Swift 3
	public var mainWindow: OpaquePointer
	*/
	public var mainWindow: COpaquePointer
	
	public var titleAndFooter: TitleAndFooterWidget?
	public var appInfo: AppInfoWidget?
	public var menu: MenuWidget?
	public var popup: PopupWidget?
	public var modules: ModulesWidget?
	public var background: BackgroundWidget?
	public var inputPopup: InputPopupWidget?
	
	public init(delegate: MainGuiDelegate) {
		
		self.delegate = delegate
		setlocale(LC_ALL, "")
		mainWindow = initscr()
		cbreak()
		noecho()
		
		if(has_colors()) {
			
			start_color()
			init_pair(Int16(WidgetUIColor.Background.rawValue), Int16(COLOR_WHITE),
			          Int16(use_default_colors()))
			init_pair(Int16(WidgetUIColor.FooterBackground.rawValue), Int16(COLOR_MAGENTA),
			          Int16(COLOR_WHITE))
			init_pair(Int16(WidgetUIColor.Title.rawValue), Int16(COLOR_BLACK),
			          Int16(COLOR_WHITE))
			init_pair(Int16(WidgetUIColor.Border.rawValue), Int16(COLOR_WHITE),
			          Int16(COLOR_CYAN))
			init_pair(Int16(WidgetUIColor.WarningLevelSuccess.rawValue), Int16(COLOR_GREEN),
			          Int16(COLOR_BLACK))
			init_pair(Int16(WidgetUIColor.WarningLevelDanger.rawValue), Int16(COLOR_RED),
			          Int16(COLOR_BLACK))
			init_pair(Int16(WidgetUIColor.WarningLevelCool.rawValue), Int16(COLOR_BLUE),
			          Int16(COLOR_BLACK))
			init_pair(Int16(WidgetUIColor.ButtonDanger.rawValue), Int16(COLOR_WHITE),
			          Int16(COLOR_RED))
			init_pair(Int16(WidgetUIColor.ButtonCool.rawValue), Int16(COLOR_WHITE),
			          Int16(COLOR_BLUE))
			init_pair(Int16(WidgetUIColor.ButtonDangerSelected.rawValue), Int16(COLOR_RED),
			          Int16(COLOR_RED))
			init_pair(Int16(WidgetUIColor.CyanBackground.rawValue), Int16(use_default_colors()),
			          Int16(COLOR_CYAN))
			init_pair(Int16(WidgetUIColor.ButtonCool.rawValue), Int16(COLOR_WHITE),
			          Int16(COLOR_BLUE))
			init_pair(Int16(WidgetUIColor.Progress.rawValue), Int16(COLOR_GREEN),
			          Int16(COLOR_RED))
			init_pair(Int16(WidgetUIColor.ProgressBar.rawValue), Int16(COLOR_RED),
			          Int16(COLOR_GREEN))
			init_pair(Int16(WidgetUIColor.ProgressText.rawValue), Int16(COLOR_WHITE),
			          Int16(COLOR_GREEN))
			bkgd(UInt32(COLOR_PAIR(WidgetUIColor.Background.rawValue)))
		}
		
		nonl()
		intrflush(stdscr, true)
		keypad(stdscr, true)
		curs_set(0)
	}
	
	public mutating func initTitleWidget(widget: TitleAndFooterWidget) {
		
		if(self.titleAndFooter != nil) {
			deinitTitleWidget()
		}
		
		self.titleAndFooter = widget
		self.titleAndFooter?.draw()
		wrefresh(mainWindow)
	}
	
	public mutating func deinitTitleWidget() {
		
		if(titleAndFooter != nil) {
			
			titleAndFooter?.deinitWidget()
			titleAndFooter = nil
			wrefresh(mainWindow)
		}
	}
	
	public func hasTitleWidget() -> Bool {
		
		return (titleAndFooter != nil) ? true : false
	}
	
	public mutating func initAppInfoWidget(widget: AppInfoWidget) {
		
		if(self.appInfo != nil) {
			deinitAppInfoWidget()
		}
		
		self.appInfo = widget
		self.appInfo?.draw()
		wrefresh(mainWindow)
	}
	
	public mutating func deinitAppInfoWidget() {
		
		if(appInfo != nil) {
			
			appInfo?.deinitWidget()
			appInfo = nil
			wrefresh(mainWindow)
		}
	}
	
	public func hasAppInfoWidget() -> Bool {
		
		return (appInfo != nil) ? true : false
	}
	
	public mutating func initMenuWidget(widget: MenuWidget) {
		
		if(self.menu != nil) {
			deinitMenuWidget()
		}
		
		self.menu = widget
		self.menu?.draw()
		wrefresh(mainWindow)
	}
	
	public mutating func deinitMenuWidget() {
		
		if(menu != nil) {
			
			menu?.deinitWidget()
			menu = nil
			wrefresh(mainWindow)
		}
	}
	
	public func hasMenuWidget() -> Bool {
		
		return (menu != nil) ? true : false
	}
	
	public mutating func initPopupWidget(widget: PopupWidget) {
		
		if(self.popup != nil) {
			deinitPopupWidget()
		}
		
		self.popup = widget
		self.popup?.draw()
		wrefresh(mainWindow)
	}
	
	public mutating func deinitPopupWidget() {
		
		if(popup != nil) {
			
			popup?.deinitWidget()
			popup = nil
			wrefresh(mainWindow)
		}
		
		resizeAll()
	}
	
	public func hasPopupWidget() -> Bool {
		
		return (popup != nil) ? true : false
	}
	
	public mutating func initInputPopupWidget(widget: InputPopupWidget) {
	
		if(self.inputPopup != nil) {
			deinitInputPopupWidget()
		}
		
		self.inputPopup = widget
		self.inputPopup?.draw()
		wrefresh(mainWindow)
	}
	
	public mutating func deinitInputPopupWidget() {
		
		if(inputPopup != nil) {
			
			inputPopup?.deinitWidget()
			inputPopup = nil
			wrefresh(mainWindow)
		}
		
		resizeAll()
	}
	
	public func hasInputPopupWidget() -> Bool {
		
		return (inputPopup != nil) ? true : false
	}
	
	public mutating func initModuleWidget(widget: ModulesWidget) {
		
		if(self.modules != nil) {
			deinitModuleWidget()
		}
		
		self.modules = widget
		self.modules?.draw()
		wrefresh(mainWindow)
	}
	
	public mutating func deinitModuleWidget() {
		
		if(modules != nil) {
			
			modules?.deinitWidget()
			modules = nil
			wrefresh(mainWindow)
		}
	}
	
	public func hasModuleWidget() -> Bool {
		
		return (modules != nil) ? true : false
	}
	
	public mutating func initBackgroundWidget(widget: BackgroundWidget) {
		
		if(self.background != nil) {
			deinitBackgroundWidget()
		}
		
		self.background = widget
		self.background?.draw()
		wrefresh(mainWindow)
	}
	
	public mutating func deinitBackgroundWidget() {
		
		if(background != nil) {
			
			background?.deinitWidget()
			background = nil
			wrefresh(mainWindow)
		}
	}
	
	public func hasBackgroundWidget() -> Bool {
		
		return (background != nil) ? true : false
	}
	
	mutating func resizeAll() {
		
		wclear(self.mainWindow)
		
		if(background != nil) {
			
			background?.resize()
		}
		
		if(titleAndFooter != nil) {
			
			titleAndFooter?.resize()
		}
		
		if(appInfo != nil) {
			
			appInfo?.resize()
		}
		
		if(menu != nil) {
			
			menu?.resize()
		}
		
		if(modules != nil) {
			
			modules?.resize()
		}
		
		if(popup != nil) {
			
			popup?.resize()
		}
		
		if(inputPopup != nil) {
			
			inputPopup?.resize()
		}
		
		wrefresh(self.mainWindow)
	}
	
	public mutating func deinitAll() {
		
		deinitTitleWidget()
		deinitAppInfoWidget()
		deinitMenuWidget()
		deinitModuleWidget()
		deinitPopupWidget()
		deinitBackgroundWidget()
		deinitInputPopupWidget()
		wrefresh(self.mainWindow)
	}
	
	mutating func sendKeyEventToWidget(keycode: Int32) {
		
		if(titleAndFooter != nil) {
			
			/* ## Swift 3
			titleAndFooter?.keyEvent(keyCode: keycode)
			*/
			titleAndFooter?.keyEvent(keycode)
		}
		
		if(appInfo != nil) {
			
			/* ## Swift 3
			appInfo?.keyEvent(keyCode: keycode)
			*/
			appInfo?.keyEvent(keycode)
		}
		
		if(popup != nil) {
			
			/* ## Swift 3
			popup?.keyEvent(keyCode: keycode)
			*/
			popup?.keyEvent(keycode)
			return
		}
		
		if(inputPopup != nil) {
			
			/* ## Swift 3
			inputPopup?.keyEvent(keyCode: keycode)
			*/
			inputPopup?.keyEvent(keycode)
			return
		}
		
		if(menu != nil) {
			
			/* ## Swift 3
			menu?.keyEvent(keyCode: keycode)
			*/
			menu?.keyEvent(keycode)
		}
		
		if(modules != nil) {
			
			/* ## Swift 3
			modules?.keyEvent(keyCode: keycode)
			*/
			modules?.keyEvent(keycode)
		}
	}
	
	public mutating func onGUI() {
		
		let currentKey = getch()
		
		if(currentKey == KEY_RESIZE) {
			
			self.resizeAll()
		}else if(currentKey == Int32(UnicodeScalar("q").value) || currentKey == 27 || currentKey == Int32(UnicodeScalar("Q").value)) {
			
			if(self.hasInputPopupWidget()) {
				/* ## Swift 3
				self.sendKeyEventToWidget(keycode: currentKey)
				*/
				self.sendKeyEventToWidget(currentKey)
			}else{
				self.delegate(action: MainGuiActions.EXIT)
			}
			
		}else if(currentKey == Int32(UnicodeScalar("b").value) || currentKey == Int32(UnicodeScalar("B").value)) {
			
			if(self.hasInputPopupWidget()) {
				/* ## Swift 3
				self.sendKeyEventToWidget(keycode: currentKey)
				*/
				self.sendKeyEventToWidget(currentKey)
			}else{
				self.delegate(action: MainGuiActions.BACK)
			}

		}else{
			
			/* ## Swift 3
			self.sendKeyEventToWidget(keycode: currentKey)
			*/
			self.sendKeyEventToWidget(currentKey)
		}
	}
	
	public mutating func exitGui(status: Int32) {
		
		self.deinitAll()
		endwin()
		exit(status)
	}
	
	public mutating func waitPopup(waitForSecond: UInt) {
		
		/* ## Swift 3
		let loopStartDate: UInt = UInt(Date().timeIntervalSince1970)
		*/
		let loopStartDate: UInt = UInt(NSDate().timeIntervalSince1970)
		repeat {
		
			/* ## Swift 3
			let currentDate: UInt = UInt(Date().timeIntervalSince1970)
			*/
			let currentDate: UInt = UInt(NSDate().timeIntervalSince1970)
			let dateDif = currentDate - loopStartDate
			
			if(dateDif > waitForSecond) {
				break
			}
			
		} while(true)
		self.deinitPopupWidget()
	}
	
	public mutating func refreshMainWindow() {
		
		self.resizeAll()
	}
}
