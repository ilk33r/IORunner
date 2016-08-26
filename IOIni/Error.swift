//
//  Error.swift
//  IORunner/IOIni
//
//  Created by ilker özcan on 22/07/16.
//
//

#if swift(>=3)

	enum ParseError: Error {
		
		case InvalidSyntax(err: String)
		case UnsupportedToken(err: String)
	}
#elseif swift(>=2.2) && os(OSX)
	
	enum ParseError: ErrorType {
	
		case InvalidSyntax(err: String)
		case UnsupportedToken(err: String)
	}
#endif
