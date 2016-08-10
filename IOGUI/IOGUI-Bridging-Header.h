//
//  IOGUI-Bridging-Header.h
//  IOProcessChecker
//
//  Created by ilker özcan on 13/07/16.
//
//

#ifndef IOGUI_Bridging_Header_h
#define IOGUI_Bridging_Header_h

#ifndef _XOPEN_SOURCE
#	define _XOPEN_SOURCE
#endif

#ifndef _XOPEN_SOURCE_EXTENDED
#	define _XOPEN_SOURCE_EXTENDED
#endif

#ifndef NCURSES_WIDECHAR
#	define NCURSES_WIDECHAR 1
#endif

#ifdef Linux
#	import <locale.h>
#	import <curses.h>
#endif

#ifdef Darwin
#	import <curses.h>
#endif


#endif /* IOGUI_Bridging_Header_h */
