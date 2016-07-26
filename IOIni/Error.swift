//
//  Error.swift
//  IORunner/IOIni
//
//  Created by ilker özcan on 22/07/16.
//
//

#if swift(>=3)

	/*
	#if os(Linux)
	enum ParseError: Error {
		
		case InvalidSyntax(err: String)
		case UnsupportedToken(err: String)
	}
	#else
	*/
	enum ParseError: ErrorProtocol {
			
		case InvalidSyntax(err: String)
		case UnsupportedToken(err: String)
	}
	//#endif
#elseif swift(>=2.2) && os(OSX)
	
	enum ParseError: ErrorType {
	
		case InvalidSyntax(err: String)
		case UnsupportedToken(err: String)
	}
#endif
